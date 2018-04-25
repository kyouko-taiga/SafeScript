/// A named symbol.
public class Symbol {

    public init(name: String) {
        self.name = name
    }

    /// The type of the symbol.
    ///
    /// Note that due to the dynamic nature of safescript, the type of a symbol may change during
    /// the different passes of the semantic analysis.
    public var type: SafeScriptType?

    public let name: String
    public weak var scope: Scope?

}

extension Symbol: Hashable {

    public var hashValue: Int {
        return self.name.hashValue ^ (self.scope?.id ?? 0)
    }

    public static func == (lhs: Symbol, rhs: Symbol) -> Bool {
        return lhs === rhs
    }

}

extension Symbol: CustomStringConvertible {

    public var description: String {
        return "$\(name)"
    }

}
