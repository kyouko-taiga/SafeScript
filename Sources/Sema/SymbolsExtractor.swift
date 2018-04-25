import AST
import Utils

/// A visitor that extracts the symbols declared in the AST's scopes.
///
/// This visitor annotates scope-opening nodes with symbols for each entity (e.g. function, type,
/// ...) that's declared within said scope.
///
/// This step is indispensable for lexical scoping (perfomed by the `ScopeBinder`). It's what's
/// let us bind identifiers to the appropriate declaration (i.e. to the appropriate scope).
public struct SymbolsExtractor: ASTVisitor, Pass {

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

    public mutating func visit(_ node: Block) throws {
        // Create a new scope for the block.
        let innerScope = Scope(parent: scopes.top)
        context[node, "innerScope"] = innerScope

        // Visit the block's statements.
        scopes.push(innerScope)
        try self.visit(node.statements)
        scopes.pop()
    }

    public mutating func visit(_ node: VarDecl) throws {
        // Make sure the property's name wasn't already declared.
        if scopes.top!.defines(name: node.name) {
            errors.append(DuplicateDeclaration(name: node.name, at: node.range))
        }

        // Create a new symbol for the property, and visit the node's declaration.
        let symbol = Symbol(name: node.name)
        scopes.top!.add(symbol: symbol)
        context[node, "scope"] = scopes.top
        context[node, "symbol"] = symbol
        try traverse(node)
    }


    public mutating func visit(_ node: FunDecl) throws {
        // Make sure the function's name wasn't already declared.
        if scopes.top!.defines(name: node.name) {
            errors.append(DuplicateDeclaration(name: node.name, at: node.range))
        }

        // Create a symbol for the function's name within the currently visited scope.
        let symbol = Symbol(name: node.name)
        scopes.top!.add(symbol: symbol)
        context[node, "scope"] = scopes.top
        context[node, "symbol"] = symbol

        // Create a new scope for the function's parameters.
        let innerScope = Scope(name: node.name, parent: scopes.top)
        scopes.push(innerScope)
        context[node, "innerScope"] = innerScope

        // Add the function's parameters to its inner scope.
        try visit(node.parameters)

        // Visit the function's body.
        // Note that we visit the statements directly, so as to avoid creating an additional
        // scope. That's because JavaScript's function parameters are declared in the same scope
        // as that of the function body.
        context[node.body, "innerScope"] = innerScope
        for statement in node.body.statements {
            try visit(statement)
        }
        scopes.pop()
    }

    public mutating func visit(_ node: ParamDecl) throws {
        // Make sure the parameter's name wasn't already declared.
        if scopes.top!.defines(name: node.name) {
            errors.append(DuplicateDeclaration(name: node.name, at: node.range))
        }

        // Create a new symbol for the parameter, and visit the node's declaration.
        let symbol = Symbol(name: node.name)
        scopes.top!.add(symbol: symbol)
        context[node, "scope"] = scopes.top
        context[node, "symbol"] = symbol
        try traverse(node)
    }

    public mutating func visit(_ node: ClassDecl) throws {
        // Make sure the class name wasn't already declared.
        if scopes.top!.defines(name: node.name) {
            errors.append(DuplicateDeclaration(name: node.name, at: node.range))
        }

        // Create a new symbol for the class.
        let symbol = Symbol(name: node.name)
        scopes.top!.add(symbol: symbol)
        context[node, "scope"] = scopes.top
        context[node, "symbol"] = symbol

        // Visit the class body.
        try traverse(node)
        scopes.pop()
    }

    // MARK: Internals

    private var context: Context!
    private var scopes: Stack<Scope> = []
    private var errors: [Error] = []

}
