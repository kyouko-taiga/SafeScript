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

    /// The members of the symbol.
    ///
    /// Those are the symbols that "belong" to this symbol, in the context of objects and class
    /// instances. We collect them so we can ensure their unicity when visiting dot expressions.
    public var children: [Symbol] = []

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
