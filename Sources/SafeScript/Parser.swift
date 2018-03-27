public class Parser {

    // MARK: Public API

    /// Initializes a parser with a token stream.
    ///
    /// - Note: The token stream must have at least one token and ends with `.eof`.
    public init<S>(_ tokens: S, moduleName: String) where S: Sequence, S.Element == Token {
        self.stream = Array(tokens)
        self.moduleName = moduleName
        assert((self.stream.count > 0) && (self.stream.last!.kind == .eof), "invalid token stream")
    }

    /// Initializes a parser from a source file.
    convenience public init(path: String) throws {
        let moduleName = path.split(separator: ".").first!
        let lexer = try Lexer(path: path)
        self.init(lexer, moduleName: String(moduleName))
    }

    /// Parses the token stream into an AST.
    public func parse() throws -> Block {
        var statements: [Node] = []

        while true {
            // Skip statement delimiters.
            consumeMany { $0.isStatementDelimiter }
            // Check for end of file.
            guard peek().kind != .eof else { break }
            // Parse a statement.
            statements.append(try parseStatement())
        }

        let range = statements.isEmpty
            ? SourceRange(at: SourceLocation())
            : SourceRange(from: statements.first!.range.start, to: statements.last!.range.end)
        return Block(statements: statements, range: range)
    }

    // MARK: Properties

    /// The name of the module being parsed.
    let moduleName: String
    /// The stream of tokens.
    var stream: [Token]
    /// The current position in the token stream.
    var streamPosition: Int = 0

}
