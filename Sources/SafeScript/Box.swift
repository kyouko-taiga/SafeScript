/// Boxes the given value to ensure copy-on-write semantics.
public struct Box<T> {

    public init(_ value: T) {
        self.boxed = Ref(value)
    }

    public var value: T {
        get { return boxed.value }
        set {
            guard isKnownUniquelyReferenced(&boxed) else {
                boxed = Ref(newValue)
                return
            }
            boxed.value = newValue
        }
    }

    private var boxed: Ref<T>

}

private class Ref<T> {

    init(_ value: T) {
        self.value = value
    }

    var value: T

}
