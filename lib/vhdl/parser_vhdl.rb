#! /usr/env/bin ruby    

require_relative 'lexer_vhdl.rb'
require_relative 'ast_vhdl.rb'

# TODO : Ajouter la prise en charge de l'instanciation de composants et donc par nécessité la prise en charge du dev modulaire (plusieurs fichiers, plusieurs entités, etc). Enregistrement de l'AST de tous les fichiers scannés dans un .work pour permettre la récupération et l'exploitation de ce dernier pour l'instanciation des composants.     

# TODO : Vérifier les doublons d'instances pour certains objets (arch, ent, etc). Voir avec JC si on ne sait pas comment s'y prendre.


module VHDL
    
    class Parser
        def parse str
            print "Lexical verification......."
            @tokens=Lexer.new.tokenize(str) 
            # pp @tokens # Uncomment for debug
            puts "OK"
            print "Parsing.................."
            @ast = AST::Root.new(parse_entity, parse_architecture)
            puts "OK"
            puts "Parsing succesfully terminated !"
            @ast
        end

        def parse_entity
            expect :entity
            ret = AST::Entity.new(expect(:ident).val, parse_ports)
            expect :semicol
            expect :end
            expect :ident
            expect :semicol
            del_next_new_line
            ret
            # Note : si on souhaite stocker la ou les architectures de l'entité dans cet objet, il est impossible de le faire ici. Il sera nécessaire de décorer l'AST avec une seconde passe ou lors de l'analyse de contexte.
        end

        def parse_ports
            expect :is
            if expect :port                
                expect :o_parent
                ports = []
                while show_next.kind != :semicol # Boucle jusqu'à la fin de la déclaration des ports
                    name = expect(:ident).val
                    expect :colon
                    port_type = expect(:in, :out).val
                    data_type = expect(:type).val
                    expect :semicol, :c_parent # 2 possibilités au même instant, ne créant pas de nouvelle branche dans l'arbre de décision (fin de branchement/chemin parallèle)
                    ports.append(AST::Port.new(name, port_type, data_type))
                end
                return ports
            end
        end

        def parse_architecture
            archs = []
            while show_next != nil
                if show_next.kind == :architecture
                    expect :architecture
                    name = expect(:ident).val
                    expect :of
                    ent = expect(:ident).val
                    expect :is
                    expect :begin
                    del_next_new_line
                    body = []
                    while show_next.kind != :end
                        body << parse_arch_body
                    end 
                    expect :end
                    expect :architecture
                    expect :semicol
                    del_next_new_line
                    archs << AST::Architecture.new(name, ent, body)
                else 
                    break
                end
            end
            return archs
        end

        def parse_arch_body
            next_line = show_next_line
            next_line_kinds = next_line.collect {|x| x.kind}
            case next_line_kinds
                # Component instanciation
                in [:ident, :colon, :entity, *] 
                    name = next_line[0]
                     # Gives the name of the Instantiated object
                    lib = next_line[3] # Gives the lib in which entity is declared
                    ent = next_line[5] # Gives the name of entity Instantiated
                    arch = next_line[7] # Gives the architectures name to use (if multiples declared in lib)
                    if show_next.kind == :gen_map
                        puts "WIP"
                    end
                    del_next_new_line
                    expect :port_map
                    port_map = AST::PortMap.new([])
                    expect :o_parent
                    # Loop until :c_parent instead of :coma
                    while show_next.kind != :semicol
                        a = expect :ident # Create an AssignCommand class object with these information
                        expect :assign
                        b = expect :ident
                        port_map.assign_commands << AST::AssignCommand.new(a, b)
                        expect :coma, :c_parent
                    end
                    expect :semicol
                    ret = AST::InstantiateCommand.new(name, ent, arch, lib, port_map)
                # Signal/Port assignement 
                in [:ident, :assign_sig, :ident, :semicol]
                    # Only create an object, visitor object in charge of contextual analysis will then replace the names by actual instantiated Port objects.
                    ret = AST::AssignCommand.new(next_line[0], next_line[2])
            else
                raise "ERROR : Expecting architecture body expression. Received unknown expression."
            end 
            del_next_new_line
            return ret
        end

        def show_next_line

            del_next_new_line

            ret = []
            until show_next.kind == :new_line
                ret << show_next 
                accept_it
            end

            return ret
        end

        def show_next
            @tokens.first # Renvoi le premier élément de la file (Array)
        end

        def accept_it
            @tokens.shift # supprime le premier élément de la file (Array)
        end

        def del_next_new_line
            while show_next != nil 
                if show_next.kind == :new_line
                    accept_it
                else 
                    return nil
                end
            end
        end

        def expect *expected_tok_kind # Arguments multiples sous forme d'Array
            del_next_new_line

            actual_kind = show_next.kind

            if expected_tok_kind.include? actual_kind
                ret = accept_it
            else 
                raise "ERROR : expecting token #{expected_tok_kind}. Received #{actual_kind}."
            end

            return ret
        end
    end
end
