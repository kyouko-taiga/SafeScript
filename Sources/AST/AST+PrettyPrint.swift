public protocol PrettyPrintable {

    var prettyDescription: String { get }

}

extension Block {

    public var prettyDescription: String {
        var result = "{\n"
        for stmt in statements {
            result += stmt.prettyDescription
                .split(separator: "\n")
                .map({ "  " + $0 })
                .joined(separator: "\n") + "\n"
        }
        return result + "}"
    }

}

extension VarDecl {

    public var prettyDescription: String {
        var result = attributes.isEmpty
            ? ""
            : attributes.map({ $0.rawValue }).joined(separator: " ") + " "
        result += reassignable
            ? "let "
            : "const "
        result += "\(name): \(mutability.rawValue)"
        if let (op, val) = initialBinding {
            result += " \(op) \(val.prettyDescription)"
        }
        return result
    }

}

extension FunDecl {

    public var prettyDescription: String {
        var result = attributes.isEmpty
            ? ""
            : attributes.map({ $0.rawValue }).joined(separator: " ") + " "
        if asynchronous {
            result += "async "
        }
        result += "function \(name)"
        result += "("
        result += parameters.map({ $0.prettyDescription }).joined(separator: ", ")
        result += "): \(returnMutability.rawValue) "
        result += body.prettyDescription
        return result
    }

}

extension GenDecl {

    public var prettyDescription: String {
        var result = attributes.isEmpty
            ? ""
            : attributes.map({ $0.rawValue }).joined(separator: " ") + " "
        if asynchronous {
            result += "async "
        }
        result += "function* \(name)"
        result += "("
        result += parameters.map({ $0.prettyDescription }).joined(separator: ", ")
        result += ")"
        if let annotation = returnAnnotation {
            result += ": \(annotation.prettyDescription)"
        }
        result += " \(body.prettyDescription)"
        return result
    }

}

extension ArrowFun {

    public var prettyDescription: String {
        var result = "("
        result += parameters.map({ $0.prettyDescription }).joined(separator: ", ")
        result += ")"
        if let annotation = returnAnnotation {
            result += ": \(annotation.prettyDescription)"
        }
        result += " \(body.prettyDescription)"
        return result
    }

}

extension ParamDecl {

    public var prettyDescription: String {
        var result = "\(name): \(mutability.rawValue)"
        if let (op, val) = defaultValue {
            result += " \(op) \(val.prettyDescription)"
        }
        return result
    }

}

extension ClassDecl {

    public var prettyDescription: String {
        var result = "class \(name) {\n"
        for member in members {
            result += member.prettyDescription
                .split(separator: "\n")
                .map({ "  " + $0 })
                .joined(separator: "\n") + "\n"
        }
        return result + "}"
    }

}

extension Assignment {

    public var prettyDescription: String {
        return "\(lvalue.prettyDescription) \(op) \(rvalue.prettyDescription)"
    }

}

extension If {

    public var prettyDescription: String {
        var result = "if \(condition.prettyDescription) \(thenBlock.prettyDescription)"
        if let elseBlock = elseBlock {
            result += " else \(elseBlock.prettyDescription)"
        }
        return result
    }

}

extension Switch {

    public var prettyDescription: String {
        var result = "switch \(value.prettyDescription) {\n"
        for case_ in cases {
            result += case_.prettyDescription
                .split(separator: "\n")
                .map({ "  " + $0 })
                .joined(separator: "\n") + "\n"
        }
        return result + "}"
    }

}

extension SwitchCase {

    public var prettyDescription: String {
        return "case \(value.prettyDescription): \(body.prettyDescription)"
    }

}

extension WhileLoop {

    public var prettyDescription: String {
        return "while \(condition.prettyDescription) \(body.prettyDescription)"
    }

}

extension ForLoop {

    public var prettyDescription: String {
        return "while \(condition.prettyDescription) \(body.prettyDescription)"
    }

}

extension Continue {

    public var prettyDescription: String {
        return "continue"
    }

}

extension Break {

    public var prettyDescription: String {
        return "break"
    }

}

extension Return {

    public var prettyDescription: String {
        if let value = self.value {
            return "return \(value.prettyDescription)"
        } else {
            return "return"
        }
    }

}

extension Yield {

    public var prettyDescription: String {
        if let value = self.value {
            return "yield \(value.prettyDescription)"
        } else {
            return "yield"
        }
    }

}

extension PrefixExpr {

    public var prettyDescription: String {
        return "\(op) \(operand.prettyDescription)"
    }

}

extension PostfixExpr {

    public var prettyDescription: String {
        return "\(operand.prettyDescription) \(op)"
    }

}

extension InfixExpr {

    public var prettyDescription: String {
        return "(\(left.prettyDescription) \(op) \(right.prettyDescription))"
    }

}

extension TernaryExpr {

    public var prettyDescription: String {
        let thenLines = thenValue.prettyDescription.split(separator: "\n")
        var thenDescription = thenLines.first!
        if thenLines.count > 1 {
            thenDescription += "\n" + thenLines
                .dropFirst()
                .map({ "  \($0)" })
                .joined(separator: "\n")
        }

        let elseLines = elseValue.prettyDescription.split(separator: "\n")
        var elseDescription = elseLines.first!
        if elseLines.count > 1 {
            elseDescription += "\n" + elseLines
                .dropFirst()
                .map({ "  \($0)" })
                .joined(separator: "\n")
        }

        return "\(condition.prettyDescription)\n" +
            "  ? \(thenDescription)\n" +
            "  : \(elseDescription)"
    }

}

extension DotExpr {

    public var prettyDescription: String {
        return "\(owner.prettyDescription).\(attribute)"
    }

}

extension CallExpr {

    public var prettyDescription: String {
        let args = arguments.map({ $0.prettyDescription }).joined(separator: ", ")
        return "\(callee.prettyDescription)(\(args))"
    }

}

extension SubscriptExpr {

    public var prettyDescription: String {
        return "\(callee.prettyDescription)[\(index.prettyDescription)]"
    }

}

extension Argument {

    public var prettyDescription: String {
        return byReference
            ? "&\(value.prettyDescription)"
            : value.prettyDescription
    }

}

extension Identifier {

    public var prettyDescription: String {
        return name
    }

}

extension ScalarLiteral {

    public var prettyDescription: String {
        if let string = value as? String {
            return "'\(string)'"
        } else {
            return "\(value)"
        }
    }

}

extension ArrayLiteral {

    public var prettyDescription: String {
        return "[ " + elements.map({ $0.prettyDescription }).joined(separator: ", ") + " ]"
    }

}

extension ObjectLiteral {

    public var prettyDescription: String {
        let entries = elements.map({ (arg) -> String in
            let (key, value) = arg
            return key is ScalarLiteral
                ? "\(key.prettyDescription): \(value.prettyDescription)"
                : "[ \(key.prettyDescription) ]: \(value.prettyDescription)"
        })
        return "{ " + entries.joined(separator: ", ") + " }"
    }

}
