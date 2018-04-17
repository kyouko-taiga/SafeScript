import Parser

let source = """
let x: mutable = 0
let y: mutable &- x
"""

let lexer = Lexer(string: source)
let parser = Parser(lexer, moduleName: "main")
let ast = try parser.parse()
print(ast.prettyDescription)
