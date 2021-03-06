import AST
import Utils

/// Borrow checker.
public struct BorrowChecker: ASTVisitor, Pass {

    public let name: String = "borrow checking"

    public init() {}

    public mutating func run(on module: Node, in context: Context) -> [Error] {
        self.context = context
        do {
            try visit(module)
            return errors
        } catch {
            return [error]
        }
    }

    // MARK: Statement processing

    /// Processes a statement block.
    public mutating func visit(_ node: Block) throws {
        try visit(node.statements)

        // Clean the borrows that go out of scope.
        let all: Set<Permission> = [.readOnly, .readWrite]
        for (_, symbol) in (context[node, "innerScope"] as! Scope).symbols {
            // Remove the reference from the typing context.
            defer {
                memory.removeValue(forKey: symbol)
                permissions.removeValue(forKey: symbol)
            }

            // Restore the permission on the location, assuming the reference was bound.
            guard let location = memory[symbol]
                else { continue }
            let refs = references(to: location).subtracting([symbol])
            permissions[location] = refs.reduce(all) {
                result, p in result.intersection(permissions[p]!)
            }
        }
    }

    /// Processes a variable declaration.
    public mutating func visit(_ node: VarDecl) {
        // Retrieve the symbol associated with the variable under declaration.
        let symbol: Symbol = context[node, "symbol"]!

        // Determine which permissions should be associated with the variable.
        // Π[x -> { ro }] | Π[x -> { ro, rw }]
        permissions[symbol] = node.mutability == .mutable
            ? [.readWrite, .readOnly]
            : [.readOnly]

        // Handle initial bindings.
        if let (op, value) = node.initialBinding {
            do {
                try visit(value)
                symbol.type = (context[value, "symbol"] as? Symbol)?.type
                if op == .copy {
                    try makeCopyBinding(to: symbol, at: node.range)
                } else {
                    let p: Permission = node.mutability == .mutable
                        ? .readWrite
                        : .readOnly
                    try makeRefBinding(to: symbol, on: value, borrowing: p, at: node.range)
                }
            } catch {
                errors.append(error)
                return
            }
        }
    }

    /// Processes a function declaration.
    public mutating func visit(_ node: FunDecl) throws {
        try traverse(node)
    }

    /// Processes a function parameter declaration.
    public mutating func visit(_ node: ParamDecl) throws {
        // Retrieve the symbol associated with the parameter.
        let symbol: Symbol = context[node, "symbol"]!

        // Determine which permissions should be associated with the parameter.
        // Π[x -> { ro }] | Π[x -> { ro, rw }]
        permissions[symbol] = node.mutability == .mutable
            ? [.readWrite]
            : [.readOnly]

        // Handle default values.
        if let (op, value) = node.defaultValue {
            do {
                try visit(value)
                symbol.type = (context[value, "symbol"] as? Symbol)?.type
                if op == .copy {
                    try makeCopyBinding(to: symbol, at: node.range)
                } else {
                    let p: Permission = node.mutability == .mutable
                        ? .readWrite
                        : .readOnly
                    try makeRefBinding(to: symbol, on: value, borrowing: p, at: node.range)
                }
            } catch {
                errors.append(error)
                return
            }
        } else {
            memory[symbol] = MemoryLocation()
        }
    }

    /// Processes a binding statement.
    public mutating func visit(_ node: Assignment) throws {
        // The l-value must be a referenceable expression.
        guard let destination: Symbol = context[node.lvalue, "symbol"]
            else { throw NonReferenceableExpression(node: node) }

        do {
            try visit(node.rvalue)
            destination.type = (context[node.rvalue, "symbol"] as? Symbol)?.type
            if node.op == .copy {
                try makeCopyBinding(to: destination, at: node.range)
            } else {
                let p: Permission = permissions[destination]!.contains(.readWrite)
                    ? .readWrite
                    : .readOnly
                try makeRefBinding(to: destination, on: node.rvalue, borrowing: p, at: node.range)
            }
        } catch {
            errors.append(error)
            return
        }
    }

    /// Processes a function call expression.
    public mutating func visit(_ node: CallExpr) throws {
        // Get the type of the callee.
        try visit(node.callee)
        guard let symbol: Symbol = context[node.callee, "symbol"] else {
            errors.append(TypeError(reason: "cannot find the type of \(node.callee)", at: node.range))
            return
        }
        guard let ty = symbol.type as? FunctionType else {
            let ty = symbol.type ?? GroundType.undefined
            errors.append(TypeError(reason: "\(ty) is not a function type", at: node.range))
            return
        }

        // Make sure the number of parameters agree.
        // FIXME: Handle default parameters.
        guard ty.domain.count == node.arguments.count else {
            errors.append(TypeError(
                reason: "invalid number of parameters, " +
                        "expected \(ty.domain.count), got \(node.arguments.count)",
                at: node.range))
            return
        }

        // Process the node's callee.
        let symbols = ty.domain.map { q -> Symbol in
            let symbol = Symbol(name: "?")
            permissions[symbol] = q == .mutable
                ? [ .readWrite ]
                : [ .readOnly ]
            return symbol
        }

        for (argument, symbol) in zip(node.arguments, symbols) {
            try visit(argument.value)
            guard argument.byReference
                else { continue }

            do {
                let p = permissions[symbol]!.first!
                try makeRefBinding(to: symbol, on: argument.value, borrowing: p,at: argument.range)
            } catch {
                errors.append(error)
                return
            }
        }

        // Release all symbols.
        let all: Set<Permission> = [.readOnly, .readWrite]
        for symbol in symbols {
            // Remove the reference from the typing context.
            defer {
                memory.removeValue(forKey: symbol)
                permissions.removeValue(forKey: symbol)
            }

            // Restore the permission on the location, assuming the reference was bound.
            guard let location = memory[symbol]
                else { continue }
            let refs = references(to: location).subtracting([symbol])
            permissions[location] = refs.reduce(all) {
                result, p in result.intersection(permissions[p]!)
            }
        }
    }

    /// Performs a copy binding.
    ///
    /// In the case of a copy binding, we create either a new memory location if the l-value is
    /// unbounded, or use the already bound one, as long as it is mutable.
    private mutating func makeCopyBinding(to lvalue: Symbol, at range: SourceRange) throws {
        // FIXME: Update the type of the symbol (and the memory location?)

        if memory[lvalue] != nil {
            // Make sure the location is mutable through the reference (i.g. rw ∈ ρx).
            guard effectivePermissions(of: lvalue).contains(.readWrite) else {
                throw BorrowError(reason: "cannot mutate immutable object", at: range)
            }
        } else {
            // Create a new memory location and bind it to the symbol.
            let location = MemoryLocation()
            memory[lvalue] = location

            // Notice that the location inherit from the permissions of its reference.
            // Π[l -> Π(x)]
            permissions[location] = permissions[lvalue]
        }
    }

    /// Performs a reference binding.
    private mutating func makeRefBinding(
        to lvalue: Symbol,
        on rvalue: Node,
        borrowing permission: Permission,
        at range: SourceRange) throws
    {
        // The r-value must be a referenceable expression.
        guard let source: Symbol = context[rvalue, "symbol"]
            else { throw NonReferenceableExpression(node: rvalue) }
        try makeRefBinding(to: lvalue, on: source, borrowing: permission, at: range)
    }

    /// Performs a reference binding.
    private mutating func makeRefBinding(
        to lvalue: Symbol,
        on rvalue: Symbol,
        borrowing permission: Permission,
        at range: SourceRange) throws
    {
        // FIXME: Update the type of the symbol (and the memory location?)

        // Make sure the r-value is bound to a location.
        guard let location = memory[rvalue]
            else { throw ReferenceError(symbol: rvalue, at: range) }

        // Restore the permission on the l-value's bound location, of any.
        if let bound = memory[lvalue] {
            let refs = references(to: location).subtracting([lvalue])
            let all: Set<Permission> = [.readOnly, .readWrite]
            permissions[bound] = refs.reduce(all) {
                result, p in result.intersection(permissions[p]!)
            }
        }

        // In the case of an immutable (resp. mutable) borrow, there should not be more than one
        // reference with read-write (resp. read-only) permission on the referred location.
        let refs = references(to: location)
        let incompatible = refs.compactMap({ permissions[$0]?.contains(permission.dual) })
        guard incompatible.count <= 1
            else { throw BorrowError(reason: "incompatible borrow", at: range) }

        // Bind the variable to the given memory location and update permissions.
        memory[lvalue] = location
        permissions[lvalue] = [permission]
        permissions[location] = [permission]
    }

    /// Returns the set of references on the given abstract memory location.
    private func references(to location: MemoryLocation) -> Set<Symbol> {
        return Set(memory.compactMap({ $0.value === location ? $0.key : nil }))
    }

    // MARK: Expression typing

    /// Returns the effective permissions of the given symbol.
    private func effectivePermissions(of symbol: Symbol) -> Set<Permission> {
        let symbolPermissions = permissions[symbol] ?? []
        if let locationPermissions = memory[symbol].flatMap({ permissions[$0] }) {
            return symbolPermissions.intersection(locationPermissions)
        }
        return symbolPermissions
    }

    // MARK: Internals

    /// A mapping that associates expressions to abstract memory locations.
    private var memory: [Symbol: MemoryLocation] = [:]
    /// A mapping that associates expressions and abstract memory locations to permissions.
    private var permissions: ReferenceMap<AnyObject, Set<Permission>> = [:]

    /// The AST context.
    private var context: Context!
    /// An array of the errors detected during the pass.
    private var errors: [Error] = []

}

fileprivate enum Permission: String, CustomStringConvertible {

    case readOnly = "ro", readWrite = "rw"

    var dual: Permission {
        return self == .readOnly
            ? .readWrite
            : .readOnly
    }

    var description: String { return rawValue }

}

fileprivate class MemoryLocation: CustomStringConvertible {

    init() {
        self.id = MemoryLocation.nextID
        MemoryLocation.nextID += 1
    }

    var id: Int
    static var nextID = 0

    var description: String { return "l\(id)" }

}
