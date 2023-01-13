#! /usr/env/bin ruby

module VHDL
    module AST

        class Work 
            # Current library, known entities are stored in it in the form of decorated ASTs.
            # "entities" attribute is Hash type variable containing known entities associated with their name as the hash key.
            attr_accessor :entities

            def initialize *ent
                @entities = {}
                if ent != []
                    ent.each{|e| @entities[e.name] = e}
                end
            end
        
            def export
                f = File.new(".work", "w")
                f.puts(Marshal.dump(self))
                f.close
            end

            def import
                f = File.new(".work", "r")
                self.entities = Marshal.load(f).entities
                f.close
            end

            def add ent
                @entities[ent.name] = ent
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

        Root            =   Struct.new(*:entity, *:architectures)
        Entity          =   Struct.new(:name, *:ports, *:architectures)
        Port            =   Struct.new(:name, :port_type, :data_type, :value)
        Architecture    =   Struct.new(:name, :entity, :body)

        PortMap         = Struct.new(*:assign_commands)

        AssignCommand   =   Struct.new(:dest, :source)
        InstantiateCommand = Struct.new(:name, :entity, :arch, :lib, :port_map)
        # Add behavioral expressions classes necessary to parse the architecture body
    end
end