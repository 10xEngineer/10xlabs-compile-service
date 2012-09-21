# encoding: utf-8
require 'compile/compile_kits'
require 'compile/utils'
require 'compile/git'
require 'etc'

def sandbox_create(sandbox_id, kit, source_url, rsa_key)
	# TODO would be much nicer to have block with sandbox_id
	useradd(sandbox_id)

	run_as(sandbox_id) do 
		sandbox_file(sandbox_id, '.compile', kit)
		sandbox_file(sandbox_id, '.source_url', source_url)

		ssh_identity(sandbox_id, rsa_key)
	end
end

def sandbox_exec(sandbox_id, action, args = [])
	raise "Sandbox '#{sandbox_id} does not exists." unless File.exists?(sandbox_path(sandbox_id))

	kit_registry = get_compile_kits

	Dir.chdir(sandbox_path(sandbox_id)) do
		compile_kit = File.open('.compile', &:readline).strip

		synchronize_data(sandbox_id)

		if compile_kit.empty? or compile_kit == "detect"			
			# FIXME get default kit_list
			default_kits = ['vagrant', 'java', '10xlabs-definition']
			processed = []
			compile_list = []


			kits = default_kits
			while kits.length > 0
				_list = evaluate(sandbox_id, kits)

				compile_list = compile_list + _list

				processed = (processed + kits).uniq

				kits = _list
				_list.each do |k|
					kits = kits + kit_registry[k][:allows]
				end

				kits = kits - processed
			end

			# write actual compile list back to sandbox
			sandbox_file(sandbox_id, '.compile', compile_list.join(','))
		else
			compile_list = compile_kit.split(',')
		end

		puts compile_list.inspect

		# TODO run compilation
		compile_list = compile_kit
	end
end

def evaluate(sandbox_id, compile_list)
	_list = []

	compile_list.each do |compiler|
		res = run_compilation(sandbox_id, compiler, "detect", true)
		
		if res[0] == 0
			kits = res[1].strip.split('\n')[0].split(',')

			_list = _list + kits
		end		
	end

	_list
end

def run_compilation(sandbox_id, compile_kit, action, first_line = false)
	# TODO configurable
	compile_root = "/opt/compile"
	sandbox_root = sandbox_path(sandbox_id, 'repo')

	action_command = File.join(compile_root, compile_kit, 'bin/', action)

	return unless File.exists? action_command 

	res = [1, nil]

	Dir.chdir(sandbox_root) do
		res = run_as(sandbox_id) do
			command = [action_command, sandbox_root]

			res = TenxLabs::External.execute(command.join(' '), false) do |line|
				puts line unless action == "detect"
			end
		end
	end

	return res
end

def synchronize_data(sandbox_id)
	file_name = sandbox_path(sandbox_id, '.source_url')
	source_url = File.open(file_name, &:readline).strip
	sandbox_root = sandbox_path(sandbox_id)

	# FIXME check for http or GIT (git is now hardcoded)

	Dir.chdir(sandbox_root) do
		res = run_as(sandbox_id) do
			sync_repo(sandbox_id, source_url)
		end
	end
end