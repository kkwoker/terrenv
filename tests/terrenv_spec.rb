require_relative './rspec_helper'
require_relative '../lib/terrenv'

describe TerrEnv do
  it 'lists all environments' do
    TerrEnv.list
  end
end

