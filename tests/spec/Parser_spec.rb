require "../lib/vhdl.rb"

RSpec.describe VHDL::Parser do

    before(:each) do
        @parser = VHDL::Parser.new
        @str = " entity test2 is 
                    port ( 
                        clk : in bit;
                        en : in bit;
                        rst : in bit;
                        s : out bit
                    );
                end test2;
                
                architecture rtl of test2 is
                
                begin
                
                    s <= clk;
                
                end architecture;
                
                architecture behavioral of test2 is
                
                begin
                
                    MUX : entity work.test(rtl)
                    port map (
                        clk => clk,
                        en => en,
                        rst => rst,
                        s => s
                    );
                
                end architecture;"
                @ast = nil
            
    end

    # ToDo : En théorie, les tests devraient plutôt être unitaires et non en un bloc comme celui-ci. A voir pour partitionner plus tard.
    it 'parses a character string (VHDL source code) into a valid AST' do 
        expect(@ast = @parser.parse(@str)).to be_kind_of VHDL::AST::Root
    end

    it 'parses entity description from VHDL source'
        expect(@ast.entity).to be_kind_of VHDL::AST::Entity 
        expect(@ast.entity.name).to be_kind_of VHDL::AST::Ident        
        expect(@ast.entity.ports).to be_kind_of Array 
        @ast.entity.ports.each{|p| expect(p).to be_kind_of VHDL::AST::Port}
    end

    it 'parses architecture description from VHDL source'
        # TODO : Architectures, on devrait ici vérifier chaque champ de chaque branche de l'AST pour s'assurer que le logiciel fasse bien ce qu'on lui demande. Ici, on se restreint à la vérif structurelle pour le moment
        expect(@ast.architectures).to be_kind_of Array
        @ast.architectures.each{ |a| expect(a).to be_kind_of VHDL::AST::Architecture}
        @ast.architectures.each{ |a|
            expect(a.name).to be_kind_of VHDL::AST::Ident
            expect(a.name.name).to eq('rtl').or eq('behavioral')
        }
    end

    it 'parses architectures body from VHDL source'
        @ast.architectures.each{ |a|
            if a.name.name == 'rtl'
                expect(a.body).to be_kind_of VHDL::AST::AssignStatement
                expect(a.body.dest).to be_kind_of VHDL::AST::Ident
                expect(a.body.source).to be_kind_of VHDL::AST::Ident
            elsif a.name.name == 'behavioral'
                expect(a.body).to be_kind_of VHDL::AST::InstantiateStatement
                expect(a.body.name).to be_kind_of VHDL::AST::Ident
                expect(a.body.entity).to be_kind_of VHDL::AST::Ident
                expect(a.body.arch).to be_kind_of VHDl::AST::Ident
                expect(a.body.lib).to be_kind_of VHDL::AST::Ident
                expect(a.body.port_map).to be_kind_of VHDL::AST::PortMap
            end
        }
    end 

    it 'parses port map structure from VHDL source'
        a.body.port_map.each{|s| expect(s).to be_kind_of VHDL::AST::AssociationStatement}
        a.body.port_map.each{|s| expect(s.dest).to be_kind_of VHDL::AST::Ident}
        a.body.port_map.each{|s| expect(s.source).to be_kind_of VHDL::AST::Ident}
    end

end 