require_relative "../lib/vhdl.rb"

# TODO : Voir pour faire des tests avec Rspec

txt=IO.read("./tests/test.vhd")
ast = VHDL::Parser.new.parse(VHDL::Lexer.new.tokenize(txt))
decorated_ast = VHDL::Visitor.new.visitAST ast
# pp decorated_ast

test = VHDL::AST::Work.new(decorated_ast.entity)
# # pp test
test.export

deparser = VHDL::DeParser.new decorated_ast
deparser.deparse
deparser.save

txt = IO.read("./tests/test2.vhd")
ast = VHDL::Parser.new.parse(VHDL::Lexer.new.tokenize(txt))
decorated_ast = VHDL::Visitor.new.visitAST ast


deparser = VHDL::DeParser.new decorated_ast
deparser.deparse
deparser.save


txt=IO.read("./rev_test.vhd")
ast = VHDL::Parser.new.parse(VHDL::Lexer.new.tokenize(txt))
decorated_ast = VHDL::Visitor.new.visitAST ast
# pp decorated_ast

test = VHDL::AST::Work.new(decorated_ast.entity)
# # pp test
test.export

deparser = VHDL::DeParser.new decorated_ast
deparser.deparse
deparser.save_as("./rev_rev_test.vhd")

txt = IO.read("./rev_test2.vhd")
ast = VHDL::Parser.new.parse(VHDL::Lexer.new.tokenize(txt))
decorated_ast = VHDL::Visitor.new.visitAST ast

deparser = VHDL::DeParser.new decorated_ast
deparser.deparse
deparser.save_as("./rev_rev_test2.vhd")