extension Parser {

    /// Returns the token 1 position ahead, without consuming the stream.
    func peek() -> Token {
        assert((streamPosition) < stream.count)
        return stream[streamPosition]
    }

    /// Attempts to consume a single token.
    @discardableResult
    func consume() -> Token? {
        guard streamPosition < stream.count
            else { return nil }
        defer { streamPosition += 1 }
        return stream[streamPosition]
    }

    /// Attempts to consume a single token of the given kind from the stream.
    @discardableResult
    func consume(_ kind: TokenKind) -> Token? {
        guard (streamPosition < stream.count) && (stream[streamPosition].kind == kind)
            else { return nil }
        defer { streamPosition += 1 }
        return stream[streamPosition]
    }

    /// Attempts to consume a single token of the given kind, after a sequence of tokens of the
    /// given kind.
    @discardableResult
    func consume(_ kind: TokenKind, afterMany skipKind: TokenKind) -> Token? {
        let backtrackPosition = streamPosition
        consumeMany { $0.kind == skipKind }
        if let result = consume(kind) {
            return result
        }
        rewind(to: backtrackPosition)
        return nil
    }

    /// Attemps to consume a single token, if it satisfies the given predicate.
    @discardableResult
    func consume(if predicate: (Token) throws -> Bool) rethrows -> Token? {
        guard try (streamPosition < stream.count) && predicate(stream[streamPosition])
            else { return nil }
        defer { streamPosition += 1 }
        return stream[streamPosition]
    }

    /// Consumes up to the given number of elements from the stream.
    @discardableResult
    func consumeMany(upTo n: Int = 1) -> ArraySlice<Token> {
        let consumed = stream[streamPosition ..< streamPosition + n]
        streamPosition += consumed.count
        return consumed
    }

    /// Consumes tokens from the stream as long as they satisfy the given predicate.
    @discardableResult
    func consumeMany(while predicate: (Token) throws -> Bool) rethrows -> ArraySlice<Token> {
        let consumed: ArraySlice = try stream[streamPosition...].prefix(while: predicate)
        streamPosition += consumed.count
        return consumed
    }

    /// Consume new lines.
    func consumeNewlines() {
        for token in stream[streamPosition...] {
            guard token.kind == .newline else { break }
            streamPosition += 1
        }
    }

    /// Rewinds the token stream by the given number of positions.
    func rewind(_ n: Int = 1) {
        streamPosition = Swift.max(streamPosition - 1, 0)
    }

    /// Rewinds the stream to the specified position.
    func rewind(to position: Int) {
        streamPosition = position
    }

}
