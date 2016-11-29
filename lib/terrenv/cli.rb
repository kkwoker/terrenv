#!/usr/bin/env ruby
require 'thor'
require 'yaml'
require 'terrenv/version'

module Terrenv
  class CLI < Thor
    map %w[--version -v] => :__print_version

    desc "--version, -v", "print the version"
    def __print_version
      puts Terrenv::VERSION
    end

    desc "apply", "Applies configuration from TerraformFile"
    def apply
      puts 'Creating environments'
      begin
        settings = YAML.load(File.read('TerraformFile'))
      rescue
        puts "Couldn't find TerraformFile, did you initialize it?"
        exit 1
      end
      # TODO Delete environments not specified
      settings['environments'].each do |env|
        create(env)
        use(env)
        remote_setup
      end
    end

    desc "use [ENV_NAME]", "Switch to an env"
    def use(environment)
      state_dir = state_dir_format(environment)
      puts "Using environment #{ state_dir }"
      if Dir.exists?(state_dir)
        FileUtils.rm('.terraform', force: true)
        # TODO: if .terraform exists and is not a soft link, this silently fails
        FileUtils.ln_s(state_dir, '.terraform', force: true)
        FileUtils.rm('terraform.tfvars', force: true)
        FileUtils.ln_s("#{state_dir}/terraform.tfvars", 'terraform.tfvars', force: true)
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
      settings['environments'] = ['staging']
      File.open('TerraformFile', 'w') { |file| file.write(settings.to_yaml) }
    end
    private
    def delete(environment)
      # TODO: Deleted environment can still be in use
      state_dir = state_dir_format(environment)
      FileUtils.rm_rf(state_dir)
    end
    def create(env)
      state_dir = state_dir_format(env)
      if not File.exists?(state_dir)
        Dir.mkdir(state_dir)
        FileUtils.touch("#{state_dir}/terraform.tfvars")
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
      File.readlink('.terraform')[10..-1]
    end
  end
end
