require 'optparse'
require "../lib/vhdl.rb"
require 'uri'

# TODO : C'est un exécutable Ruby ayant pour objectif de parser un code source VHDL. Se renseigner sur les appels système et les outils pour faire des applications OS avec du Ruby (ligne de commande, ...)
# Pistes d'outils : optparse, distribution en gem

@options = {}
args = {}

OptionParser.new do |opts|

    Version = "Hyle 0.1.0a (Feb 2023)"

    opts.on("-v", "--verbose", "Show extra information.") do
        @options[:verbose] = true
    end

    opts.on("-V", "--version", "Show used program current version.") do
        puts Version
    end

    opts.on("-p", "--parse=file1,file2,...", Array, "Parse a vhdl file which path is in arguments.") do  |f|
       @options[:parse] = true 
       args[:files] = f
    end

    opts.on("-o", "--output=path", "Store the generated data to a specific file, specifying its path in arguments.") do |p|
        puts "Warning : Still WIP, le .work will be stored next to this script."
        @options[:output] = true
        args[:output]=p
    end
end.parse!

if @options[:parse]

    # ? : Parallélisable ? En soit pour le lexing et le parsing sûrement car se fait sur des fichiers différents. Le visiteur nécessitera un accès à la même lib donc plus compliqué, tout de même faisable avec un sémaphore mais à voir si on y gagne vraiment, ce sera surtout our de gros fichiers, pour le moment on en est vraiment pas là.

    if @options[:verbose]
        args[:files].each { |f|
            VHDL::Visitor.new.visitAST(VHDL::Parser.new.parse(VHDL::Lexer.new.tokenize(IO.read(f))))
        }
    else 
        args[:files].each { |f| # ! : Permettra aussi le timing de chaque phase à l'avenir, toujours intéressant
            puts "Loading file #{f}"
            str = IO.read(f)
            print "Lexical analysis......"
            tokens = VHDL::Lexer.new.tokenize(str)
            puts "OK"
            print "Parsing..............."
            ast = VHDL::Parser.new.parse(tokens)
            puts "OK"
            print "Contextual Analysis..."
            VHDL::Visitor.new.visitAST(ast)
            puts "OK"
            puts "Job terminated successfully !"
        }
    end
end