require 'spec_helper'
require 'terrenv/cli'

describe Terrenv::CLI do
  describe '#list' do
    context 'when called' do
      let(:output) { capture(:stdout) { subject.list } }
      it 'says it is listing all environments' do
        expect(output).to include('Listing all environments')
      end
    end
  end

  #describe '#create' do
  #  context '' do
  #    let(:output) { capture(:stdout) { subject.create 'testing' } }
  #    it 'creates a "terraform-testing" directory' do
  #      expect(output).to include('asdf')
  #    end
  #  end
  #end


  describe '#apply' do
    context '' do
      let(:output) { capture(:stdout) { subject.apply } }
      before { FileUtils.cp 'spec/test/resources/TerraformFile', './' }
      it 'says it is creating environments' do
        expect(output).to include('Creating environments...')
      end

      it 'creates "terraform-staging" directory' do
        expect(Dir.exists?('terraform-staging')).to be true
      end
      it 'creates "terraform-testing" directory' do
        expect(Dir.exists?('terraform-testing')).to be true
      end
      after(:all) do
        FileUtils.rm 'TerraformFile'
        FileUtils.rmdir 'terraform-staging'
        FileUtils.rmdir 'terraform-testing'
      end
    end
  end
end

