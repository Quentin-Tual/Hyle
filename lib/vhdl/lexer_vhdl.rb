#! /usr/env/bin ruby

Token=Struct.new(:kind,:val)

module VHDL
    class Lexer
        def tokenize str
            tokens=[]
            while str.size > 0
                case str
                    when /\A\n/
                        tokens << Token.new(:new_line, $&)
                    when /\A\s/
                    when /\Aentity/
                        tokens << Token.new(:entity, $&)
                    when /\Ais/
                        tokens << Token.new(:is, $&)
                    when /\Aend/ 
                        tokens << Token.new(:end, $&)
                    when /\A;/
                        tokens << Token.new(:semicol, $&)
                    when /\Aarchitecture/
                        tokens << Token.new(:architecture, $&)
                    when /\Aof/
                        tokens << Token.new(:of, $&)
                    when /\Abegin/
                        tokens << Token.new(:begin, $&)
                    when /\Aport map/
                        tokens << Token.new(:port_map, $&)
                    when /\Aport/
                        tokens << Token.new(:port, $&)
                    when /\A\(/
                        tokens << Token.new(:o_parent, $&)
                    when /\A\)/
                        tokens << Token.new(:c_parent, $&)
                    when /\A\:/
                        tokens << Token.new(:colon, $&)
                    when /\Ain/
                        tokens << Token.new(:in, $&)
                    when /\Aout/
                        tokens << Token.new(:out, $&)
                    when /\Abit/ 
                        tokens << Token.new(:type, $&)
                    when /\A<=/
                        tokens << Token.new(:assign_sig, $&)
                    when /\A\:/
                        tokens << Token.new(:colon, $&)
                    when /\A\./
                        tokens << Token.new(:namespace_sep, $&)
                    when /\Ageneric map/
                        tokens << Token.new(:gen_map, $&)
                    when /\A=>/
                        tokens << Token.new(:assign, $&)
                    when /\A\,/
                        tokens << Token.new(:coma, $&)
                    when /\A[a-zA-Z]+(\w)*\b/ # Placed at the end of the case statement because other "kinds" could satisfy the regexp
                        tokens << Token.new(:ident, $&)
                    else
                        raise "Encountered unknown expression : #{str[0..-1]}"
                end
                str.delete_prefix!($&)
            end

            tokens
        end
        
    end
end

# Unit test 

# if $PROGRAM_NAME==__FILE__
#     txt=IO.read("./vhdl/test.vhd")
#     pp VHDL::Lexer.new.tokenize txt
# end