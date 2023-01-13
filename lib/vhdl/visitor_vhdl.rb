#! /usr/env/bin ruby    

require_relative 'ast_vhdl.rb'

module VHDL

    class Visitor 
        # Visitor's goal is to decorate the given AST and detect any contextual error, including type errors.
        attr_accessor :id_tab, :ent_name

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
            @ent_name = subAst.name
            @id_tab[subAst.name] = subAst
            visitPorts subAst.ports 
        end

        def visitPorts subAst
            subAst.each{|e| visitPort e}
        end
        
        def visitPort subAst
            @id_tab[subAst.name] = subAst
        end

        def visitArch subAst
            subAst.entity = @id_tab[subAst.entity]
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

        def visitInstantiateCommand exp
            exp.name = exp.name.val
            if exp.lib.val == "work"
                exp.entity = @actual_lib.entities[exp.entity.val]
                exp.arch = exp.entity.architectures.select{ |arch|
                    arch.name == exp.arch.val
                }
                if exp.arch == []
                    raise "Error : Architecture not found for instanciation of #{exp.name}."
                elsif exp.arch.length > 1 
                    raise "Error : Multiple architectures found in entity #{exp.entity.name} for instanciation of #{exp.name}."
                end
            else
                raise "Error : Only \"work\" library allowed in the current version. See #{exp.name} instance declaration of entity #{exp.entity}."
            end
            visitPortMap exp.port_map, exp.entity
            # TODO : Verify wiring (data and port type) and decorate the AST (replace names by direct references).
        end

        def visitPortMap exp, ent
            exp.assign_commands.each{|command| 
                # Decorate the AST replacing names by references to objects from work lib
                command.dest = id_tab[command.dest.val]
                command.source = ent.ports.select{|p| p.name == command.source.val}[0] 
                # Test data and port type validity for port_map expression.
                testTypeValidity command, :port_map
            }
        end

        def visitExp exp
            case exp
            when VHDL::AST::AssignCommand
                # Contextual verification
                testTypeValidity exp, :assign_sig # Also replaces name by references link between objects
            when VHDL::AST::InstantiateCommand
                visitInstantiateCommand exp
            when VHDL::AST::PortMap
                exp.assign_commands.each{|c| testTypeValidity c, :port_map} 
            else
                raise "Error : unknown expression in architecture body"
            end
        end

        def testTypeValidity exp, exp_type
            case exp_type # Different conditions for a valid expression, also different form to test (match it up in the future)
            when :port_map  
                if exp.dest.data_type == exp.source.data_type
                    if exp.dest.port_type == exp.source.port_type
                        return true
                    else 
                        raise "Error : ports #{exp.dest.name} and #{exp.source.name} are from same port type and can't be wired together."
                    end
                else 
                    raise "Error : ports #{exp.dest.name} and #{exp.source.name} don't ave the same data_type and can't be wired together."
                end
            when :assign_sig
                if id_tab[exp.dest.val].data_type == id_tab[exp.source.val].data_type
                    if id_tab[exp.dest.val].port_type != id_tab[exp.source.val].port_type
                        # AST decoration
                        exp.dest = id_tab[exp.dest.val] 
                        exp.source = id_tab[exp.source.val]
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