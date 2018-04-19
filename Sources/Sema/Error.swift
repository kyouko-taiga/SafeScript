import AST

public protocol SemanticError: Error {

    var range: SourceRange? { get }

}

public struct DuplicateDeclaration: SemanticError, CustomStringConvertible {

    public init(name: String, at range: SourceRange? = nil) {
        self.name = name
        self.range = range
    }

    public let name : String
    public let range: SourceRange?

    public var description: String {
        let location = self.range != nil
            ? "\(self.range!.start)"
            : "?:?"
        return "\(location): duplicate declaration: \(name)"
    }

}

public struct UndefinedSymbol: SemanticError, CustomStringConvertible {

    public init(name: String, at range: SourceRange? = nil) {
        self.name = name
        self.range = range
    }

    public let name : String
    public let range: SourceRange?

    public var description: String {
        let location = self.range != nil
            ? "\(self.range!.start)"
            : "?:?"
        return "\(location): undefined symbol: \(name)"
    }

}
