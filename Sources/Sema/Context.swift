import AST

/// An AST context.
public class Context {

    public typealias Element = (node: Node, data: [String: Any])

    public init() {}

    public subscript(node: Node, key: String) -> Any? {
        get {
            guard let data = mapping.first(where: { $0.node === node })?.data
                else { return nil }
            return data[key]
        }

        set {
            if let index = mapping.index(where: { $0.node === node }) {
                var newData = mapping[index].data
                newData[key] = newValue
                mapping[index] = (node: node, data: newData)
            } else if newValue != nil {
                mapping.append((node: node, data: [key: newValue!]))
            }
        }
    }

    public subscript<T>(node: Node, key: String) -> T? {
        return self[node, key] as? T
    }

    var mapping: [Element] = []

}
