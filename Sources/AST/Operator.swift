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

    /// Returns the precedence group of the operator.
    public var precedence: Int {
        switch self {
        case .or                        : return 0
        case .and                       : return 1
        case .bor                       : return 2
        case .bxor                      : return 3
        case .band                      : return 4
        case .eq, .ne, .seq, .sne       : return 5
        case .contains, .instanceof     : return 6
        case .lt, .le, .ge, .gt         : return 7
        case .lshift, .rshift, .urshift : return 8
        case .add, .sub                 : return 9
        case .mul, .div, .mod           : return 10
        case .pow                       : return 11
        }
    }

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

