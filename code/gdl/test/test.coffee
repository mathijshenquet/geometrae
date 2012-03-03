fs = require 'fs'

require '../helpers'
require '../lexer'
require '../parser'

lexer = new GDLLexer
parser = new GDLParser

tokens = lexer.tokenize ("" + fs.readFileSync "simple.gdl")
console.log tokens

pt = parser.parse(tokens)
console.log pt
