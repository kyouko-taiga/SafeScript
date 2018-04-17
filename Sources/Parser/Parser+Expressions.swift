import AST

extension Parser {

    /// Parses an expression.
    ///
    /// Because this parser is implemented as a recursive descent parser, a particular attention
    /// must be made as to how expressions can be parsed witout triggering infinite recursions,
    /// due to the left-recursion of the related production rules.
    func parseExpression() throws -> Node {
        var left = try parseAtom()

        // Attempt to parse the remainder of an infix expression.
        while true {
            let backtrackPosition = streamPosition
            consumeNewlines()
            guard let op = peek().asInfixOperator else {
                rewind(to: backtrackPosition)
                break
            }
            consume()

            // If an infix operator could be consumed, then we MUST parse a right operand.
            let right = try parseAtom()

            // If the left operand is an infix expression, we should check the precedence of its
            // operator and potentially reorder the operands.
            if let expr = left as? InfixExpr, expr.op.precedence < op.precedence {
                let l = expr.left
                let r = InfixExpr(
                    left: expr.right, op: op, right: right,
                    range: SourceRange(from: l.range.start, to: right.range.end))
                left = InfixExpr(
                    left: l, op: expr.op, right: r,
                    range: SourceRange(from: l.range.start, to: r.range.start))
            } else {
                left = InfixExpr(
                    left: left, op: op, right: right,
                    range: SourceRange(from: left.range.start, to: right.range.start))
            }
        }

        return left
    }

    func parseAtom() throws -> Node {
        let startToken = peek()

        var expression: Node
        switch startToken.kind {
        case .number:
            consume()
            let value: Any = Int(startToken.value!) ?? Double(startToken.value!)!
            expression = ScalarLiteral(value: value, range: startToken.range)

        case .string:
            consume()
            expression = ScalarLiteral(value: startToken.value!, range: startToken.range)

        case .bool:
            consume()
            expression = ScalarLiteral(value: startToken.value == "true", range: startToken.range)

        case .identifier:
            expression = try parseIdentifier()

        case .leftBracket:
            expression = try parseArrayLiteral()

        case .leftBrace:
            expression = try parseObjectLiteral()

        case _ where startToken.isPrefixOperator:
            expression = try parsePrefixExpr()

        default:
            throw unexpectedToken(expected: "expression")
        }

        // Parse the optional suffix of the expression.
        suffix:while true {
            // Consuming new lines here allow us to parse expressions suffixes split over several
            // lines. However, if the remainder of the token stream turns out not to be parsable
            // as a suffix, we should backtrack to avoid consuming possibly significant new lines.
            let backtrackPosition = streamPosition
            consumeNewlines()
            switch peek().kind {
            case .leftParen:
                consume()
                let args = try parseList(
                    delimitedBy: .rightParen, parsingItemsWith: parseArgument)
                guard let endToken = consume(.rightParen)
                    else { throw unexpectedToken(expected: ")") }
                expression = CallExpr(
                    callee: expression, arguments: args,
                    range: SourceRange(from: expression.range.start, to: endToken.range.end))

            case .leftBracket:
                consume()
                consumeNewlines()
                let index = try parseExpression()
                guard let endToken = consume(.rightBracket, afterMany: .newline)
                    else { throw unexpectedToken(expected: "]") }
                expression = SubscriptExpr(
                    callee: expression, index: index,
                    range: SourceRange(from: expression.range.start, to: endToken.range.end))

            case .dot:
                consume()
                guard let ident = consume(.identifier, afterMany: .newline)
                    else { throw parseFailure(.expectedMember) }
                expression = DotExpr(
                    owner: expression, attribute: ident.value!,
                    range: SourceRange(from: expression.range.start, to: ident.range.end))

            case .inc, .dec:
                let op = consume()
                expression = PostfixExpr(
                    op: op!.asPostfixOperator!, operand: expression,
                    range: SourceRange(from: expression.range.start, to: op!.range.end))

            case .questionMark:
                consume()
                consumeNewlines()
                let thenValue = try parseExpression()
                guard consume(.colon, afterMany: .newline) != nil
                    else { throw unexpectedToken(expected: ":") }
                consumeNewlines()
                let elseValue = try parseExpression()
                expression = TernaryExpr(
                    condition: expression, thenValue: thenValue, elseValue: elseValue,
                    range: SourceRange(from: expression.range.start, to: elseValue.range.end))

            default:
                rewind(to: backtrackPosition)
                break suffix
            }
        }

        return expression
    }


    func parsePrefixExpr() throws -> PrefixExpr {
        guard let startToken = consume(), let op = startToken.asPrefixOperator
            else { throw unexpectedToken(expected: "prefix operator") }

        let operand = try parseExpression()
        return PrefixExpr(
            op: op, operand: operand,
            range: SourceRange(from: startToken.range.start, to: operand.range.end))
    }

    func parseArgument() throws -> Argument {
        // Parse the optional '&' operator for arguments passed by reference.
        let andToken = consume(.band)
        if andToken != nil {
            consumeNewlines()
        }

        // Parse the argument's value.
        let value = try parseExpression()
        let start = andToken?.range.start ?? value.range.start
        let arg = Argument(
            byReference: andToken != nil, value: value,
            range: SourceRange(from: start, to: value.range.end))
        return arg
    }

    func parseIdentifier() throws -> Identifier {
        guard let token = consume(.identifier)
            else { throw unexpectedToken(expected: "identifier") }
        return Identifier(name: token.value!, range: token.range)
    }

    func parseArrayLiteral() throws -> ArrayLiteral {
        guard let startToken = consume(.leftBracket)
            else { throw unexpectedToken(expected: "[") }
        let elements = try parseList(delimitedBy: .rightBracket, parsingItemsWith: parseExpression)
        guard let endToken = consume(.rightBracket)
            else { throw unexpectedToken(expected: "]") }

        return ArrayLiteral(
            elements: elements,
            range: SourceRange(from: startToken.range.start, to: endToken.range.end))
    }

    func parseObjectLiteral() throws -> ObjectLiteral {
        guard let startToken = consume(.leftBrace)
            else { throw unexpectedToken(expected: "{") }
        let elements = try parseList(
            delimitedBy: .rightBrace, parsingItemsWith: parseObjectLiteralElement)

        // Consume the delimiter of the list.
        guard let endToken = consume(.rightBrace)
            else { throw unexpectedToken(expected: "}") }

        return ObjectLiteral(
            elements: elements,
            range: SourceRange(from: startToken.range.start, to: endToken.range.end))
    }

    func parseObjectLiteralElement() throws -> (Node, Node) {
        let startkToken = consume()!

        // Parse the key of the element.
        let key: Node
        switch startkToken.kind {
        case .identifier, .string:
            key = ScalarLiteral(value: startkToken.value!, range: startkToken.range)
        case .leftBracket:
            key = try parseExpression()
            guard consume(.rightBracket) != nil
                else { throw unexpectedToken(expected: "]") }
        default:
            throw unexpectedToken(expected: "identifier")
        }

        // Parse the `:` symbol.
        guard consume(.colon, afterMany: .newline) != nil
            else { throw unexpectedToken(expected: ":") }

        // Parse the value it should maps to.
        consumeNewlines()
        let value = try parseExpression()
        return (key, value)
    }

}
