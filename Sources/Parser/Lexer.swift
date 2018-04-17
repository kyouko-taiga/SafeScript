import Foundation
import AST

/// Lexer for the tokens of the Anzen language.
public struct Lexer {

    public init(string: String) {
        currentLocation = SourceLocation()
        characters = string.unicodeScalars
        charIndex = characters.startIndex
    }

    public init(path: String) throws {
        let string = try String.init(contentsOfFile: path)
        self.init(string: string)
    }

    /// Take the given number of characters from the stream, advancing the lexer.
    mutating func take(_ n: Int = 1) -> String.UnicodeScalarView.SubSequence {
        let startIndex = charIndex
        for _ in 0 ..< n {
            guard let c = currentChar
                else { return characters[startIndex ... charIndex] }
            if c == "\n" {
                currentLocation.line += 1
                currentLocation.column = 1
            } else {
                currentLocation.column += 1
            }
            currentLocation.offset += 1
            charIndex = characters.index(after: charIndex)
        }
        return characters[startIndex ... charIndex]
    }

    /// Take a characters from the stream as long as the predicate holds, advancing the lexer.
    mutating func take(while predicate: (UnicodeScalar) -> Bool) -> String.UnicodeScalarView.SubSequence {
        let startIndex = charIndex
        while let c = currentChar, predicate(c) {
            _ = take()
        }
        return characters[startIndex ..< charIndex]
    }

    /// Skip the given number of characters in the stream.
    mutating func skip(_ n: Int = 1) {
        _ = take(n)
    }

    /// Skip the characters of the stream while the given predicate holds.
    mutating func skip(while predicate: (UnicodeScalar) -> Bool) {
        while let c = currentChar, predicate(c) {
            skip()
        }
    }

    /// Retrieves the i-th character of the stream.
    func char(at index: Int) -> UnicodeScalar? {
        let forwardIndex = characters.index(charIndex, offsetBy: index)
        return forwardIndex < characters.endIndex
            ? characters[forwardIndex]
            : nil
    }

    /// Returns a source range from the given location to the lexer's current location.
    func range(from start: SourceLocation) -> SourceRange {
        return SourceRange(from: start, to: currentLocation)
    }

    /// The current character in the stream.
    var currentChar: UnicodeScalar? {
        return charIndex < characters.endIndex
            ? characters[charIndex]
            : nil
    }

    /// The stream of characters.
    var characters: String.UnicodeScalarView
    /// The current character index in the stream.
    var charIndex: String.UnicodeScalarView.Index

    /// The current source location of the lexer.
    var currentLocation: SourceLocation

    /// Whether or not the stream has been depleted.
    var depleted = false

}

extension Lexer: IteratorProtocol, Sequence {

    /// Returns the next token.
    public mutating func next() -> Token? {
        guard !depleted else { return nil }

        // Ignore whitespaces.
        skip(while: isWhitespace)

        // Check for the end of file.
        guard let c = currentChar else {
            defer { depleted = true }
            return Token(kind: .eof, range: SourceRange(at: currentLocation))
        }

        // Check for statement delimiters.
        if c == "\n" {
            defer { skip(while: { isWhitespace($0) || isStatementDelimiter($0) }) }
            return Token(kind: .newline, range: SourceRange(at: currentLocation))
        }
        if c == ";" {
            defer { skip(while: { isWhitespace($0) || isStatementDelimiter($0) }) }
            return Token(kind: .semicolon, range: SourceRange(at: currentLocation))
        }

        let startLocation = currentLocation

        // Skip comments.
        if c == "/" {
            let nextChar = char(at: 1)

            // We found a line comment.
            if nextChar == "/" {
                skip(while: { $0 != "\n" })
                return self.next()
            }

            // We found a block comment.
            if nextChar == "*" {
                skip(2)
                while currentChar != "*" || char(at: 1) != "/" {
                    // Make sure the stream isn't depleted.
                    guard charIndex < characters.endIndex else {
                        depleted = true
                        skip(while: { _ in true })
                        return Token(kind: .unterminatedBlockComment, range: range(from: startLocation))
                    }
                    skip()
                }
                skip(2)
                return self.next()
            }
        }

        // Check for number literals.
        if isDigit(c) {
            let number = take(while: isDigit)

            // Check for double literals.
            var value = String(number)
            if currentChar == "." && (char(at: 1).map(isDigit) ?? false) {
                skip()
                let fraction = take(while: isDigit)
                value += "." + String(fraction)
            }

            return Token(kind: .number, value: value, range: range(from: startLocation))
        }

        // Check for identifiers.
        if isAlnumOrUnderscore(c) {
            let chars = String(take(while: isAlnumOrUnderscore))
            let kind: TokenKind
            var value: String? = nil

            // Check for keywords and operators.
            switch chars {
            case "true"       : kind = .bool; value = "true"
            case "false"      : kind = .bool; value = "false"
            case "in"         : kind = .in
            case "instanceof" : kind = .instanceof
            case "typeof"     : kind = .typeof
            case "void"       : kind = .void
            case "delete"     : kind = .delete
            case "await"      : kind = .await
            case "let"        : kind = .let
            case "const"      : kind = .const
            case "mutable"    : kind = .mutable
            case "async"      : kind = .async
            case "function"   : kind = .function
            case "static"     : kind = .static
            case "class"      : kind = .class
            case "new"        : kind = .new
            case "while"      : kind = .while
            case "for"        : kind = .for
            case "break"      : kind = .break // swiftlint:disable:this unneeded_break_in_switch
            case "continue"   : kind = .continue
            case "return"     : kind = .return
            case "yield"      : kind = .yield
            case "if"         : kind = .if
            case "else"       : kind = .else
            case "switch"     : kind = .switch
            case "case"       : kind = .case
            default           : kind = .identifier; value = chars
            }

            return Token(kind: kind, value: value, range: range(from: startLocation))
        }

        // Check for string literals.
        if c == "\"" || c == "'" {
            skip()

            let startIndex = charIndex
            while currentChar != c {
                // Make sure the stream isn't depleted.
                guard charIndex < characters.endIndex else {
                    depleted = true
                    skip(while: { _ in true })
                    return Token(kind: .unterminatedStringLiteral, range: range(from: startLocation))
                }
                skip()

                // Skip escaped end quotes.
                if (currentChar == "\\") && (char(at: 1) == "\"") {
                    skip(2)
                }
            }

            let value = String(characters[startIndex ..< charIndex])
            skip()
            return Token(kind: .string, value: value, range: range(from: startLocation))
        }

        // Check for operators.
        if operatorChars.contains(c) {
            // Check for operators made of a 3 characters.
            if let c1 = char(at: 1), let c2 = char(at: 2) {
                let value = String(c) + String(c1) + String(c2)
                var kind: TokenKind? = nil

                switch value {
                case ">>>": kind = .urshift
                case "===": kind = .seq
                case "!==": kind = .sne
                case "...": kind = .ellipsis
                default  : break
                }

                if kind != nil {
                    skip(3)
                    return Token(kind: kind!, range: range(from: startLocation))
                }
            }

            // Check for operators made of 2 characters.
            if let c1 = char(at: 1) {
                let value = String(c) + String(c1)
                var kind: TokenKind? = nil

                switch value {
                case "&-": kind = .borrow
                case "=>": kind = .arrow
                case "<=": kind = .le
                case ">=": kind = .ge
                case "==": kind = .eq
                case "!=": kind = .ne
                case ">>": kind = .rshift
                case "<<": kind = .lshift
                case "**": kind = .pow
                case "&&": kind = .and
                case "||": kind = .or
                case "++": kind = .inc
                case "--": kind = .dec
                default  : break
                }

                if kind != nil {
                    skip(2)
                    return Token(kind: kind!, range: range(from: startLocation))
                }
            }

            // Check for operators made of a single character.
            var value: String? = nil
            let kind: TokenKind

            switch c {
            case ".": kind = .dot
            case ",": kind = .comma
            case ":": kind = .colon
            case "?": kind = .questionMark
            case "(": kind = .leftParen
            case ")": kind = .rightParen
            case "{": kind = .leftBrace
            case "}": kind = .rightBrace
            case "[": kind = .leftBracket
            case "]": kind = .rightBracket
            case "=": kind = .copy
            case "<": kind = .lt
            case ">": kind = .gt
            case "+": kind = .add
            case "-": kind = .sub
            case "*": kind = .mul
            case "/": kind = .div
            case "%": kind = .mod
            case "!": kind = .not
            case "~": kind = .invert
            case "&": kind = .band
            case "^": kind = .bxor
            case "|": kind = .bor
            default : kind = .unknown; value = String(c)
            }

            skip()
            return Token(kind: kind, value: value, range: range(from: startLocation))
        }

        skip()
        return Token(kind: .unknown, value: String(c), range: range(from: startLocation))
    }

}

/// Returns whether or not the given character is a whitespace.
func isWhitespace(_ char: UnicodeScalar) -> Bool {
    return char == " " || char == "\t"
}

/// Returns whether or not the given character is a statement delimiter.
func isStatementDelimiter(_ char: UnicodeScalar) -> Bool {
    return char == "\n" || char == ";"
}

/// Returns whether or not the given charater is a digit.
func isDigit(_ char: UnicodeScalar) -> Bool {
    return CharacterSet.decimalDigits.contains(char)
}

/// Returns whetehr or not the given character is an alphanumeric characters, or `_`.
func isAlnumOrUnderscore(_ char: UnicodeScalar) -> Bool {
    return char == "_" || CharacterSet.alphanumerics.contains(char)
}

/// Set of operator symbols.
let operatorChars = Set<UnicodeScalar>(".,:!?(){}[]<>-*/%+-=&".unicodeScalars)
