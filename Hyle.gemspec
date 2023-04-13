Gem::Specification.new do |spec|
  spec.name        = 'Hyle'
  spec.version     = '0.1.0'
  spec.summary     = 'A partial VHDL parser.'
  spec.description = 'Hyle is a partial VHDL parser developped in order to learn ruby and compilation. The parser does not support \'process\', \'component\' and \'generic\' keywords. Also it does not yet support library calling.'
  spec.authors     = ['QuentinT']
  spec.email       = 'quentintual2@gmail.com'
  spec.homepage    = 'https://github.com/Quentin-Tual/Hyle'
  spec.license     = 'MIT'

  spec.files       = Dir['lib/*','bin']
  spec.require_paths = ['lib','bin']
end
