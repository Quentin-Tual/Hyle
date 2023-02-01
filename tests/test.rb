require_relative "../lib/vhdl.rb"

# TODO : Voir pour faire des tests avec Rspec

txt=IO.read("./test.vhd")
ast = VHDL::Parser.new.parse txt
decorated_ast = VHDL::Visitor.new.visitAST ast
# pp decorated_ast

test = VHDL::AST::Work.new(decorated_ast.entity)
# # pp test
test.export

# txt = IO.read("vhdl/tests/test2.vhd")
# ast = VHDL::Parser.new.parse txt
# decorated_ast = VHDL::Visitor.new.visitAST ast

# test.update decorated_ast.entity
# # pp test

# test2 = VHDL::AST::Work.new
# test2.import
# pp test2

txt=IO.read("./test2.vhd")
ast = VHDL::Parser.new.parse txt
decorated_ast = VHDL::Visitor.new.visitAST ast

pp decorated_ast