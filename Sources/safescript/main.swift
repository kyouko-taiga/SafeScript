#if os(Linux)
import Glibc
#else
import Darwin.C
#endif
import AST
import Parser
import Sema
import Transpiler
import Utils

// Read the input and output paths.
if CommandLine.arguments.count < 2 {
    Console.err.print("error: ", in: [.bold, .red], terminator: "")
    Console.err.print("missing input")
    exit(1)
}

var inputPath : String? = nil
var outputPath: String? = nil

var i = 1
while i < CommandLine.arguments.count {
    if CommandLine.arguments[i] == "-o" {
        guard (i + 1) < CommandLine.arguments.count else {
            Console.err.print("error: ", in: [.bold, .red], terminator: "")
            Console.err.print("no output specified after '-o'")
            exit(1)
        }
        outputPath = CommandLine.arguments[i + 1]
        i += 2
    } else if inputPath != nil {
        Console.err.print("error: ", in: [.bold, .red], terminator: "")
        Console.err.print("unexpected argument: '\(CommandLine.arguments[i])'")
        exit(1)
    } else {
        inputPath = CommandLine.arguments[i]
        i += 1
    }
}

outputPath = outputPath ?? (inputPath! + ".js")

// Read the input file.
let inputFile: File
do {
    inputFile = try File(path: inputPath!)
} catch {
    Console.err.print("error: ", in: [.bold, .red], terminator: "")
    Console.err.print(error)
    exit(1)
}

// Parse the input file.
let lexer = Lexer(string: inputFile.read())
let parser = Parser(lexer, moduleName: "main")
let ast: Block
do {
    ast = try parser.parse()
} catch let error as SemanticError {
    report(error: error, in: inputFile)
    exit(1)
} catch {
    Console.err.print("error: ", in: [.bold, .red], terminator: "")
    Console.err.print(error)
    exit(1)
}

// Perform semantic analysis.
let astContext = Context()
var passes: [Pass] = [SymbolsExtractor(), ScopeBinder(), TypeCreator(), BorrowChecker()]
for i in 0 ..< passes.count {
    let errors = passes[i].run(on: ast, in: astContext)
    guard errors.isEmpty else {
        for error in errors {
            switch error {
            case let se as SemanticError:
                report(error: se, in: inputFile)
            default:
                Console.err.print("error: ", in: [.bold, .red], terminator: "")
                Console.err.print(error)
            }
        }
        exit(1)
    }
}

var transpiler = try Transpiler(
    output: File(path: outputPath!, mode: .write))
try transpiler.visit(ast)
