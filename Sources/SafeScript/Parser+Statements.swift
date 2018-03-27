extension Parser {

    func parseStatement() throws -> Node {
        switch peek().kind {
        case .let, .const:
            return try parseVarDecl()

        default:
            throw unexpectedToken(expected: "statement or expression")
        }
    }

    func parseVarDecl() throws -> Node {
        guard let startToken = consume(if: { $0.kind == .let || $0.kind == .const })
            else { throw unexpectedToken(expected: "'let' or 'const'") }

        // Parse the name of the property.
        guard let name = consume(.identifier, afterMany: .newline)
            else { throw parseFailure(.expectedIdentifier) }
        var endLocation = name.range.end

        // Parse the optional mutability qualifier.
        var qualifier: MutabilityQualifer? = nil
        if consume(.colon, afterMany: .newline) != nil {
            guard let q = consume(if: { $0.kind == .mutable || $0.kind == .const })
                else { throw unexpectedToken(expected: "mutability qualifier") }
            qualifier = MutabilityQualifer(rawValue: q.kind.rawValue)
            endLocation = q.range.end
        }

        // Parse the optional initial binding value.
        var initialBinding: (op: BindingOperator, value: Node)? = nil
        let backtrackPosition = streamPosition
        consumeNewlines()
        if let op = consume()?.asBindingOperator {
            consumeNewlines()
            let value = try parseExpression()
            initialBinding = (op, value)
            endLocation = value.range.end
        } else {
            rewind(to: backtrackPosition)
        }

        return VarDecl(
            name: name.value!,
            attributes: [],
            reassignable: startToken.kind == .let,
            mutability: qualifier ?? .const,
            initialBinding: initialBinding,
            range: SourceRange(from: startToken.range.start, to: endLocation))
    }

}
