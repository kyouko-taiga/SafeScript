import AST

extension Parser {

    func parseStatement() throws -> Node {
        switch peek().kind {
        case .continue:
            let token = consume()
            return Continue(range: token!.range)
        case .break:
            let token = consume()
            return Break(range: token!.range)

        case .return:
            return try parseReturn()
        case .yield:
            return try parseYield()
        case .let, .const:
            return try parseVarDecl()
        case .function:
            return try parseFunDecl()

        default:
            // Attempt to parse a binding statement before falling back to an expression.
            if let binding = attempt(parseBindingStmt) { return binding }
            return try parseExpression()
        }
    }

    func parseVarDecl() throws -> VarDecl {
        guard let startToken = consume(if: { $0.kind == .let || $0.kind == .const })
            else { throw unexpectedToken(expected: "'let' or 'const'") }

        // Parse the name of the property.
        guard let name = consume(.identifier, afterMany: .newline)
            else { throw parseFailure(.expectedIdentifier) }
        var end = name.range.end

        // Parse the optional mutability qualifier.
        var qualifier: MutabilityQualifer? = nil
        if consume(.colon, afterMany: .newline) != nil {
            guard let q = consume(if: { $0.kind == .mutable || $0.kind == .const })
                else { throw unexpectedToken(expected: "mutability qualifier") }
            qualifier = MutabilityQualifer(rawValue: q.kind.rawValue)
            end = q.range.end
        }

        // Parse the optional initial binding value.
        var initialBinding: (op: BindingOperator, value: Node)? = nil
        let backtrackPosition = streamPosition
        consumeNewlines()
        if let op = consume()?.asBindingOperator {
            consumeNewlines()
            let value = try parseExpression()
            initialBinding = (op, value)
            end = value.range.end
        } else {
            rewind(to: backtrackPosition)
        }

        return VarDecl(
            name: name.value!,
            attributes: [],
            reassignable: startToken.kind == .let,
            mutability: qualifier ?? .const,
            initialBinding: initialBinding,
            range: SourceRange(from: startToken.range.start, to: end))
    }

    func parseFunDecl() throws -> FunDecl {
        guard let startToken = consume(.function)
            else { throw unexpectedToken(expected: "function") }

        // Parse the name of the function.
        guard let name = consume(.identifier, afterMany: .newline)?.value
            else { throw parseFailure(.expectedIdentifier) }

        // Parse the parameter list.
        guard consume(.leftParen, afterMany: .newline) != nil
            else { throw unexpectedToken(expected: "(") }
        let parameters = try parseList(delimitedBy: .rightParen, parsingItemsWith: parseParamDecl)
        guard consume(.rightParen) != nil
            else { throw unexpectedToken(expected: ")") }

        // Parse the optional return annotation.
        var qualifier: MutabilityQualifer = .const
        if consume(.colon, afterMany: .newline) != nil {
            guard let q = consume(if: { $0.kind == .mutable || $0.kind == .const })
                else { throw unexpectedToken(expected: "mutability qualifier") }
            qualifier = MutabilityQualifer(rawValue: q.kind.rawValue)!
        }

        // Parse the function body.
        consumeNewlines()
        let body = try parseStatementBlock()

        return FunDecl(
            name: name, attributes: [], asynchronous: false,
            parameters: parameters,
            returnMutability: qualifier,
            body: body,
            range: SourceRange(from: startToken.range.start, to: body.range.end))
    }

    func parseParamDecl() throws -> ParamDecl {
        // Parse the parameter name.
        guard let name = consume(.identifier)
            else { throw parseFailure(.expectedIdentifier) }
        var end = name.range.end

        // Parse the optional type annotation.
        var qualifier: MutabilityQualifer = .const
        if consume(.colon, afterMany: .newline) != nil {
            guard let q = consume(if: { $0.kind == .mutable || $0.kind == .const })
                else { throw unexpectedToken(expected: "mutability qualifier") }
            qualifier = MutabilityQualifer(rawValue: q.kind.rawValue)!
            end = q.range.end
        }

        // Parse the optional initial binding value.
        var initialBinding: (op: BindingOperator, value: Node)? = nil
        let backtrackPosition = streamPosition
        consumeNewlines()
        if let op = consume()?.asBindingOperator {
            consumeNewlines()
            let value = try parseExpression()
            initialBinding = (op, value)
            end = value.range.end
        } else {
            rewind(to: backtrackPosition)
        }

        return ParamDecl(
            name: name.value!,
            mutability: qualifier,
            defaultValue: initialBinding,
            range: SourceRange(from: name.range.start, to: end))
    }

    func parseReturn() throws -> Return {
        guard let startToken = consume(.return)
            else { throw unexpectedToken(expected: "return") }

        // Parse an optional return value.
        if let value = attempt(parseExpression) {
            return Return(
                value: value,
                range: SourceRange(from: startToken.range.start, to: value.range.end))
        }
        return Return(range: startToken.range)
    }

    func parseYield() throws -> Yield {
        guard let startToken = consume(.return)
            else { throw unexpectedToken(expected: "return") }

        // Parse an optional yield value.
        if let value = attempt(parseExpression) {
            return Yield(
                value: value,
                range: SourceRange(from: startToken.range.start, to: value.range.end))
        }
        return Yield(range: startToken.range)
    }

    func parseBindingStmt() throws -> Assignment {
        // Parse the left operand.
        let left = try parseExpression()

        // Parse the binding operator.
        consumeNewlines()
        guard let op = peek().asBindingOperator
            else { throw unexpectedToken(expected: "binding operator") }
        consume()

        // Parse the right operand.
        consumeNewlines()
        let right = try parseExpression()
        return Assignment(
            lvalue: left, op: op, rvalue: right,
            range: SourceRange(from: left.range.start, to: right.range.end))
    }

    func parseStatementBlock() throws -> Block {
        guard let startToken = consume(.leftBrace)
            else { throw unexpectedToken(expected: "{") }

        // Skip trailing new lines.
        consumeNewlines()

        // Parse as many statements as possible
        var statements: [Node] = []
        while peek().kind != .rightBrace {
            statements.append(try parseStatement())

            // Skip leading new lines.
            consumeNewlines()

            // If the next token isn't the block delimiter, we MUST parse a statement delimiter.
            if peek().kind != .rightBrace {
                guard peek().isStatementDelimiter
                    else { throw parseFailure(.expectedStatementDelimiter) }
                consume()
            }
        }

        let endToken = consume(.rightBrace)!
        return Block(
            statements: statements,
            range: SourceRange(from: startToken.range.start, to: endToken.range.end))
    }

}
