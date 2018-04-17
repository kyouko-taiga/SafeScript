public protocol ASTVisitor {

    mutating func visit(_ node: Block)           throws
    mutating func visit(_ node: VarDecl)         throws
    mutating func visit(_ node: FunDecl)         throws
    mutating func visit(_ node: GenDecl)         throws
    mutating func visit(_ node: ArrowFun)        throws
    mutating func visit(_ node: ParamDecl)       throws
    mutating func visit(_ node: ClassDecl)       throws
    mutating func visit(_ node: Assignment)      throws
    mutating func visit(_ node: If)              throws
    mutating func visit(_ node: Switch)          throws
    mutating func visit(_ node: SwitchCase)      throws
    mutating func visit(_ node: WhileLoop)       throws
    mutating func visit(_ node: ForLoop)         throws
    mutating func visit(_ node: Continue)        throws
    mutating func visit(_ node: Break)           throws
    mutating func visit(_ node: Return)          throws
    mutating func visit(_ node: Yield)           throws
    mutating func visit(_ node: PrefixExpr)      throws
    mutating func visit(_ node: PostfixExpr)     throws
    mutating func visit(_ node: InfixExpr)       throws
    mutating func visit(_ node: TernaryExpr)     throws
    mutating func visit(_ node: DotExpr)         throws
    mutating func visit(_ node: CallExpr)        throws
    mutating func visit(_ node: SubscriptExpr)   throws
    mutating func visit(_ node: Argument)        throws
    mutating func visit(_ node: Identifier)      throws
    mutating func visit(_ node: ScalarLiteral)   throws
    mutating func visit(_ node: ArrayLiteral)    throws
    mutating func visit(_ node: ObjectLiteral)   throws

}
