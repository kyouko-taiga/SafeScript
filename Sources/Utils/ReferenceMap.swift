public struct ReferenceMap<Key: AnyObject, Value> {

    public typealias Element = (key: Key, value: Value)

    public init() {}

    public subscript(key: Key) -> Value? {
        get {
            let h = Unmanaged.passUnretained(key).toOpaque().hashValue
            return storage[h]?.first(where: { $0.key === key })?.value
        }

        set {
            let h = Unmanaged.passUnretained(key).toOpaque().hashValue
            if let index = storage[h]?.index(where: { $0.key === key }) {
                if newValue != nil {
                    storage[h]![index] = (key: key, value: newValue!)
                } else {
                    storage[h]!.remove(at: index)
                }
            } else if newValue != nil {
                storage[h] = [(key: key, value: newValue!)]
            }
        }
    }

    @discardableResult
    public mutating func removeValue(forKey key: Key) -> Value? {
        let h = Unmanaged.passUnretained(key).toOpaque().hashValue
        guard let index = storage[h]?.index(where: { $0.key === key })
            else { return nil }
        let (_, value) = storage[h]!.remove(at: index)
        return value
    }

    private var storage: [Int: [Element]] = [:]

}

extension ReferenceMap: ExpressibleByDictionaryLiteral {

    public init(dictionaryLiteral elements: (Key, Value)...) {
        for (key, value) in elements {
            self[key] = value
        }
    }

}
