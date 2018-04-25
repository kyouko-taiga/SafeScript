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

public struct UnexpectedNode: SemanticError, CustomStringConvertible {

    public init(node: Node) {
        self.node = node
    }

    public let node: Node

    public var range: SourceRange? {
        return node.range
    }

    public var description: String {
        let location = "\(node.range.start)"
        return "\(location): unexpected node: \(node)"
    }

}

public struct NonReferenceableExpression: SemanticError, CustomStringConvertible {

    public init(node: Node) {
        self.node = node
    }

    public let node: Node

    public var range: SourceRange? {
        return node.range
    }

    public var description: String {
        let location = "\(node.range.start)"
        return "\(location): non-referenceable expression: \(node)"
    }

}

public struct ReferenceError: SemanticError, CustomStringConvertible {

    public init(symbol: Symbol, at range: SourceRange? = nil) {
        self.symbol = symbol
        self.range = range
    }

    public let symbol: Symbol
    public let range: SourceRange?

    public var description: String {
        let location = self.range != nil
            ? "\(self.range!.start)"
            : "?:?"
        return "\(location): reference error: \(symbol.name)"
    }

}

public struct BorrowError: SemanticError, CustomStringConvertible {

    public init(reason: String, at range: SourceRange? = nil) {
        self.reason = reason
        self.range = range
    }

    public let reason: String
    public let range: SourceRange?

    public var description: String {
        let location = self.range != nil
            ? "\(self.range!.start)"
            : "?:?"
        return "\(location): \(reason)"
    }

}

public struct TypeError: SemanticError, CustomStringConvertible {

    public init(reason: String, at range: SourceRange? = nil) {
        self.reason = reason
        self.range = range
    }

    public let reason: String
    public let range: SourceRange?

    public var description: String {
        let location = self.range != nil
            ? "\(self.range!.start)"
            : "?:?"
        return "\(location): \(reason)"
    }

}
