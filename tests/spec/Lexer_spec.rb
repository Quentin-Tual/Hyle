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
end