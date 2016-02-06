require 'yaml'
require 'json-schema'
require 'credentials/passwordstore_provider'




class Runner
  
  schema = {
    "type" => "object",
    "required" => ["a"],
    "properties" => {
      "a" => {"type" => "integer"}
    }
  }

  data = {
    "a" => 5
  }

  JSON::Validator.validate(schema, data)
  def initialize(config_file: nil)
    default_file = File.join(Dir.home, '.drobots.yaml')
    @config_file = config_file || default_file
    @config = YAML.load_file(@config_file)

    
  end

  def drobots
    @drobots ||= @config['drobots'].map do |name, config|
      credential_provider = Credentials::PasswordstoreProvider.new(pass_name: config['passwordstore']['name'])
      Object.const_get("Drobots::#{name}").new(credential_provider)
    end
  end

  def run
    drobots.each(&:run)
  end
end
