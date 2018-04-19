import AST

public protocol Pass {

    mutating func run(on module: Node, in context: Context) -> [Error]

    var name: String { get }

}
