#! /usr/env/bin ruby

module VHDL
    module AST
        $DEF_LIB = ".work"
        $DEF_TYPES = ["bit", "/bit_vector\(\d+ downto \d+\)/"] # Defines the allowed types in the VHDL parsed 
        $DEF_TYPES_SIZES = {"bit" => 1}
        $DEF_OP = ["and", "or", "xor", "not", "nand", "nor"]
        $DEF_OP_TYPES = {
            "and" => [["bit", "bit"],["bit_vector","bit_vector"]],
            "or" => [["bit", "bit"],["bit_vector","bit_vector"]],
            "xor" => [["bit", "bit"],["bit_vector","bit_vector"]],
            "not" => [["bit", "bit"],["bit_vector","bit_vector"]],
            "nand" => [["bit", "bit"],["bit_vector","bit_vector"]],
            "nor" => [["bit", "bit"],["bit_vector","bit_vector"]]
        }
        $DEF_OP_RET_TYPES = {
            "and" => {  ["bit", "bit"] => "bit",
                        ["bit_vector","bit_vector"] => "bit_vector"},
            "or" => {   ["bit", "bit"] => "bit",
                        ["bit_vector","bit_vector"] => "bit_vector"},
            "xor" => {  ["bit", "bit"] => "bit",
                        ["bit_vector","bit_vector"] => "bit_vector"},
            "not" => {  ["bit", "bit"] => "bit",
                        ["bit_vector","bit_vector"] => "bit_vector"},
            "nand" => { ["bit", "bit"] => "bit",
                        ["bit_vector","bit_vector"] => "bit_vector"},
            "nor" => {  ["bit", "bit"] => "bit",
                        ["bit_vector","bit_vector"] => "bit_vector"}
        }
        
        Token = Struct.new(:kind, :val, :line)

        Root                    =   Struct.new(*:entity, *:architectures)
        Entity                  =   Struct.new(:name, *:ports, *:architectures)
        Port                    =   Struct.new(:name, :port_type, :data_type) do
            def get_data_type_name
                return self.data_type.get_typename
            end
        end
        Architecture            =   Struct.new(:name, :entity, :decl, :body)
        PortMap                 =   Struct.new(*:association_statements)
        
        Ident                   =   Struct.new(:token, :decl) do 
            def name 
                self.token.val
            end
        end

        Type                    = Struct.new(:type_name,:size) do
            attr_accessor :type_name, :size

            def initialize type_name
                if $DEF_TYPES.collect{|ref| type_name.match?(ref)}.include?(true)
                    self.type_name = type_name.split("(")[0]
                    if $DEF_TYPES_SIZES[type_name].nil? # If the size is not dermined by the type 
                        # * : \/ Parsing from vector size to bit size below \/
                        self.size = type_name[/\d+/].to_i + 1 
                    else # Else, size for this type is known 
                        self.size = $DEF_TYPES_SIZES[type_name]
                    end
                else
                    raise "Error : Unknown type #{type_name} encountered."
                end
            end

            def == e
                if (self.type_name == e.type_name) and (self.size == e.size)
                    return true
                else 
                    return false
                end
            end

            def get_typename
                return self.type_name
            end
        end
        Operator                =   Struct.new(:op)
        SignalDeclaration       =   Struct.new(:name, :data_type) do 
            def get_data_type_name
                return self.data_type.get_typename
            end
        end

        AssociationStatement    =   Struct.new(:dest, :source)
        AssignStatement         =   Struct.new(:dest, :source)
        InstantiateStatement    =   Struct.new(:name, :entity, :arch, :lib, :port_map)

        UnaryExp                =   Struct.new(:operator, :operand, :ret_type)
        BinaryExp               =   Struct.new(:operand1, :operator, :operand2, :ret_type) 

        # Add behavioral expressions classes necessary to parse the architecture body
        GTECH_AST = {
            "and2_d" => AST::Entity.new(
                AST::Ident.new(AST::Token.new(:ident, "and2_d")), # Entity name
                [
                    AST::Port.new(AST::Ident.new(AST::Token.new(:ident, "i0")), "in", AST::Type.new("bit")),
                    AST::Port.new(AST::Ident.new(AST::Token.new(:ident, "i1")), "in", AST::Type.new("bit")),
                    AST::Port.new(AST::Ident.new(AST::Token.new(:ident, "o0")), "out", AST::Type.new("bit")),
                ],
                [AST::Architecture.new(
                    AST::Ident.new(AST::Token.new(:ident, "netenos"))
                )] # Arch name
            ),
            "or2_d" => AST::Entity.new(
                AST::Ident.new(AST::Token.new(:ident, "or2_d")), # Entity name
                [
                    AST::Port.new(AST::Ident.new(AST::Token.new(:ident, "i0")), "in", AST::Type.new("bit")),
                    AST::Port.new(AST::Ident.new(AST::Token.new(:ident, "i1")), "in", AST::Type.new("bit")),
                    AST::Port.new(AST::Ident.new(AST::Token.new(:ident, "o0")), "out", AST::Type.new("bit")),
                ],
                [AST::Architecture.new(
                    AST::Ident.new(AST::Token.new(:ident, "netenos"))
                )] # Arch name
            ),
            "xor2_d" => AST::Entity.new(
                AST::Ident.new(AST::Token.new(:ident, "xor2_d")), # Entity name
                [
                    AST::Port.new(AST::Ident.new(AST::Token.new(:ident, "i0")), "in", AST::Type.new("bit")),
                    AST::Port.new(AST::Ident.new(AST::Token.new(:ident, "i1")), "in", AST::Type.new("bit")),
                    AST::Port.new(AST::Ident.new(AST::Token.new(:ident, "o0")), "out", AST::Type.new("bit")),
                ],
                [AST::Architecture.new(
                    AST::Ident.new(AST::Token.new(:ident, "netenos"))
                )] # Arch name
            ),
            "nand2_d" => AST::Entity.new(
                AST::Ident.new(AST::Token.new(:ident, "nand2_d")), # Entity name
                [
                    AST::Port.new(AST::Ident.new(AST::Token.new(:ident, "i0")), "in", AST::Type.new("bit")),
                    AST::Port.new(AST::Ident.new(AST::Token.new(:ident, "i1")), "in", AST::Type.new("bit")),
                    AST::Port.new(AST::Ident.new(AST::Token.new(:ident, "o0")), "out", AST::Type.new("bit")),
                ],
                [AST::Architecture.new(
                    AST::Ident.new(AST::Token.new(:ident, "netenos"))
                )] # Arch name
            ),
            "nor2_d" => AST::Entity.new(
                AST::Ident.new(AST::Token.new(:ident, "nor2_d")), # Entity name
                [
                    AST::Port.new(AST::Ident.new(AST::Token.new(:ident, "i0")), "in", AST::Type.new("bit")),
                    AST::Port.new(AST::Ident.new(AST::Token.new(:ident, "i1")), "in", AST::Type.new("bit")),
                    AST::Port.new(AST::Ident.new(AST::Token.new(:ident, "o0")), "out", AST::Type.new("bit")),
                ],
                [AST::Architecture.new(
                    AST::Ident.new(AST::Token.new(:ident, "netenos"))
                )] # Arch name
            ),
            "not_d" => AST::Entity.new(
                AST::Ident.new(AST::Token.new(:ident, "not_d")), # Entity name
                [
                    AST::Port.new(AST::Ident.new(AST::Token.new(:ident, "i0")), "in", AST::Type.new("bit")),
                    AST::Port.new(AST::Ident.new(AST::Token.new(:ident, "o0")), "out", AST::Type.new("bit")),
                ],
                [AST::Architecture.new(
                    AST::Ident.new(AST::Token.new(:ident, "netenos"))
                )] # Arch name
            ) 
        }

        class Work 
            # Current library, known entities are stored in it in the form of decorated ASTs.
            # "entities" attribute is Hash type variable containing known entities associated with their name as the hash key.
            attr_accessor :entities

            def initialize *ent
                @entities = {}
                if ent != []
                    ent.each{|e| @entities[e.name.name] = e}
                end
                GTECH_AST.values.each{ |ent|
                    self.add ent
                }
            end
        
            def export
                f = File.new($DEF_LIB, "wb")
                f.puts(Marshal.dump(self))
                f.close
            end

            def import # ! Causes troubles by replacing what already exists in the work object, use a tmp variable ?
                if File.exists?($DEF_LIB)
                    f = File.new($DEF_LIB, "rb")
                    tmp = Marshal.load(f).entities
                    tmp.values.map{|ent| self.add ent}
                    f.close
                    return self.entities
                else 
                    puts "Warning : no default library found, a .work will be created."
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