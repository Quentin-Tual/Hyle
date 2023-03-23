require "../lib/vhdl.rb"

RSpec.describe VHDL::Visitor do
    
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
                expect(arch.decl).to be_kind_of Array
                arch.decl.each{ |declaration|
                    expect(declaration).to be_kind_of VHDL::AST::SignalDeclaration # ! : ou d'éventuels futurs types de déclarations possibles.
                    expect(declaration.name).to be_kind_of VHDL::AST::Ident
                    expect(declaration.data_type).to be_kind_of VHDL::AST::Type
                    expect(declaration.data_type.type_name).to be_kind_of String
                    expect(declaration.data_type.size).to be_kind_of Integer
                }
                expect(arch.body).to be_kind_of Array
                arch.body.each{ |statement|
                    expect(statement).to be_kind_of(VHDL::AST::AssociationStatement).or be_kind_of(VHDL::AST::AssignStatement).or be_kind_of(VHDL::AST::InstantiateStatement)
                    case statement
                    when VHDL::AST::AssignStatement
                        expect(statement.dest.decl).to be_kind_of(VHDL::AST::Port).or be_kind_of(VHDL::AST::SignalDeclaration)
                        expect(statement.source).to be_kind_of(VHDL::AST::Ident).or be_kind_of(VHDL::AST::UnaryExp).or be_kind_of(VHDL::AST::BinaryExp)
                        if statement.source.class == VHDL::AST::Ident
                            expect(statement.source.decl).to be_kind_of(VHDL::AST::Port).or be_kind_of(VHDL::AST::SignalDeclaration)
                        end # ! : Ici on devrait séparer en deux tests avec les UnaryExp à ajouter à terme.
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

        it 'Check the context in architecture declaration and add signals to id_tab attribute' do 

        end
    end

    context 'Existing .work file with instanciation' do
        before(:each) do
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
                expect(port.data_type).to be_kind_of VHDL::AST::Type
                expect(port.data_type).to eq(VHDL::AST::Type.new("bit"))
            }
        end

        it 'visits architectures of the AST' do 
            @decorated_ast.architectures.each{ |arch| 
                expect(arch.name).to be_kind_of VHDL::AST::Ident
                expect(arch.entity).to be_kind_of VHDL::AST::Entity
                expect(arch.decl).to be_kind_of Array
                arch.decl.each{ |declaration|
                    expect(declaration).to be_kind_of VHDL::AST::SignalDeclaration # ! : ou d'éventuels futurs types de déclarations possibles.
                    expect(declaration.name).to be_kind_of VHDL::AST::Ident
                    expect(declaration.data_type).to be_kind_of VHDL::AST::Type
                    expect(declaration.data_type.type_name).to be_kind_of String
                    expect(declaration.data_type.size).to be_kind_of Integer
                }
                expect(arch.body).to be_kind_of Array
                arch.body.each{ |statement|
                    expect(statement).to be_kind_of(VHDL::AST::AssociationStatement).or be_kind_of(VHDL::AST::AssignStatement).or be_kind_of(VHDL::AST::InstantiateStatement)
                    case statement
                    when VHDL::AST::AssignStatement
                        expect(statement.dest.decl).to be_kind_of(VHDL::AST::Port).or be_kind_of(VHDL::AST::SignalDeclaration)
                        expect(statement.source.decl).to be_kind_of(VHDL::AST::Port).or be_kind_of(VHDL::AST::SignalDeclaration).or be_kind_of(VHDL::AST::BinaryExp)
                        if statement.source.class == VHDL::AST::BinaryExp
                            expect(statement.source.operand1.decl).to be_kind_of(VHDL::AST::Port).or be_kind_of(VHDl::AST::SignalDeclaration)
                            expect(statement.source.operand2.decl).to be_kind_of(VHDL::AST::Port).or be_kind_of(VHDl::AST::SignalDeclaration)
                            expect(statement.source.operator.decl).to be_kind_of(VHDL::AST::Operator)
                        end
                    when VHDL::AST::InstantiateStatement
                        expect(statement.name).to be_kind_of VHDL::AST::Ident
                        expect(statement.entity).to be_kind_of VHDL::AST::Entity
                        expect(statement.arch).to be_kind_of VHDL::AST::Architecture
                        expect(statement.lib).to be_kind_of VHDL::AST::Ident
                        expect(statement.port_map).to be_kind_of VHDL::AST::PortMap
                        statement.port_map.association_statements.each{ |asso_stmt| 
                            expect(asso_stmt).to be_kind_of VHDL::AST::AssociationStatement
                            expect(asso_stmt.dest.decl).to be_kind_of(VHDL::AST::Port).or be_kind_of(VHDL::AST::SignalDeclaration)
                            expect(asso_stmt.source.decl).to be_kind_of VHDL::AST::Port 
                        }
                    end
                }
            }
        end
    end
    
end