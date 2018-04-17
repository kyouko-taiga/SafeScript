extension Array {

    func duplicates<T>(groupedBy discriminator: (Element) -> T) -> [Element] where T: Hashable {
        var present: Set<T> = []
        var result: [Element] = []

        for element in self {
            let key = discriminator(element)
            if present.insert(key).inserted != true {
                result.append(element)
            }
        }
        return result
    }

}
