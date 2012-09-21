# encoding: utf-8
require 'compile/utils'
require 'compile/git'
require 'etc'

# TODO if kit == 'detect' - automatically invoice all base kit's detect + all expanded kits

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

	Dir.chdir(sandbox_path(sandbox_id)) do
		compile_kit = File.open('.compile', &:readline).strip

		synchronize_data(sandbox_id)

		if compile_kit.empty? or compile_kit == "detect"
			# TODO get default kit_list
			default_kits = ['vagrant', 'java', '10xlabs-definition']

			compile_list = evaluate(sandbox_id, default_kits)

			# TODO write it back to ~/.compile
		else
			compile_list = compile_kit.split(',')
		end

		# TODO run compilation
		compile_list = compile_kit
	end
end

def evaluate(sandbox_id, compile_list)
	_list = []

	compile_list.each do |compiler|
		res = run_compilation(sandbox_id, compiler, "detect")
		
		_list = _list + res[1].strip.split('\n')[0].split(',') if res[0] == 0
	end

	puts _list.inspect

	# TODO if [ -x "${compiler_root}/${kit_name}/bin/${command}" ]
		# TODO synchronize sandbox source
		# TODO su $sandbox_id -c "${compiler_root}/${kit_name}/bin/${command} $3 $4"

	_list
end

def run_compilation(sandbox_id, compile_kit, action)
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