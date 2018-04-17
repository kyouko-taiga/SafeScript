/// Common interface for all AST nodes.
public protocol Node: PrettyPrintable {

    /// The range in the source file of the concrete syntax this node represents.
    var range: SourceRange { get set }

}

/// Common interface for nodes associated with a name.
public protocol NamedNode: Node {

    /// The name of symbol this node is associated with.
    var name: String { get }

}

/// Enumeration of the mutability qualifiers.
public enum MutabilityQualifer: String {

    case mutable
    case const

}

/// Enumeration of the member attributes.
public enum MemberAttribute: String {

    case mutable
    case `static`

}

/// Anonymous block.
public class Block: Node {

    public init(statements: [Node], range: SourceRange) {
        self.statements = statements
        self.range = range
    }

    /// The statements of the block.
    public var statements: [Node]
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A variable declaration.
public class VarDecl: NamedNode {

    public init(
        name: String,
        attributes: Set<MemberAttribute>,
        reassignable: Bool,
        mutability: MutabilityQualifer,
        initialBinding: (op: BindingOperator, value: Node)?,
        range: SourceRange)
    {
        self.name = name
        self.attributes = attributes
        self.reassignable = reassignable
        self.mutability = mutability
        self.initialBinding = initialBinding
        self.range = range
    }

    /// The name of the variable.
    public var name: String
    /// The member attributes of the variable.
    public var attributes: Set<MemberAttribute>
    /// Whether or not the variable is reassignable (i.e. declared with `let` or `const`).
    public var reassignable: Bool
    /// The mutability qualifier of the variable.
    public var mutability: MutabilityQualifer
    /// The initial binding value of the property.
    public var initialBinding: (op: BindingOperator, value: Node)?
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A function declaration.
public class FunDecl: NamedNode {

    public init(
        name: String,
        attributes: Set<MemberAttribute>,
        asynchronous: Bool,
        parameters: [ParamDecl],
        returnMutability: MutabilityQualifer,
        body: Block,
        range: SourceRange)
    {
        self.name = name
        self.attributes = attributes
        self.asynchronous = asynchronous
        self.parameters = parameters
        self.returnMutability = returnMutability
        self.body = body
        self.range = range
    }

    /// The name of the function.
    public var name: String
    /// The member attributes of the function.
    public var attributes: Set<MemberAttribute>
    /// Whether or not the function is asynchronous.
    public var asynchronous: Bool
    /// The parameters of the function.
    public var parameters: [ParamDecl]
    /// The mutability qualifier of the function return.
    public var returnMutability: MutabilityQualifer
    /// The body of the function.
    public var body: Block
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A generator declaration.
public class GenDecl: NamedNode {

    public init(
        name: String,
        attributes: Set<MemberAttribute>,
        asynchronous: Bool,
        parameters: [ParamDecl],
        returnAnnotation: Node?,
        body: Block,
        range: SourceRange)
    {
        self.name = name
        self.attributes = attributes
        self.asynchronous = asynchronous
        self.parameters = parameters
        self.returnAnnotation = returnAnnotation
        self.body = body
        self.range = range
    }

    /// The name of the generator.
    public var name: String
    /// The member attributes of the generator.
    public var attributes: Set<MemberAttribute>
    /// Whether or not the generator is asynchronous.
    public var asynchronous: Bool
    /// The parameters of the generator.
    public var parameters: [ParamDecl]
    /// The return annotation of the generator.
    public var returnAnnotation: Node?
    /// The body of the generator.
    public var body: Block
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// An arrow function expression.
public class ArrowFun: Node {

    public init(
        parameters: [ParamDecl],
        returnAnnotation: Node?,
        body: Block,
        range: SourceRange)
    {
        self.parameters = parameters
        self.returnAnnotation = returnAnnotation
        self.body = body
        self.range = range
    }

    /// The parameters of the function.
    public var parameters: [ParamDecl]
    /// The return annotation of the function.
    public var returnAnnotation: Node?
    /// The body of the function.
    public var body: Block
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A function parameter declaration.
public class ParamDecl: NamedNode {

    public init(
        name: String,
        mutability: MutabilityQualifer,
        defaultValue: (op: BindingOperator, value: Node)?,
        range: SourceRange)
    {
        self.name = name
        self.mutability = mutability
        self.defaultValue = defaultValue
        self.range = range
    }

    /// The name of the parameter.
    public var name: String
    /// The mutability qualifier of the parameter.
    public var mutability: MutabilityQualifer
    /// The default value of the paramter.
    public var defaultValue: (op: BindingOperator, value: Node)?
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A class declaration.
public class ClassDecl: NamedNode {

    public init(name: String, members: [Node], range: SourceRange) {
        self.name = name
        self.members = members
        self.range = range
    }

    /// The name of the class.
    public var name: String
    /// The members of the class.
    public var members: [Node]
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// An assignment statement.
public class Assignment: Node {

    public init(lvalue: Node, op: BindingOperator, rvalue: Node, range: SourceRange) {
        self.lvalue = lvalue
        self.op = op
        self.rvalue = rvalue
        self.range = range
    }

    /// The l-value of the assignment.
    public var lvalue: Node
    /// The binding operator of the assignment.
    public var op: BindingOperator
    /// The r-value of the assignment.
    public var rvalue: Node
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A conditional statement.
public class If: Node {

    public init(condition: Node, thenBlock: Node, elseBlock: Node?, range: SourceRange) {
        self.condition = condition
        self.thenBlock = thenBlock
        self.elseBlock = elseBlock
        self.range = range
    }

    /// The condition of the statement.
    public var condition: Node
    /// The then block of the statement.
    public var thenBlock: Node
    /// The else block of the statement.
    public var elseBlock: Node?
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A switch statement.
public class Switch: Node {

    public init(value: Node, cases: [SwitchCase], range: SourceRange) {
        self.value = value
        self.cases = cases
        self.range = range
    }

    /// The value on which the statement is evaluated.
    public var value: Node
    /// The cases of the statement.
    public var cases: [SwitchCase]
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// The case of a switch statement.
public class SwitchCase: Node {

    public init(value: Node, body: Node, range: SourceRange) {
        self.value = value
        self.body = body
        self.range = range
    }

    /// The value of the case.
    public var value: Node
    /// The body of the case.
    public var body: Node
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A while loop.
public class WhileLoop: Node {

    public init(condition: Node, body: Node, range: SourceRange) {
        self.condition = condition
        self.body = body
        self.range = range
    }

    /// The condition of the loop.
    public var condition: Node
    /// The then body of the loop.
    public var body: Node
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A for loop.
public class ForLoop: Node {

    public init(condition: Node, body: Node, range: SourceRange) {
        self.condition = condition
        self.body = body
        self.range = range
    }

    /// The condition of the loop.
    public var condition: Node
    /// The then body of the loop.
    public var body: Node
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A continue statement.
public class Continue: Node {

    public init(range: SourceRange) {
        self.range = range
    }

    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A break statement.
public class Break: Node {

    public init(range: SourceRange) {
        self.range = range
    }

    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A return statement.
public class Return: Node {

    public init(value: Node? = nil, range: SourceRange) {
        self.value = value
        self.range = range
    }

    /// The value of the return statement.
    public var value: Node?
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A yield statement.
public class Yield: Node {

    public init(value: Node? = nil, range: SourceRange) {
        self.value = value
        self.range = range
    }

    /// The value of the yield statement.
    public var value: Node?
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A prefixed expression.
public class PrefixExpr: Node {

    public init(op: PrefixOperator, operand: Node, range: SourceRange) {
        self.op = op
        self.operand = operand
        self.range = range
    }

    /// The operator of the expression.
    public var op: PrefixOperator
    /// The operand of the expression.
    public var operand: Node
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A postfixed expression.
public class PostfixExpr: Node {

    public init(op: PostfixOperator, operand: Node, range: SourceRange) {
        self.op = op
        self.operand = operand
        self.range = range
    }

    /// The operator of the expression.
    public var op: PostfixOperator
    /// The operand of the expression.
    public var operand: Node
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// An infixed expression.
public class InfixExpr: Node {

    public init(left: Node, op: InfixOperator, right: Node, range: SourceRange) {
        self.left = left
        self.op = op
        self.right = right
        self.range = range
    }

    /// The left operand of the expression.
    public var left: Node
    /// The operator of the expression.
    public var op: InfixOperator
    /// The right operand of the expression.
    public var right: Node
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A ternary expression.
public class TernaryExpr: Node {

    public init(condition: Node, thenValue: Node, elseValue: Node, range: SourceRange) {
        self.condition = condition
        self.thenValue = thenValue
        self.elseValue = elseValue
        self.range = range
    }

    /// The condition of the expression.
    public var condition: Node
    /// The value of the expression, if the condition holds.
    public var thenValue: Node
    /// The value of the expression, if the condition doesn't hold.
    public var elseValue: Node
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A dot expression.
public class DotExpr: Node {

    public init(owner: Node, attribute: String, range: SourceRange) {
        self.owner = owner
        self.attribute = attribute
        self.range = range
    }

    /// The owner.
    public var owner: Node
    /// The attribute expression.
    public var attribute: String
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A call expression.
public class CallExpr: Node {

    public init(callee: Node, arguments: [Argument], range: SourceRange) {
        self.callee = callee
        self.arguments = arguments
        self.range = range
    }

    /// The callee.
    public var callee: Node
    /// The arguments of the call.
    public var arguments: [Argument]
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A subscript expression.
public class SubscriptExpr: Node {

    public init(callee: Node, index: Node, range: SourceRange) {
        self.callee = callee
        self.index = index
        self.range = range
    }

    /// The callee.
    public var callee: Node
    /// The index of the subscript.
    public var index: Node
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A call or subscript argument.
public class Argument: Node {

    public init(byReference: Bool, value: Node, range: SourceRange) {
        self.byReference = byReference
        self.value = value
        self.range = range
    }

    /// Whether or not the argument is passed by reference.
    public var byReference: Bool
    /// The value of the argument.
    public var value: Node
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// An identifier.
public class Identifier: NamedNode {

    public init(name: String, range: SourceRange) {
        self.name = name
        self.range = range
    }

    /// The name of the variable.
    public var name: String
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A scalar literal.
public class ScalarLiteral: Node {

    public init(value: Any, range: SourceRange) {
        self.value = value
        self.range = range
    }

    /// The value of the literal.
    public var value: Any
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// An array literal.
public class ArrayLiteral: Node {

    public init(elements: [Node], range: SourceRange) {
        self.elements = elements
        self.range = range
    }

    /// The elements of the literal.
    public var elements: [Node]
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}

/// A object literal.
public class ObjectLiteral: Node {

    public init(elements: [String: Node], range: SourceRange) {
        self.elements = elements
        self.range = range
    }

    /// The elements of the literal.
    public var elements: [String: Node]
    /// The range in the source file of the concrete syntax this node represents.
    public var range: SourceRange

}
