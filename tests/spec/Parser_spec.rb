require "../lib/vhdl.rb"

RSpec.describe VHDL::Parser do

    before(:each) do
        @str = IO.read("test2.vhd")
                @ast = VHDL::Parser.new.parse @str

    end

    before(:all) do
        @parser = VHDL::Parser.new
    end

    # ToDo : En théorie, les tests devraient plutôt être unitaires et non en un bloc comme celui-ci. A voir pour partitionner plus tard.
    it 'parses a character string (VHDL source code) into a valid AST' do
        expect(@ast).to be_kind_of VHDL::AST::Root
    end

    it 'parses entity description from VHDL source' do
        expect(@ast.entity).to be_kind_of VHDL::AST::Entity 
        expect(@ast.entity.name).to be_kind_of VHDL::AST::Ident        
        expect(@ast.entity.ports).to be_kind_of Array 
        @ast.entity.ports.each{|p| expect(p).to be_kind_of VHDL::AST::Port}
    end

    it 'parses architecture description from VHDL source' do
        # TODO : Architectures, on devrait ici vérifier chaque champ de chaque branche de l'AST pour s'assurer que le logiciel fasse bien ce qu'on lui demande. Ici, on se restreint à la vérif structurelle pour le moment
        expect(@ast.architectures).to be_kind_of Array
        @ast.architectures.each{ |a| expect(a).to be_kind_of VHDL::AST::Architecture}
        @ast.architectures.each{ |a|
            expect(a.name).to be_kind_of VHDL::AST::Ident
            expect(a.name.name).to eq('rtl').or eq('behavioral')
        }
    end

    it 'parses architectures body from VHDL source' do
        @ast.architectures.each{ |a|
            if a.name.name == 'rtl'
                expect(a.body).to be_kind_of Array
                a.body.each{ |b| 
                    expect(b).to be_kind_of VHDL::AST::AssignStatement 
                    expect(b.dest).to be_kind_of VHDL::AST::Ident
                    expect(b.source).to be_kind_of VHDL::AST::Ident
                }
                
            elsif a.name.name == 'behavioral'
                a.body.each{ |b| 
                    expect(b).to be_kind_of VHDL::AST::InstantiateStatement
                    expect(b.name).to be_kind_of VHDL::AST::Ident
                    expect(b.entity).to be_kind_of VHDL::AST::Ident
                    expect(b.arch).to be_kind_of VHDL::AST::Ident
                    expect(b.lib).to be_kind_of VHDL::AST::Ident
                    expect(b.port_map).to be_kind_of VHDL::AST::PortMap
                }
                
            end
        }
    end 

    it 'parses port map structure from VHDL source' do
        @ast.architectures.each { |a| 
            tmp = a.body.select{ |b| b.class == VHDL::AST::InstantiateStatement}
            tmp.each{|is| 
                is.port_map.association_statements.each{ |s| 
                    expect(s).to be_kind_of VHDL::AST::AssociationStatement
                    expect(s.dest).to be_kind_of VHDL::AST::Ident
                    expect(s.source).to be_kind_of VHDL::AST::Ident
                }
            }
        } 
    end
end