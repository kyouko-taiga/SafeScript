extension Parser {

    /// Parses an expression.
    ///
    /// Because this parser is implemented as a recursive descent parser, a particular attention
    /// must be made as to how expressions can be parsed witout triggering infinite recursions,
    /// due to the left-recursion of the related production rules.
    func parseExpression() throws -> Node {
        // var operand = try parseAtom()
        return try parseAtom()
    }

    func parseAtom() throws -> Node {
        let startToken = peek()

        var expression: Node
        switch startToken.kind {
        case .number:
            consume()
            let value: Any = Int(startToken.value!) ?? Double(startToken.value!)!
            expression = ScalarLiteral(value: value, range: startToken.range)

        default:
            throw unexpectedToken(expected: "expression")
        }

        return expression
    }

}
