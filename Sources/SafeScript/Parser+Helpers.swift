extension Parser {

    /// Attempts to run the given parsing function but backtracks if it failed.
    func attempt<Result>(_ parse: () throws -> Result) -> Result? {
        let backtrackingPosition = streamPosition
        guard let result = try? parse() else {
            rewind(to: backtrackingPosition)
            return nil
        }
        return result
    }

    /// Parses a list of elements, separated by a `,`.
    ///
    /// This helper will parse a list of elements, separated by a `,` and optionally ending with
    /// one, until it finds `delimiter`. New lines before and after each element will be consumed,
    /// but the delimiter won't.
    func parseList<Element>(
        delimitedBy delimiter: TokenKind,
        parsingElementWith parse: () throws -> Element)
        rethrows -> [Element]
    {
        // Skip leading new lines.
        consumeMany { $0.kind == .newline }

        // Parse as many elements as possible.
        var elements: [Element] = []
        while peek().kind != delimiter {
            // Parse an element.
            try elements.append(parse())

            // If the next consumable token isn't a separator, stop parsing here.
            consumeNewlines()
            if consume(.comma) == nil {
                break
            }

            // Skip trailing new after the separator.
            consumeNewlines()
        }

        return elements
    }

    /// Tiny helper to build parse errors.
    func parseFailure(_ syntaxError: SyntaxError, range: SourceRange? = nil) -> ParseError {
        return ParseError(syntaxError, range: range ?? peek().range)
    }

    /// Tiny helper to build unexpected token errors.
    func unexpectedToken(expected: String? = nil, got token: Token? = nil) -> ParseError {
        let t = token ?? peek()
        return ParseError(.unexpectedToken(expected: expected, got: t), range: t.range)
    }

}
