import AST

public protocol SafeScriptType { }

public struct GroundType: SafeScriptType {

    init(name: String) {
        self.name = name
    }

    public let name: String

    public static let undefined = GroundType(name: "undefined")
    public static let number    = GroundType(name: "number")
    public static let string    = GroundType(name: "string")

}

extension GroundType: CustomStringConvertible {

    public var description: String { return name }

}

public class FunctionType: SafeScriptType {

    init(domain: [MutabilityQualifer]) {
        self.domain = domain
    }

    let domain: [MutabilityQualifer]

}

extension FunctionType: CustomStringConvertible {

    public var description: String {
        let t = domain.map({ $0.rawValue }).joined(separator: ", ")
        return "f(\(t)"
    }

}
