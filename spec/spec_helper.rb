require 'rspec'

require 'terrenv'
# from thor spec helper
def capture(stream)
  begin
    stream = stream.to_s
    eval "$#{stream} = StringIO.new"
    yield
    result = eval("$#{stream}").string
  ensure
    eval("$#{stream} = #{stream.upcase}")
  end

  result
end

def cleanup
  FileUtils.rm 'TerraformFile'
  FileUtils.rm_rf 'terraform-production'
  FileUtils.rm_rf 'terraform-staging'
  FileUtils.rm_rf '.terraform'
  FileUtils.rm_rf 'terraform.tfvars'
end
