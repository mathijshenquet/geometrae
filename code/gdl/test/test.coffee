fs = require 'fs'
{Lexer} = require '../lexer'
{Parser} = require '../parser'

lexer = new Lexer
parser = new Parser

tokens = lexer.tokenize ("" + fs.readFileSync "simple.gdl")
console.log tokens

pt = parser.parse(tokens)
console.log pt
