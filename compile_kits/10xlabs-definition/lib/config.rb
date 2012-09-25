# encoding: utf-8

require 'yajl'

# TODO how to get compile kit name
def compile_kit_name
	File.basename(File.expand_path("../../", __FILE__))
end

def get_config
	kit_name = compile_kit_name
	config_file = "/etc/10xlabs-compile.json"

	config = {}

	if File.exists? config_file
		config = Yajl::Parser.parse(File.open(config_file))
	end


	# override with environment variables
	config["endpoint"] = ENV['MICROCLOUD'] if ENV['MICROCLOUD']

	config
end