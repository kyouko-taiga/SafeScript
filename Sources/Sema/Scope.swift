/// A mapping from names to symbols.
///
/// This collection stores the symbols that are declared within a scope (e.g. a function scope).
/// It is a mapping `String -> [Symbol]`, as a symbol names may be overloaded.
public class Scope {

    public init(name: String? = nil, parent: Scope? = nil) {
        // Create a unique ID for the scope.
        self.id = Scope.nextID
        Scope.nextID += 1

        self.name   = name
        self.parent = parent
    }

    /// Returns whether or not a symbol with the given name exists in this scope.
    public func defines(name: String) -> Bool {
        return self.symbols[name] != nil
    }

    /// Adds a symbol to this scope.
    public func add(symbol: Symbol) {
        precondition(!self.defines(name: symbol.name))
        self.symbols[symbol.name] = symbol
        symbol.scope = self
    }

    /// Returns the first scope in the hierarchy for which a symbol with the given name exists.
    public func findScopeDefining(name: String) -> Scope? {
        if self.symbols[name] != nil {
            return self
        } else if let parent = self.parent {
            return parent.findScopeDefining(name: name)
        } else {
            return nil
        }
    }

    public weak var parent: Scope?

    public let id      : Int
    public let name    : String?
    public var children: [Scope] = []
    public var symbols : [String: Symbol] = [:]

    fileprivate static var nextID = 0

}

extension Scope: Hashable {

    public var hashValue: Int {
        return self.id
    }

    public static func == (lhs: Scope, rhs: Scope) -> Bool {
        return lhs.id == rhs.id
    }

}

extension Scope: CustomStringConvertible {

    public var description: String {
        if let parent = self.parent {
            return "\(parent).\(self.name ?? self.id.description)"
        }
        return self.name ?? self.id.description
    }
}
