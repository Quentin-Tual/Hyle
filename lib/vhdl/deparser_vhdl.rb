

module VHDL 

    class DeParser
        attr_reader :dec_ast, :str
        
        def initialize dec_ast
            @dec_ast = dec_ast
            @str = ""
        end

        def deparse 
            @str << deparse_entity(@dec_ast.entity)
            @dec_ast.architectures.each{ |a|
                @str << deparse_arch(a)
            }
            return @str
        end

        def deparse_entity sub_ast
            tmp = "entity #{sub_ast.name.name} is\n"
            tmp << deparse_port(sub_ast.ports)
            tmp << "end #{sub_ast.name.name};\n\n"
        end

        def deparse_port sub_ast
            tmp = "\tport (\n"
            sub_ast.each{ |p|
                tmp << "\t\t#{p.name.name} : #{p.port_type} #{p.data_type};\n"
            }
            tmp.chop!.chop!
            tmp << "\n\t);\n"
        end

        def deparse_arch sub_ast
            tmp = "architecture #{sub_ast.name.name} of #{sub_ast.entity.name.name} is\n\n"
            # in theory, call here "deparse_arch_decl"
            tmp << "begin\n\n"
            tmp << deparse_arch_body(sub_ast.body)  
            tmp << "end architecture;\n\n"
        end

        def deparse_arch_body sub_ast
            tmp = ""
            if sub_ast != []
                sub_ast.each{ |s|
                    case s
                    when VHDL::AST::InstantiateStatement
                        tmp << deparse_instantiateStatement(s)
                    when VHDL::AST::AssignStatement
                        tmp << deparse_AssignStatement(s)
                    else
                        raise "Error : Unknown statement type. Corrupted Netlist."
                    end
                }
                tmp << "\n"
            else 
                return ""
            end            
        end

        def deparse_instantiateStatement statement
            tmp = "\t#{statement.name.name} : entity #{statement.lib.name}.#{statement.entity.name.name}(#{statement.arch.name.name})\n"
            tmp << deparse_portMap(statement.port_map)
        end

        def deparse_portMap port_map
            tmp = "\tport map (\n"
            tmp << deparse_associationStatement(port_map.association_statements) 
            tmp << "\t);\n"
        end

        def deparse_associationStatement association_statements
            tmp = ""
            association_statements.each{ |asso_state|
                tmp << "\t\t#{asso_state.dest.name.name} => #{asso_state.source.name.name},\n"
            }
            tmp.chop!.chop!
            tmp << "\n"
        end

        def deparse_AssignStatement statement
            tmp = "\t#{statement.dest.name.name} <= #{statement.source.name.name};\n"
        end

        def save
            f = File.new("rev_#{dec_ast.entity.name.name}.vhd", "w")
            f.puts(@str)
            f.close
        end 

        def save_as path
            f = File.new(path, "w")
            f.puts(@str)
            f.close
        end
    end
end 