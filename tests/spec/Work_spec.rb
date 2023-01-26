require "../lib/vhdl.rb"

# TODO : Reste les fonctions delete et update mais elles ne sont pas utilisées dans le programme.

RSpec.describe VHDL::AST::Work do
    
    before(:each) do 
        @work = VHDL::AST::Work.new
        @elt = VHDL::AST::Entity.new(VHDL::AST::Ident.new(VHDL::AST::Token.new(:test, 'test', 1)))
    end

    it 'creates a Work class' do
        expect(@work).to be_kind_of VHDL::AST::Work       
        expect(@work.entities).to be_kind_of Hash 
    end

    it 'can export contained data into a file' do
        expect(@work).to respond_to :export
    end

    it 'can import stored data on a file' do
        expect(@work).to respond_to :import
    end

    it 'allow to add more data to those contained' do
        expect(@work).to respond_to :add
    end

    it 'allow to delete data from those contained' do
        expect(@work).to respond_to :delete
    end

    it 'responds correctly when we add an Ident in the hash' do
        expect(@work.add(@elt)).to eq @elt
        expect(@work.entities['test']).to eq @elt
    end

    it 'responds correctly to the export demand' do
        @work.add @elt
        expect(@work.export).to eq nil
        expect(File.exists?($DEF_LIB)).to eq true
    end

    it 'responds correctly to the import demand' do
        expect(@work.import).to have_key('test')
        expect(@work.entities['test']).to eq @elt
    end

end