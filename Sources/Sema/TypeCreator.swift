import AST

/// Type creator.
public struct TypeCreator: ASTVisitor, Pass {

    public let name: String = "type creation"

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

    public mutating func visit(_ node: FunDecl) throws {
        guard let symbol: Symbol = context[node, "symbol"] else {
            errors.append(UndefinedSymbol(name: node.name, at: node.range))
            return
        }
        symbol.type = FunctionType(domain: node.parameters.map({ $0.mutability }))

        // Visit the parameters, in case a function is declared in their default values.
        try visit(node.parameters)
    }

    /// The AST context.
    private var context: Context!
    /// An array of the errors detected during the pass.
    private var errors: [Error] = []

}
