require 'spec_helper'
require 'terrenv/cli'

describe Terrenv::CLI do
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

      it 'creates "terraform-staging/terraform.tfvars"' do
        expect(File.exists?("terraform-staging/terraform.tfvars")).to be true
      end

      it 'creates "terraform-production" directory' do
        expect(Dir.exists?('terraform-production')).to be true
      end

      it 'creates "terraform-production/terraform.tfvars"' do
        expect(File.exists?("terraform-production/terraform.tfvars")).to be true
      end

      it 'creates symlink ".terraform" pointing to .???' do
        expect(File.readlink('.terraform')).to eq('terraform-staging')
      end

      it 'creates unpointed symlink "terraform.tfvars"' do
        expect(File.readlink('terraform.tfvars')).to eq('terraform-staging/terraform.tfvars')

      end
      after(:all) { cleanup }
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
      it 'switches to terraform-production' do
        subject.use 'production'
        expect(File.readlink('.terraform')).to eq 'terraform-production'
      end
      it 'does not use non-existent environments' do
        subject.use 'non-existent'
        expect(File.readlink('.terraform')).not_to eq 'terraform-non-existent'
      end
      after(:all) { cleanup }
    end
  end
  describe '#current_env' do
    context '' do
      let(:environment) { subject.send(:current_env) }
      before do
        FileUtils.cp 'spec/test/resources/TerraformFile', './'
        subject.apply
      end
      it 'current environemnt should be staging' do
        expect(environment).to eq 'staging'
      end
      after(:all) { cleanup }
    end
  end
  # TODO: Test when environment in Terrafile is not specified
  # require 'stringio'
  # describe '#init' do
  #   context '' do
  #     let(:output) { capture(:stdout) { subject.init } }
  #     before do
  #       project = StringIO.new("rspec\n")
  #       bucket = StringIO.new("somebucket\n")
  #       region = StringIO.new("someregion\n")
  #     end
  #     it ''
  #   end
  # end

end
