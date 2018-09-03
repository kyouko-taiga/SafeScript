import AST

/// Enumerates the kinds of tokens.
public enum TokenKind: String {

    // MARK: Literals

    case number
    case string
    case bool

    // MARK: Identifiers

    case identifier

    // MARK: Operators

    case pow            = "**"
    case mul            = "*"
    case div            = "/"
    case mod            = "%"
    case add            = "+"
    case sub            = "-"
    case lshift         = "<<"
    case rshift         = ">>"
    case urshift        = ">>>"
    case lt             = "<"
    case le             = "<="
    case ge             = ">="
    case gt             = ">"
    case `in`
    case instanceof
    case eq             = "=="
    case ne             = "!="
    case seq            = "==="
    case sne            = "!=="
    case not            = "!"
    case invert         = "~"
    case band           = "&"
    case bxor           = "^"
    case bor            = "|"
    case and            = "&&"
    case or             = "||"
    case inc            = "++"
    case dec            = "--"
    case typeof
    case void
    case delete
    case await
    case copy           = "="
    case borrow         = "&-"
    case arrow          = "=>"

    case dot            = "."
    case comma          = ","
    case colon          = ":"
    case semicolon      = ";"
    case questionMark   = "?"
    case ellipsis       = "..."
    case newline
    case eof

    case leftParen      = "("
    case rightParen     = ")"
    case leftBrace      = "{"
    case rightBrace     = "}"
    case leftBracket    = "["
    case rightBracket   = "]"

    // MARK: Keywords

    case `let`
    case `var`
    case cst
    case mut
    case async
    case `func`
    case `static`
    case `class`
    case new
    case `while`
    case `for`
    case `break`
    case `continue`
    case `return`
    case yield
    case `if`
    case `else`
    case `switch`
    case `case`

    // MARK: Error tokens

    case unknown
    case unterminatedBlockComment
    case unterminatedStringLiteral

}

/// Represents a token.
public struct Token {

    public init(kind: TokenKind, value: String? = nil, range: SourceRange) {
        self.kind = kind
        self.value = value
        self.range = range
    }

    /// Whether or not the token is a statement delimiter.
    public var isStatementDelimiter: Bool {
        return kind == .newline || kind == .semicolon
    }

    /// Whether or not the token is an prefix operator.
    public var isPrefixOperator: Bool {
        return asPrefixOperator != nil
    }

    /// The token as a prefix operator.
    public var asPrefixOperator: PrefixOperator? {
        return PrefixOperator(rawValue: kind.rawValue)
    }

    /// Whether or not the token is an postfix operator.
    public var isPostfixOperator: Bool {
        return asPostfixOperator != nil
    }

    /// The token as a postfix operator.
    public var asPostfixOperator: PostfixOperator? {
        return PostfixOperator(rawValue: kind.rawValue)
    }

    /// Whether or not the token is an infix operator.
    public var isInfixOperator: Bool {
        return asInfixOperator != nil
    }

    /// The token as an infix operator.
    public var asInfixOperator: InfixOperator? {
        return InfixOperator(rawValue: kind.rawValue)
    }

    /// Whether or not the token is a binding operator.
    public var isBindingOperator: Bool {
        return asBindingOperator != nil
    }

    /// The token as a binding operator.
    public var asBindingOperator: BindingOperator? {
        return BindingOperator(rawValue: kind.rawValue)
    }

    /// The kind of the token.
    public let kind: TokenKind
    /// The optional value of the token.
    public let value: String?
    /// The range of characters that compose the token in the source file.
    public let range: SourceRange

}

extension Token: Equatable {

    public static func == (lhs: Token, rhs: Token) -> Bool {
        return (lhs.kind == rhs.kind) && (lhs.value == rhs.value) && (lhs.range == rhs.range)
    }

}

extension Token: CustomStringConvertible {

    public var description: String {
        return kind.rawValue
    }

}
