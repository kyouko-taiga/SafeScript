import AST
import Utils

/// Borrow checker.
public struct BorrowChecker: ASTVisitor, Pass {

    public let name: String = "symbol extraction"

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

    public mutating func visit(_ node: Block) throws {
        try self.visit(node.statements)

        // Clean the borrows that go out of scope.
        let all: Set<Permission> = [.readOnly, .readWrite]
        for (_, symbol) in (context[node, "innerScope"] as! Scope).symbols {
            // Remove the reference from the typing context.
            defer {
                types.removeValue(forKey: symbol)
                memory.removeValue(forKey: symbol)
                permissions.removeValue(forKey: symbol)
            }

            // Restore the permission on the location, assuming the reference was bound.
            guard let location = memory[symbol]
                else { continue }
            let refs = references(to: location).subtracting([symbol])
            let perm = refs.reduce(Set<Permission>([.readOnly, .readWrite])) { result, p in
                result.intersection(permissions[p]!)
            }
            permissions[location] = perm
        }
    }

    public mutating func visit(_ node: VarDecl) {
        let symbol: Symbol = context[node, "symbol"]!

        permissions[symbol] = node.mutability == .mutable
            ? [.readWrite, .readOnly]
            : [.readOnly]

        if let (op, value) = node.initialBinding {
            types[symbol] = type(of: value)

            if op == .copy {
                // Allocate a new memory location and bind it to the variable's symbol.
                let location = MemoryLocation()
                memory[symbol] = location

                // The allocated location inherit from the permissions of its unique reference.
                permissions[location] = permissions[symbol]
            } else {
                do {
                    try makeBorrow(
                        for: symbol, borrowing: value,
                        permission: node.mutability == .const ? .readOnly : .readWrite)
                } catch {
                    errors.append(error)
                    return
                }
            }
        }
    }

    /// Performs an immutable or mutable borrow.
    mutating func makeBorrow(
        for symbol: Symbol, borrowing value: Node, permission: Permission) throws
    {
        // The r-value must be a referenceable expression.
        guard let destination: Symbol = context[value, "symbol"]
            else { throw NonReferenceableExpression(node: value) }

        // Make sure the symbol is bound to a location.
        guard let location = memory[destination]
            else { throw ReferenceError(symbol: destination, at: value.range) }

        // In the case of an immutable (resp. mutable) borrow, there should not be more than one
        // reference with read-write (resp. read-only) permission on the referred location.
        let refs = references(to: location)
        let incompatible = refs.compactMap({ permissions[$0]?.contains(permission.dual) })
        guard incompatible.count <= 1 else {
            throw BorrowError(reason: "incompatible borrow", at: value.range)
        }

        // Bind the variable to the given memory location and update permissions.
        memory[symbol] = location
        permissions[symbol] = [permission]
        permissions[location] = [permission]
    }

    /// Returns the set of references on the given abstract memory location.
    func references(to location: MemoryLocation) -> Set<Symbol> {
        return Set(memory.compactMap({ $0.value == location ? $0.key : nil }))
    }

    // MARK: Expression typing

    mutating func type(of node: Node) -> SafeScriptType {
        switch node {
        case let n as Identifier   : return type(of: n)
        case let n as ScalarLiteral: return type(of: n)
        default:
            errors.append(UnexpectedNode(node: node))
            return GroundType.undefined
        }
    }

    mutating func type(of node: Identifier) -> SafeScriptType {
        let symbol: Symbol = context[node, "symbol"]!
        return types[symbol] ?? GroundType.undefined
    }

    mutating func type(of node: ScalarLiteral) -> SafeScriptType {
        switch node.value {
        case is Int, is Double:
            return GroundType.number
        case is String:
            return GroundType.string
        default:
            return GroundType.undefined
        }
    }

    // MARK: Internals

    /// A mapping that associates variables to types.
    var types: [Symbol: SafeScriptType] = [:]
    /// A mapping that associates expressions to abstract memory locations.
    var memory: [Symbol: MemoryLocation] = [:]
    /// A mapping that associates expressions and abstract memory locations to permissions.
    var permissions: ReferenceMap<AnyObject, Set<Permission>> = [:]

    /// The AST context.
    private var context: Context!
    /// An array of the errors detected during the pass.
    private var errors: [Error] = []

}

enum Permission {

    case readOnly, readWrite

    var dual: Permission {
        return self == .readOnly
            ? .readWrite
            : .readOnly
    }

}

class MemoryLocation: Hashable {

    init() {
        self.id = MemoryLocation.nextID
        MemoryLocation.nextID += 1
    }

    var hashValue: Int {
        return id
    }

    static func == (lhs: MemoryLocation, rhs: MemoryLocation) -> Bool {
        return lhs === rhs
    }

    static func alloc() -> MemoryLocation {
        return MemoryLocation()
    }

    private var id: Int
    private static var nextID = 0

}
