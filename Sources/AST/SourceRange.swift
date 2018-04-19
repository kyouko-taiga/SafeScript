public struct SourceLocation: Comparable {

    public init(line: Int = 1, column: Int = 1, offset: Int = 0) {
        self.line = line
        self.column = column
        self.offset = offset
    }

    public var line: Int
    public var column: Int
    public var offset: Int

    public static func == (lhs: SourceLocation, rhs: SourceLocation) -> Bool {
        return lhs.offset == rhs.offset
    }

    public static func < (lhs: SourceLocation, rhs: SourceLocation) -> Bool {
        return lhs.offset < rhs.offset
    }

}

extension SourceLocation: CustomStringConvertible {

    public var description: String {
        return "\(line):\(column)"
    }

}

public struct SourceRange: Equatable {

    public init(from start: SourceLocation, to end: SourceLocation) {
        self.start = start
        self.end = end
    }

    public init(at location: SourceLocation) {
        self.start = location
        self.end = location
    }

    public var start: SourceLocation
    public var end: SourceLocation

    public static func == (lhs: SourceRange, rhs: SourceRange) -> Bool {
        return (lhs.start == rhs.start) && (lhs.end == rhs.end)
    }

}

extension String {

    public subscript(range: SourceRange) -> Substring {
        let start = index(startIndex, offsetBy: range.start.offset)
        let end = index(startIndex, offsetBy: range.end.offset)
        return self[start...end]
    }

}
