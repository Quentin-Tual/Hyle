#! /usr/env/bin ruby

Token=Struct.new(:kind,:val,:line)

module VHDL
    class Lexer
        def tokenize str
            tokens=[]
            while str.size > 0
                num_line = 1
                case str
                    when /\A\n/
                        tokens << Token.new(:new_line, $&, num_line)
                        num_line += 1
                    when /\A\s/
                    when /\Aentity/
                        tokens << Token.new(:entity, $&, num_line)
                    when /\Ais/
                        tokens << Token.new(:is, $&, num_line)
                    when /\Aend/ 
                        tokens << Token.new(:end, $&, num_line)
                    when /\A;/
                        tokens << Token.new(:semicol, $&, num_line)
                    when /\Aarchitecture/
                        tokens << Token.new(:architecture, $&, num_line)
                    when /\Aof/
                        tokens << Token.new(:of, $&, num_line)
                    when /\Abegin/
                        tokens << Token.new(:begin, $&, num_line)
                    when /\Aport map/
                        tokens << Token.new(:port_map, $&, num_line)
                    when /\Aport/
                        tokens << Token.new(:port, $&, num_line)
                    when /\A\(/
                        tokens << Token.new(:o_parent, $&, num_line)
                    when /\A\)/
                        tokens << Token.new(:c_parent, $&, num_line)
                    when /\A\:/
                        tokens << Token.new(:colon, $&, num_line)
                    when /\Ain/
                        tokens << Token.new(:in, $&, num_line)
                    when /\Aout/
                        tokens << Token.new(:out, $&, num_line)
                    when /\Abit/ 
                        tokens << Token.new(:type, $&, num_line)
                    when /\A<=/
                        tokens << Token.new(:assign_sig, $&, num_line)
                    when /\A\:/
                        tokens << Token.new(:colon, $&, num_line)
                    when /\A\./
                        tokens << Token.new(:namespace_sep, $&, num_line)
                    when /\Ageneric map/
                        tokens << Token.new(:gen_map, $&, num_line)
                    when /\A=>/
                        tokens << Token.new(:arrow, $&, num_line)
                    when /\A\,/
                        tokens << Token.new(:coma, $&, num_line)
                    when /\A[a-zA-Z]+(\w)*\b/ # Placed at the end of the case statement because other "kinds" could satisfy the regexp
                        tokens << Token.new(:ident, $&, num_line)
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