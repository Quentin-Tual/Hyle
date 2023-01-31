require "../lib/vhdl.rb"

RSpec.describe VHDL::Parser do

    # TODO 1 - Utiliser les fichiers plutôt que du texte en brut dans tous les tests précédents (chargement du fichier de test au format .vhd à chaque test nécessaire).
    
    # TODO 2 - Disposer d'une lib .work de test ? A voir si utile pour tester et comparer la lib générée avec celle devant être obtenue.

    # TODO 3 - S'assurer que les entités test et test2 soient dans la lib .work et vérifier qu'ici tout soit chargé correctement. 

    before(:all) do
        @visitor = VHDL::Visitor.new
        # str = IO.read("test.vhd")
        # VHDL::Parser.new.parse str
        @str = IO.read("test.vhd")
        @ast = VHDL::Parser.new.parse @str
        @decorated_ast = @visitor.visitAST @ast
    end

    it 'creates a Visitor object' do 
        # @visitor = VHDL::Visitor.new
        expect(@visitor.id_tab).to be_kind_of Hash
        expect(@visitor.actual_lib).to be_kind_of VHDL::AST::Work
    end

    it 'visits the AST, analyses its contextual correctness and decorate it' do
        expect(@decorated_ast).to be_kind_of VHDL::AST::Root
        expect(@decorated_ast.entity).to be_kind_of VHDL::AST::Entity
        expect(@decorated_ast.architectures).to be_kind_of Array
    end

    it 'visits entities of the AST' do
        expect(@decorated_ast.entity).to be_kind_of VHDL::AST::Entity 
        expect(@decorated_ast.entity.name).to be_kind_of VHDL::AST::Ident        
        expect(@decorated_ast.entity.ports).to be_kind_of Array 
        @decorated_ast.entity.ports.each{|p| expect(p).to be_kind_of VHDL::AST::Port}
    end
end