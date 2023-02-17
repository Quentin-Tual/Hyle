require "../lib/vhdl.rb"

RSpec.describe VHDL::Lexer do
    
    before(:all) do 
        # TODO : Instancier les variables utiles à chaque fois (un Lexer, ...)s
        @lexer = VHDL::Lexer.new
    end

    it "creates a Lexer class" do 
        expect(@lexer).to be_kind_of VHDL::Lexer
        expect(@lexer.tokens).to be_kind_of Array
    end

    it "tokenizes a VHDL character string" do
        str = IO.read("test2.vhd")
        expect(@lexer.tokenize(str)).to be_kind_of Array
        # TODO : en théorie on doit vérifier le type, la valeur et le numéro de ligne. En pratique... Un peu long pour le peu d'utilité, il faut grader les tests assez haut niveau pour s'éviter d'y perdre trop de temps. Par exemple des fonctions globales regroupant d'autres fonctions.
    end

    context 'Tokenizes correctly a ' do
        it "bit signal declaration line" do
            str = "signal s0 : bit;\n"
            tmp = @lexer.tokenize(str)
            expect(tmp).to be_kind_of Array
            tmp_kinds = tmp.collect{ |elt| elt.kind}
            expect(tmp_kinds).to eq([:signal, :ident, :colon, :type, :semicol, :new_line])
        end

        it "bit_vector signal declaration line" do
            str = "signal s0 : bit_vector(15 downto 0);\n"
            tmp = @lexer.tokenize(str)
            expect(tmp).to be_kind_of Array
            tmp_kinds = tmp.collect{ |elt| elt.kind}
            expect(tmp_kinds).to eq([:signal, :ident, :colon, :type, :semicol, :new_line])
        end

        it "binary expression assign statement" do
            str = "s0 <= clk and en;\n"
            tmp = @lexer.tokenize(str)
            expect(tmp).to be_kind_of Array
            expect(tmp_kinds = tmp.collect{|e| e.kind}).to eq([:ident, :assign_sig, :ident, :operator, :ident, :semicol, :new_line])
        end
    end
end