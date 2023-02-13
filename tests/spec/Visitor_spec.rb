require "../lib/vhdl.rb"

RSpec.describe VHDL::Visitor do
    
    # TODO 1 - Disposer d'une lib .work de test ? A voir si utile pour tester et comparer la lib générée avec celle devant être obtenue.

    # TODO 2 - S'assurer que les entités test et test2 soient dans la lib .work et vérifier qu'ici tout soit chargé correctement. 

    subject do 
        VHDL::Visitor.new
    end

    context 'No .work file' do
        before(:each) do
            # str = IO.read("test.vhd")
            # VHDL::Parser.new.parse str
            str = IO.read("test.vhd")
            tokens = VHDL::Lexer.new.tokenize str
            ast = VHDL::Parser.new.parse tokens
            @decorated_ast = subject.visitAST ast
        end

        it 'creates a Visitor object' do 
            # subject = VHDL::Visitor.new
            expect(subject.id_tab).to be_kind_of Hash
            expect(subject.actual_lib).to be_kind_of VHDL::AST::Work
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

        it 'visits architectures of the AST' do 
            @decorated_ast.architectures.each{ |arch| 
                expect(arch.name).to be_kind_of VHDL::AST::Ident
                expect(arch.entity).to be_kind_of VHDL::AST::Entity
                expect(arch.body).to be_kind_of Array
                arch.body.each{ |statement|
                    expect(statement).to be_kind_of(VHDL::AST::AssociationStatement).or be_kind_of(VHDL::AST::AssignStatement).or be_kind_of(VHDL::AST::InstantiateStatement)
                    case statement
                    when VHDL::AST::AssignStatement
                        expect(statement.dest).to be_kind_of VHDL::AST::Port
                        expect(statement.source).to be_kind_of VHDL::AST::Port
                    when VHDL::AST::InstantiateStatement
                        expect(statement.name).to be_kind_of VHDL::AST::Ident
                        expect(statement.entity).to be_kind_of VHDL::AST::Entity
                        expect(statement.arch).to be_kind_of VHDL::AST::Architecture
                        expect(statement.lib).to be_kind_of VHDL::AST::Ident
                        expect(statement.port_map).to be_kind_of VHDL::AST::PortMap
                        statement.port_map.association_statements.each{ |asso_stmt| 
                            expect(asso_stmt).to be_kind_of VHDL::AST::AssociationStatement
                            expect(asso_stmt.dest).to be_kind_of VHDL::AST::Port
                            expect(asso_stmt.source).to be_kind_of VHDL::AST::Port 
                        }
                    end
                }
            }
        end
    end

    context 'Existing .work file' do
        before(:each) do
            # str = IO.read("test.vhd")
            # VHDL::Parser.new.parse str
            str = IO.read("test2.vhd")
            tokens = VHDL::Lexer.new.tokenize str
            ast = VHDL::Parser.new.parse tokens
            @decorated_ast = subject.visitAST ast
        end

        it 'creates a Visitor object' do 
            # subject = VHDL::Visitor.new
            expect(subject.id_tab).to be_kind_of Hash
            expect(subject.actual_lib).to be_kind_of VHDL::AST::Work
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
            @decorated_ast.entity.ports.each{ |port| 
                expect(port).to be_kind_of VHDL::AST::Port
                expect(port.name).to be_kind_of VHDL::AST::Ident
                expect(port.port_type).to eq("in").or eq("out")
                expect(port.data_type).to eq "bit"
                expect(port.value).to eq nil
            }
        end

        it 'visits architectures of the AST' do 
            @decorated_ast.architectures.each{ |arch| 
                expect(arch.name).to be_kind_of VHDL::AST::Ident
                expect(arch.entity).to be_kind_of VHDL::AST::Entity
                expect(arch.body).to be_kind_of Array
                arch.body.each{ |statement|
                    expect(statement).to be_kind_of(VHDL::AST::AssociationStatement).or be_kind_of(VHDL::AST::AssignStatement).or be_kind_of(VHDL::AST::InstantiateStatement)
                    case statement
                    when VHDL::AST::AssignStatement
                        expect(statement.dest).to be_kind_of VHDL::AST::Port
                        expect(statement.source).to be_kind_of VHDL::AST::Port
                    when VHDL::AST::InstantiateStatement
                        expect(statement.name).to be_kind_of VHDL::AST::Ident
                        expect(statement.entity).to be_kind_of VHDL::AST::Entity
                        expect(statement.arch).to be_kind_of VHDL::AST::Architecture
                        expect(statement.lib).to be_kind_of VHDL::AST::Ident
                        expect(statement.port_map).to be_kind_of VHDL::AST::PortMap
                        statement.port_map.association_statements.each{ |asso_stmt| 
                            expect(asso_stmt).to be_kind_of VHDL::AST::AssociationStatement
                            expect(asso_stmt.dest).to be_kind_of VHDL::AST::Port
                            expect(asso_stmt.source).to be_kind_of VHDL::AST::Port 
                        }
                    end
                }
            }
        end
    end
end