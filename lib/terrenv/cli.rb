#!/usr/bin/env ruby
require 'bundler/setup'
require 'thor'
require 'yaml'

module Terrenv
  class CLI < Thor
    desc "list", "list all environments"
    def list
      puts "Listing all environments"
    end

    desc "delete [ENV_NAME]", "Remove environment"
    def delete(environment)
      # TODO: Deleted environment can still be in use
      state_dir = state_dir_format(environment)
      FileUtils.rm_rf(state_dir)
    end

    desc "use [ENV_NAME]", "Switch to an env"
    def use(environment)
      # TODO: Use can use environment that doesn't exist
      state_dir = state_dir_format(environment)
      puts "Using environment #{ state_dir }"
      FileUtils.rm('.terraform', :force => true)
      FileUtils.ln_s(state_dir, '.terraform', :force => true)
    end

    desc "apply", "Applies configuration from TerraformFile"
    def apply
      puts 'Creating environments'
      settings = YAML.load(File.read('TerraformFile'))
      settings['environments'].each do |env|
        create(env)
      end
    end

    desc "remote_setup", "setup remote"
    def remote_setup
      settings = YAML.load(File.read('TerraformFile'))
      puts "#{settings['project']}-#{current_env} remote being used"
      puts system("terraform remote config \
             -backend=s3 \
             -backend-config=\"bucket=#{settings['bucket']}\" \
             -backend-config=\"key=#{settings['project']}-#{current_env}.tfstate\" \
             -backend-config=\"region=#{settings['region']}\"")
    end

    desc "init", "setup project"
    def init
      settings = Hash.new
      settings['project'] = ask('Project name', 'empty')
      settings['bucket'] = ask('s3 bucket', 'telusdigital-terraform-states')
      settings['region'] = ask('bucket region', 'us-west-2')
      File.open('TerraformFile', 'w') { |file| file.write(settings.to_yaml) }
    end
    private
    def create(env)
      state_dir = state_dir_format(env)
      if not File.exists?(state_dir)
        Dir.mkdir(state_dir)
        FileUtils.touch("#{state_dir}/variables.tfvars")
        puts "Created directory: #{ state_dir }"
      end
    end
    def link_env_variable_file(env)
      state_dir = state_dir_format(env)
      FileUtils.touch("#{state_dir}/#{current_env}.tfvar")
      FileUtils.ln_s(".terraform-#{current_env}/#{current_env}.tfvars", "terraform.tfvars", :force => true)
    end

    def append_to_gitignore
    end
    def ask(question, default)
      print "#{question}(#{default}): "
      answer = STDIN.gets.chomp
      answer.empty? ? default : answer
    end
    def state_dir_format(name)
      "terraform-#{ name }"
    end

    def current_env
      File.readlink('.terraform')[11..-1]
    end
  end
end
