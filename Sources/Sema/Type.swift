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
