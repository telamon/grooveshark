require 'spec_helper'

describe 'Grooveshark' do
  before do
    stub_init_session
  end

  it 'returns a new Client instance via shortcut' do
    gs = Grooveshark.new
    gs.should be_a Grooveshark::Client
    gs.session.should == '8d5e0200564abe281e7e98435e40ee16'
  end
end