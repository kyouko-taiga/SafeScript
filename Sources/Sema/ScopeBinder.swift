import AST
import Utils

public struct ScopeBinder: ASTVisitor, Pass {

    public let name: String = "scope binding"

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

    public mutating func visit(_ node: Block) throws {
        // NOTE: We choose to make all module scopes descend from SafeScript's built-in scope. As
        // a result, built-in symbols (e.g. `Math`) can be refered "as-is" within source code, yet
        // we don't loose the ability to shadow them.
        let innerScope: Scope = context[node, "innerScope"]!
        innerScope.parent = self.scopes.top

        self.scopes.push(innerScope)
        try self.visit(node.statements)
        self.scopes.pop()
    }

    public mutating func visit(_ node: VarDecl) throws {
        let scope: Scope = context[node, "scope"]!
        self.underDeclaration[scope] = node.name
        try self.traverse(node)
        self.underDeclaration.removeValue(forKey: scope)
    }

    public mutating func visit(_ node: FunDecl) throws {
        // TODO: When we'll implement parameter default values, we'll also have to make sure that
        // the identifiers in the default value don't get bound to other parameters. For instance,
        // the following should throw an `UndefinedSymbol`:
        //
        //     function f(x: const = y, y: const) {}
        //

        // Visit the function.
        self.scopes.push(context[node, "innerScope"]!)
        try self.traverse(node)
        self.scopes.pop()
    }

    public mutating func visit(_ node: ClassDecl) throws {
        self.scopes.push(context[node, "innerScope"]!)
        try self.visit(node.members)
        self.scopes.pop()
    }

    public mutating func visit(_ node: DotExpr) throws {
        // Find the scope that defines the owner of the visited expression.
        try self.visit(node.owner)
        let symbol: Symbol = context[node.owner, "symbol"]!

        // Look for a symbol of the same name in the owner's members, or create a new one.
        context[node, "scope"] = symbol.scope
        if let child = symbol.children.first(where: { $0.name == node.attribute }) {
            context[node, "symbol"] = child
        } else {
            let child = Symbol(name: node.attribute)
            symbol.scope?.add(symbol: child)
            context[node, "symbol"] = child
        }
    }

    public mutating func visit(_ node: Identifier) throws {
        // Find the scope that defines the visited identifier.
        guard let scope = self.scopes.top!.findScopeDefining(name: node.name) else {
            self.errors.append(UndefinedSymbol(name: node.name, at: node.range))
            return
        }

        // If we're visiting the initial value of the identifier's declaration (e.g. as part of a
        // property declaration), we should raise an undefined symbol error.
        guard self.underDeclaration[scope] != node.name else {
            self.errors.append(UndefinedSymbol(name: node.name, at: node.range))
            return
        }

        context[node, "scope"] = scope
        context[node, "symbol"] = scope.symbols[node.name]
    }

    /// The AST context.
    private var context: Context!

    /// A stack of scopes.
    private var scopes: Stack<Scope> = []

    /// Keeps track of what identifier is being declared while visiting its declaration.
    ///
    /// This mapping will help us keep track of what the identifier being declared when visiting
    /// its declaration, which is necessary to properly flagging declaration that refer to the
    /// same name as the identifier under declaration (e.g. `let x = x`).
    private var underDeclaration: [Scope: String] = [:]

    private var errors: [Error] = []

}
