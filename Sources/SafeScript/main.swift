let source = """
let x = 0
"""

let lexer = Lexer(string: source)
let parser = Parser(lexer, moduleName: "main")
let ast = try parser.parse()
print(ast.prettyDescription)
