require "../lib/vhdl.rb"

RSpec.describe VHDL::DeParser do

    context "Without instanciation in Architecture body" do

        before(:all) do
            str = IO.read("test.vhd")
            tokens = VHDL::Lexer.new.tokenize str
            ast = VHDL::Parser.new.parse tokens
            decorated_ast = VHDL::Visitor.new.visitAST ast
            @deparser = VHDL::DeParser.new decorated_ast
        end

        it 'contains a decorated AST' do
            expect(@deparser).to be_kind_of VHDL::DeParser
            expect(@deparser.dec_ast).to be_kind_of VHDL::AST::Root
            expect(@deparser.str).to be_kind_of String
        end

        it 'returns entity VHDL description' do
            tmp = @deparser.deparse_entity  @deparser.dec_ast.entity
            expect(tmp).to be_kind_of String 
            expect(tmp).to eq("entity test is\n\tport (\n\t\tclk : in bit;\n\t\ten : in bit;\n\t\trst : in bit;\n\t\ts : out bit\n\t);\nend test;\n\n")
        end

        it 'return an architecture section in VHDL description' do
            tmp = @deparser.deparse_arch @deparser.dec_ast.architectures[0]
            expect(tmp).to be_kind_of String
            expect(tmp).to eq("architecture rtl of test is\n\n\tsignal s0 : bit;\n\tsignal s1 : bit_vector(15 downto 0);\n\nbegin\n\n\ts <= clk;\n\nend architecture;\n\n")
        end

        it 'return an architecture section in VHDL description with an empty body' do
            tmp = @deparser.deparse_arch @deparser.dec_ast.architectures[1]
            expect(tmp).to be_kind_of String
            expect(tmp).to eq("architecture behavioral of test is\n\nbegin\n\nend architecture;\n\n")
        end 

        it 'restitute correctly architecture signal declarations' do
            tmp = @deparser.deparse_arch_decl @deparser.dec_ast.architectures[0].decl
            expect(tmp).to eq "\tsignal s0 : bit;\n\tsignal s1 : bit_vector(15 downto 0);\n\n"
        end

        it 'allow to save the VHDL oobtained in a .vhd file' do
            str = IO.read("test.vhd")
            tokens = VHDL::Lexer.new.tokenize str
            ast = VHDL::Parser.new.parse tokens
            decorated_ast = VHDL::Visitor.new.visitAST ast
            # str = IO.read("test2.vhd")
            # tokens = VHDL::Lexer.new.tokenize str
            # ast = VHDL::Parser.new.parse tokens
            # decorated_ast = VHDL::Visitor.new.visitAST ast
            @deparser = VHDL::DeParser.new decorated_ast
            @deparser.deparse 
            @deparser.save
            expect(File.exists?("rev_#{@deparser.dec_ast.entity.name.name}.vhd")).to eq(true)
        end

    end

    context "With instanciation in Architecture body" do
        
        before(:all) do
            str = IO.read("test2.vhd")
            tokens = VHDL::Lexer.new.tokenize str
            ast = VHDL::Parser.new.parse tokens
            decorated_ast = VHDL::Visitor.new.visitAST ast
            @deparser = VHDL::DeParser.new decorated_ast
        end

        it 'return an architecture declaration section in VHDL description' do
            tmp = @deparser.deparse_arch @deparser.dec_ast.architectures[1]
            expect(tmp).to be_kind_of String
            expect(tmp).to eq("architecture behavioral of test2 is\n\nbegin\n\n\tMUX : entity work.test(rtl)\n\tport map (\n\t\tclk => clk,\n\t\ten => en,\n\t\trst => rst,\n\t\ts => s\n\t);\n\nend architecture;\n\n")
        end
    end
    
end