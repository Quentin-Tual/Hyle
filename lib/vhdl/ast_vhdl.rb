#! /usr/env/bin ruby

module VHDL
    module AST
        $DEF_LIB = ".work"
        
        Token = Struct.new(:kind, :val, :line)

        Root                    =   Struct.new(*:entity, *:architectures)
        Entity                  =   Struct.new(:name, *:ports, *:architectures)
        Port                    =   Struct.new(:name, :port_type, :data_type, :value)
        Architecture            =   Struct.new(:name, :entity, :body)
        PortMap                 =   Struct.new(*:association_statements)
        
        Ident                   =   Struct.new(:token) do # TODO : Ajouter des méthodes pour accéder à certaines informations du token plus rapidement, ou transformer ses informations.
            def name 
                self.token.val
            end
        end
        AssociationStatement    =   Struct.new(:dest, :source)
        AssignStatement         =   Struct.new(:dest, :source)
        InstantiateStatement    = Struct.new(:name, :entity, :arch, :lib, :port_map)
        # Add behavioral expressions classes necessary to parse the architecture body

        class Work 
            # Current library, known entities are stored in it in the form of decorated ASTs.
            # "entities" attribute is Hash type variable containing known entities associated with their name as the hash key.
            attr_accessor :entities

            def initialize *ent
                @entities = {}
                if ent != []
                    ent.each{|e| @entities[e.name.name] = e}
                end
            end
        
            def export
                f = File.new($DEF_LIB, "wb")
                f.puts(Marshal.dump(self))
                f.close
            end

            def import
                if File.exists?($DEF_LIB)
                    f = File.new($DEF_LIB, "rb")
                    self.entities = Marshal.load(f).entities
                    f.close
                    return self.entities
                else 
                    puts "Warning : no library found, a .work will be created."
                end
            end

            def add ent
                @entities[ent.name.name] = ent
            end

            def delete ent
                @entities.delete ent.name
            end

            def update ent
                self.import
                add ent
                self.export
            end
        end

        
    end
end