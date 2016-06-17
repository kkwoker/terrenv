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

  describe '#apply' do
    context '' do
      let(:output) { capture(:stdout) { subject.apply } }
      before(:all) { FileUtils.cp 'spec/test/resources/TerraformFile', './' }
      it 'says it is creating environments' do
        expect(output).to include('Creating environments')
      end

      it 'creates "terraform-staging" directory' do
        expect(Dir.exists?('terraform-staging')).to be true
      end

      it 'creates "terraform-staging/variables.tfvars"' do
        expect(File.exists?("terraform-staging/variables.tfvars")).to be true
      end

      it 'creates "terraform-testing" directory' do
        expect(Dir.exists?('terraform-testing')).to be true
      end

      it 'creates "terraform-testing/variables.tfvars"' do
        expect(File.exists?("terraform-testing/variables.tfvars")).to be true
      end
      after(:all) do
        FileUtils.rm 'TerraformFile'
        FileUtils.rm_rf 'terraform-staging'
        FileUtils.rm_rf 'terraform-testing'
        FileUtils.rm_rf '.terraform'
      end
    end
  end

  describe '#use' do
    context '' do
      let(:output) { capture(:stdout) { subject.use 'staging' }}
      before do
        FileUtils.cp 'spec/test/resources/TerraformFile', './'
        subject.apply
      end
      it 'says its using staging' do
        expect(output).to include('Using environment terraform-staging')
      end
      it 'creates ".terraform" softlink to terraform-staging' do
        expect(File.readlink('.terraform')).to eq 'terraform-staging'
      end
      it 'switches to terraform-testing' do
        subject.use 'testing'
        expect(File.readlink('.terraform')).to eq 'terraform-testing'
      end
      after(:all) do
        FileUtils.rm 'TerraformFile'
        FileUtils.rm_rf 'terraform-staging'
        FileUtils.rm_rf 'terraform-testing'
        FileUtils.rm_rf '.terraform'
      end
    end
  end

end
