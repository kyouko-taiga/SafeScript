/// Enumeration of the prefix operators.
public enum PrefixOperator: String, CustomStringConvertible {

    case not        = "!"
    case invert     = "~"
    case sub        = "-"
    case add        = "+"
    case inc        = "++"
    case dec        = "--"
    case typeof
    case void
    case delete
    case await

    public var description: String { return rawValue }

}

/// Enumeration of the infix operators.
public enum InfixOperator: String, CustomStringConvertible {

    // MARK: Exponent precedence

    case pow        = "**"

    // MARK: Multiplication precedence

    case mul        = "*"
    case div        = "/"
    case mod        = "%"

    // MARK: Addition precedence

    case add        = "+"
    case sub        = "-"

    // MARK: Shift precedence

    case lshift     = "<<"
    case rshift     = ">>"
    case urshift    = ">>>"

    // MARK: Comparison precedence

    case lt         = "<"
    case le         = "<="
    case ge         = "=>"
    case gt         = ">"

    // MARK: Containment precedence

    case contains   = "in"
    case instanceof = "instanceof"

    // MARK: Equivalence precedence

    case eq         = "=="
    case ne         = "!="
    case seq        = "==="
    case sne        = "!=="

    // MARK: Bitwise conjunction precedence

    case band       = "&"

    // MARK: Bitwise exclusive disjunction precedence

    case bxor       = "^"

    // MARK: Bitwise disjunction precedence

    case bor        = "|"

    // MARK: Logical conjunction precedence

    case and        = "&&"

    // MARK: Logical disjunction precedence

    case or         = "||"

    public var description: String { return rawValue }

}

/// Enumeration of the postfix operators.
public enum PostfixOperator: String, CustomStringConvertible {

    case inc        = "++"
    case dec        = "--"

    public var description: String { return rawValue }

}

/// Enumeration of the binding operators.
public enum BindingOperator: String, CustomStringConvertible {

    case copy       = "="
    case borrow     = "&-"

    public var description: String { return rawValue }

}

