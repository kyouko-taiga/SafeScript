import Foundation

import AST
import Parser
import Sema
import Utils

extension ParseError: SemanticError {}

func report(error: SemanticError, in source: File) {
    // Report the error description.
    if let range = error.range {
        Console.err.print("\(range.start): ", in: .bold, terminator: "")
    }
    Console.err.print("error: ", in: [.bold, .red], terminator: "")
    Console.err.print(error)

    // Report the error location, if possible.
    guard let range = error.range
        else { return }

    let lines = source.read().split(
        separator: "\n", maxSplits: range.start.line, omittingEmptySubsequences: false)
    let line = lines[range.start.line - 1].replacingOccurrences(of: "\n", with: " ")
    Console.err.print(line)
    if (range.start.line == range.end.line) && (range.end.column - range.start.column > 1) {
        Console.err.print(String(repeating: " ", count: range.start.column - 1), terminator: "")
        Console.err.print(String(repeating: "~", count: range.end.column - range.start.column))
    } else {
        Console.err.print(String(repeating: " ", count: range.start.column - 1) + "^")
    }
}
