#! /usr/env/bin ruby    

require_relative 'lexer_vhdl.rb'

# TODO : Ajouter une couche de la classe Ident dans l'AST. Finir l'intégration en adaptant le code aux objets Ident déjà instanciés. Ajouter des méthodes en fonction des besoin dans la classe Ident.

# TODO : Faire un deparser permettant de générer du VHDl à partir d'un AST, cela permet de vérifier les éventuels doublons d'objets dans un AST.

module VHDL
    
    class Parser

        def initialize
            @tokens = nil
            @ast = nil
        end

        def parse str
            #print "Lexical verification......."
            @tokens = Lexer.new.tokenize(str) 
            # pp @tokens # Uncomment for debug
            #puts "OK"
            #print "Parsing...................."
            @ast = AST::Root.new(parse_entity, parse_architectures)
            #puts "OK"
            #puts "Parsing succesfully terminated !"
            @ast
        end

        def parse_entity
            expect :entity
            ret = AST::Entity.new(AST::Ident.new(expect(:ident)), parse_ports)
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
                    name = AST::Ident.new(expect(:ident))
                    expect :colon
                    # TODO : On pourrait ici aussi créer une classe de plus en terme de couche (comme Ident). Un type nommé "type" sous la forme d'une énumération pouvant prendre un nombre prédéterminé de valeurs différentes.
                    port_type = expect(:in, :out).val 
                    data_type = expect(:type).val
                    expect :semicol, :c_parent # 2 possibilités au même instant, ne créant pas de nouvelle branche dans l'arbre de décision (fin de branchement/chemin parallèle)
                    ports.append(AST::Port.new(name, port_type, data_type))
                end
                return ports
            end
        end

        def parse_architectures
            archs = []
            while show_next != nil
                if show_next.kind == :architecture
                    archs << parse_arch_body 
                else 
                    break
                end
            end
            return archs
        end

        def parse_arch_body
            expect :architecture
            name = AST::Ident.new(expect(:ident))
            expect :of
            ent = AST::Ident.new(expect(:ident))
            expect :is
            parse_arch_declarations
            expect :begin
            del_next_new_line
            statements = []
            while show_next.kind != :end
                statements << parse_arch_statements
            end 
            expect :end
            expect :architecture
            expect :semicol
            del_next_new_line
            return AST::Architecture.new(name, ent, statements)
        end

        def parse_arch_declarations # Still WIP

        end

        def parse_arch_statements
            next_line = show_next_line
            next_line_kinds = next_line.collect {|x| x.kind}
            case next_line_kinds
                # Component instanciation
                in [:ident, :colon, :entity, *] 
                    name = AST::Ident.new(next_line[0])
                     # Gives the name of the Instantiated object
                    lib = AST::Ident.new(next_line[3]) # Gives the lib in which entity is declared
                    ent = AST::Ident.new(next_line[5]) # Gives the name of entity Instantiated
                    arch = AST::Ident.new(next_line[7]) # Gives the architectures name to use (if multiples declared in lib)
                    if show_next.kind == :gen_map
                        puts "WIP"
                    end
                    del_next_new_line
                    expect :port_map
                    port_map = AST::PortMap.new([])
                    expect :o_parent
                    # Loop until :c_parent instead of :coma
                    while show_next.kind != :semicol
                        a = AST::Ident.new(expect :ident) # Create an AssignStatement class object with these information
                        expect :arrow
                        b = AST::Ident.new(expect :ident)
                        port_map.association_statements << AST::AssociationStatement.new(a, b)
                        expect :coma, :c_parent
                    end
                    expect :semicol
                    ret = AST::InstantiateStatement.new(name, ent, arch, lib, port_map)
                # Signal/Port assignement 
                in [:ident, :assign_sig, :ident, :semicol]
                    # Only create an object, visitor object in charge of contextual analysis will then replace the names by actual instantiated Port objects.
                    ret = VHDL::AST::AssignStatement.new(AST::Ident.new(next_line[0]), AST::Ident.new(next_line[2]))
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
