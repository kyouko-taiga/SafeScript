import AST
import Utils

public struct Transpiler: ASTVisitor {

    public init(output: File) throws {
        self.output = output

        // Add the `deepcopy` function in preamble.
        self.output.write(data: deepcopy)
        self.output.write(data: "\n")
    }

    public mutating func visit(_ node: Block) throws {
        dump("{")
        for stmt in node.statements {
            try visit(stmt)
            if stmt is CallExpr { dump(";") }
        }
        dump("}")
    }

    public mutating func visit(_ node: VarDecl) throws {
        dump(node.reassignable ? "let " : "const ")
        dump(node.name)
        if let (op, val) = node.initialBinding {
            dump(op == .copy ? " = __ssdeepcopy(" : " = (")
            try visit(val)
            dump(")")
        }
        dump(";")
    }

    public mutating func visit(_ node: FunDecl) throws {
        if node.asynchronous {
            dump("async ")
        }
        dump("function \(node.name)(")
        for i in 0 ..< node.parameters.count {
            try visit(node.parameters[i])
            if i < (node.parameters.count - 1) {
                dump(",")
            }
        }
        dump(")")
        try visit(node.body)
    }

    public mutating func visit(_ node: GenDecl) throws {
        fatalError("not implemented")
    }

    public mutating func visit(_ node: ArrowFun) throws {
        fatalError("not implemented")
    }

    public mutating func visit(_ node: ParamDecl) throws {
        dump(node.name)
        if let (op, val) = node.defaultValue {
            dump(op == .copy ? " = __ssdeepcopy(" : " = (")
            try visit(val)
            dump(")")
        }
    }

    public mutating func visit(_ node: ClassDecl) throws {
        dump("class \(node.name){")
        try visit(node.members)
        dump("}")
    }

    public mutating func visit(_ node: Assignment) throws {
        try visit(node.lvalue)
        dump(node.op == .copy ? " = __ssdeepcopy(" : " = (")
        try visit(node.rvalue)
        dump(");")
    }

    public mutating func visit(_ node: If) throws {
        dump("if (")
        try visit(node.condition)
        dump(") {")
        try visit(node.thenBlock)
        dump("}")
        if let elseBlock = node.elseBlock {
            dump(" else {")
            try visit(elseBlock)
            dump("}")
        }
    }

    public mutating func visit(_ node: Switch) throws {
        fatalError("not implemented")
    }

    public mutating func visit(_ node: SwitchCase) throws {
        fatalError("not implemented")
    }

    public mutating func visit(_ node: WhileLoop) throws {
        fatalError("not implemented")
    }

    public mutating func visit(_ node: ForLoop) throws {
        fatalError("not implemented")
    }

    public mutating func visit(_ node: Continue) throws {
        dump("continue;")
    }

    public mutating func visit(_ node: Break) throws {
        dump("break;")
    }

    public mutating func visit(_ node: Return) throws {
        dump("return ")
        if let value = node.value {
            try visit(value)
        }
        dump(";")
    }

    public mutating func visit(_ node: Yield) throws {
        dump("yield ")
        if let value = node.value {
            try visit(value)
        }
        dump(";")
    }

    public mutating func visit(_ node: PrefixExpr) throws {
        dump(node.op.description)
        try visit(node.operand)
    }

    public mutating func visit(_ node: PostfixExpr) throws {
        try visit(node.operand)
        dump(node.op.description)
    }

    public mutating func visit(_ node: InfixExpr) throws {
        try visit(node.left)
        dump(node.op.description)
        try visit(node.right)
    }

    public mutating func visit(_ node: TernaryExpr) throws {
        try visit(node.condition)
        dump("?")
        try visit(node.thenValue)
        dump(":")
        try visit(node.elseValue)
    }

    public mutating func visit(_ node: DotExpr) throws {
        try visit(node.owner)
        dump(".\(node.attribute)")
    }

    public mutating func visit(_ node: CallExpr) throws {
        try visit(node.callee)
        dump("(")
        for i in 0 ..< node.arguments.count {
            try visit(node.arguments[i])
            if i < (node.arguments.count - 1) {
                dump(",")
            }
        }
        dump(")")
    }

    public mutating func visit(_ node: Argument) throws {
        try visit(node.value)
    }

    public mutating func visit(_ node: SubscriptExpr) throws {
        try visit(node.callee)
        dump("[")
        try visit(node.index)
        dump("]")
    }

    public mutating func visit(_ node: Identifier) throws {
        dump(node.name)
    }

    public mutating func visit(_ node: ScalarLiteral) throws {
        if let string = node.value as? String {
            dump("\"\(string)\"")
        } else {
            dump(String(describing: node.value))
        }
    }

    public mutating func visit(_ node: ArrayLiteral) throws {
        dump("[")
        for i in 0 ..< node.elements.count {
            try visit(node.elements[i])
            if i < (node.elements.count - 1) {
                dump(",")
            }
        }
        dump("]")
    }

    public mutating func visit(_ node: ObjectLiteral) throws {
        dump("{")
        for i in 0 ..< node.elements.count {
            if !((node.elements[i].0 is Identifier) || (node.elements[i].0 is ScalarLiteral)) {
                dump("[")
                try visit(node.elements[i].0)
                dump("]")
            } else {
                try visit(node.elements[i].0)
            }
            dump(":")
            try visit(node.elements[i].1)
            if i < (node.elements.count - 1) {
                dump(",")
            }
        }
        dump("}")
    }

    private func dump(_ text: String) {
        output.write(data: text)
    }

    private let output: File

}
