public extension ASTVisitor {

    // swiftlint:disable cyclomatic_complexity
    mutating func visit(_ node: Node) throws {
        switch node {
        case let n as Block:           try visit(n)
        case let n as VarDecl:         try visit(n)
        case let n as FunDecl:         try visit(n)
        case let n as GenDecl:         try visit(n)
        case let n as ArrowFun:        try visit(n)
        case let n as ParamDecl:       try visit(n)
        case let n as ClassDecl:       try visit(n)
        case let n as If:              try visit(n)
        case let n as Switch:          try visit(n)
        case let n as WhileLoop:       try visit(n)
        case let n as ForLoop:         try visit(n)
        case let n as Continue:        try visit(n)
        case let n as Break:           try visit(n)
        case let n as Return:          try visit(n)
        case let n as Yield:           try visit(n)
        case let n as PrefixExpr:      try visit(n)
        case let n as PostfixExpr:     try visit(n)
        case let n as InfixExpr:       try visit(n)
        case let n as TernaryExpr:     try visit(n)
        case let n as DotExpr:         try visit(n)
        case let n as CallExpr:        try visit(n)
        case let n as SubscriptExpr:   try visit(n)
        case let n as Argument:        try visit(n)
        case let n as Identifier:      try visit(n)
        case let n as ScalarLiteral:   try visit(n)
        case let n as ArrayLiteral:    try visit(n)
        case let n as ObjectLiteral:   try visit(n)
        default:
            assertionFailure("unexpected node during generic visit")
        }
    }
    // swiftlint:enable cyclomatic_complexity

    mutating func visit(_ nodes: [Node]) throws {
        for node in nodes {
            try visit(node)
        }
    }

    mutating func visit(_ node: Block) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: Block) throws {
        try visit(node.statements)
    }

    mutating func visit(_ node: VarDecl) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: VarDecl) throws {
        if let (_, value) = node.initialBinding {
            try visit(value)
        }
    }

    mutating func visit(_ node: FunDecl) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: FunDecl) throws {
        try visit(node.parameters)
        try visit(node.body)
    }

    mutating func visit(_ node: GenDecl) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: GenDecl) throws {
        try visit(node.parameters)
        try visit(node.body)
    }

    mutating func visit(_ node: ParamDecl) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: ParamDecl) throws {
        if let (_, value) = node.defaultValue {
            try visit(value)
        }
    }

    mutating func visit(_ node: ClassDecl) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: ClassDecl) throws {
        try visit(node.members)
    }

    mutating func visit(_ node: Assignment) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: Assignment) throws {
        try visit(node.lvalue)
        try visit(node.rvalue)
    }

    mutating func visit(_ node: If) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: If) throws {
        try visit(node.condition)
        try visit(node.thenBlock)
        if let elseBlock = node.elseBlock {
            try visit(elseBlock)
        }
    }

    mutating func visit(_ node: Switch) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: Switch) throws {
        try visit(node.value)
        try visit(node.cases)
    }

    mutating func visit(_ node: SwitchCase) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: SwitchCase) throws {
        try visit(node.value)
        try visit(node.body)
    }

    mutating func visit(_ node: WhileLoop) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: WhileLoop) throws {
        try visit(node.condition)
        try visit(node.body)
    }

    mutating func visit(_ node: ForLoop) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: ForLoop) throws {
        try visit(node.condition)
        try visit(node.body)
    }

    mutating func visit(_ node: Continue) throws {
    }

    mutating func visit(_ node: Break) throws {
    }

    mutating func visit(_ node: PrefixExpr) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: PrefixExpr) throws {
        try visit(node.operand)
    }

    mutating func visit(_ node: PostfixExpr) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: PostfixExpr) throws {
        try visit(node.operand)
    }

    mutating func visit(_ node: InfixExpr) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: InfixExpr) throws {
        try visit(node.left)
        try visit(node.right)
    }

    mutating func visit(_ node: TernaryExpr) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: TernaryExpr) throws {
        try visit(node.condition)
        try visit(node.thenValue)
        try visit(node.elseValue)
    }

    mutating func visit(_ node: DotExpr) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: DotExpr) throws {
        try visit(node.owner)
    }

    mutating func visit(_ node: CallExpr) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: CallExpr) throws {
        try visit(node.callee)
        try visit(node.arguments)
    }

    mutating func visit(_ node: SubscriptExpr) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: SubscriptExpr) throws {
        try visit(node.callee)
        try visit(node.index)
    }

    mutating func visit(_ node: Identifier) throws {
    }

    mutating func visit(_ node: ScalarLiteral) throws {
    }

    mutating func visit(_ node: ArrayLiteral) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: ArrayLiteral) throws {
        try visit(node.elements)
    }

    mutating func visit(_ node: ObjectLiteral) throws {
        try traverse(node)
    }

    mutating func traverse(_ node: ObjectLiteral) throws {
        for (key, value) in node.elements {
            try visit(key)
            try visit(value)
        }
    }

}
