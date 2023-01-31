#! /usr/env/bin ruby    

require_relative 'ast_vhdl.rb'

module VHDL

    class Visitor 
        # Visitor's goal is to decorate the given AST and detect any contextual error, including type errors.
        attr_accessor :id_tab, :ent_name, :actual_lib

        def initialize
            @id_tab = Hash.new
            @actual_lib = VHDL::AST::Work.new 
        end

        def visitAST ast
            print "Contextual analysis........"

            @actual_lib.import
            
            visitEntity ast.entity
            ast.architectures.each{|arch| visitArch arch}

            @actual_lib.add ast.entity
            @actual_lib.export

            puts "OK"
            puts "Contextual analysis succesfully terminated !"
            return ast
        end
        
        def visitEntity subAst
            @ent_name = subAst.name.name
            @id_tab[subAst.name.name] = subAst
            visitPorts subAst.ports 
        end

        def visitPorts subAst
            subAst.each{|e| visitPort e}
        end
        
        def visitPort subAst
            @id_tab[subAst.name.name] = subAst
        end

        def visitArch subAst
            
            subAst.entity = @id_tab[subAst.entity.name]
            if subAst.entity.architectures == nil
                subAst.entity.architectures = [subAst]
            else    
                subAst.entity.architectures << subAst
            end
            visitArchDecl subAst
            visitArchBody subAst
        end

        def visitArchDecl subAst

        end

        def visitArchBody subAst
            subAst.body.each { |line|
                visitExp line
            }
        end

        # TODO : Reprendre car pas bon dans la structure (remplacement d'un token par un nom avant de le remplacer par une entité...)
        def visitInstantiateStatement exp
            exp.name = exp.name.name
            if exp.lib.name == "work"
                exp.entity = @actual_lib.entities[exp.entity.name]
                pp exp.entity
                exp.arch = exp.entity.architectures.select{ |arch|
                    arch.name.name == exp.arch.name
                } 
                if exp.arch == []
                    raise "Error : Architecture not found for instanciation of #{exp.name}."
                elsif exp.arch.length > 1 
                    raise "Error : Multiple architectures found in entity #{exp.entity.name} for instanciation of #{exp.name}."
                else 
                    exp.arch = exp.arch[0] # On évite ici d'avoir un tableau à traiter par la suite.
                end

            else
                raise "Error : Only \"work\" library allowed in the current version. See #{exp.name} instance declaration of entity #{exp.entity}."
            end
            visitPortMap exp.port_map, exp.entity
            # TODO : Verify wiring (data and port type) and decorate the AST (replace names by direct references).
        end

        def visitPortMap exp, ent
            exp.association_statements.each{|statement| 
                # Decorate the AST replacing names by references to objects from work lib
                statement.dest = id_tab[statement.dest.name]
                statement.source = ent.ports.select{|p| p.name.name == statement.source.name}[0] 
                # Test data and port type validity for port_map expression.
                testTypeValidity statement
            }
        end

        def visitExp exp
            case exp
            when VHDL::AST::AssociationStatement # En théorie ne se retrouve jamais ici, ce n'est pas un Statement du même niveau, il intervient aussi dans les switch case certainement traité dans une autre méthode du Visiteur à ce moment.
                visitAssociateStatement exp
                #testTypeValidity exp
            when VHDL::AST::AssignStatement
                # Contextual verification
                visitAssignStatement exp
                #testTypeValidity exp # Also replaces name by references link between objects
            when VHDL::AST::InstantiateStatement
                visitInstantiateStatement exp
            # when VHDL::AST::PortMap # En théorie pas nécessaire ici car toujours précédé d'une InstantiateStatement (pas au même niveau dans l'AST que les autres commandes)
            #     visitPortMap exp 
                # exp.association_statements.each{|c| testTypeValidity c}
            else
                raise "Error : unknown expression in architecture body"
            end
        end

        def visitAssignStatement exp
            testTypeValidity exp
        end

        def visitAssociateStatement exp
            testTypeValidity exp
        end

        def testTypeValidity exp
            case exp # Different conditions for a valid expression, also different form to test (match it up in the future)
            when VHDL::AST::AssociationStatement  
                if exp.dest.data_type == exp.source.data_type
                    if exp.dest.port_type == exp.source.port_type
                        return true
                    else 
                        raise "Error : ports #{exp.dest.name} and #{exp.source.name} are from same port type and can't be wired together."
                    end
                else 
                    raise "Error : ports #{exp.dest.name} and #{exp.source.name} don't ave the same data_type and can't be wired together."
                end
            when VHDL::AST::AssignStatement
                if id_tab[exp.dest.name].data_type == id_tab[exp.source.name].data_type
                    if id_tab[exp.dest.name].port_type != id_tab[exp.source.name].port_type
                        # AST decoration
                        exp.dest = id_tab[exp.dest.name] 
                        exp.source = id_tab[exp.source.name]
                        return true
                    else 
                        raise "Error : ports #{exp.dest.name} and #{exp.source.name} are from same port type and can't be wired together."
                    end
                else
                    raise "Error : ports #{exp.dest.name} and #{exp.source.name} don't ave the same data_type and can't be wired together."
                end
            end
        end
    end
end