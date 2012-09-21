# encoding: utf-8
require 'compile/external'

def run_as(user, &block)
  u = (user.is_a? Integer) ? Etc.getpwuid(user) : Etc.getpwnam(user)

  io_read, io_write = IO.pipe

  pid = Process.fork do
  	io_read.close 

  	Process::Sys.setgid(u.gid)
    Process::Sys.setuid(u.uid)

    result = block.call(user)

    Marshal.dump(result, io_write)
  end

  io_write.close
  result = io_read.read

  Process.wait(pid)

  Marshal.load(result)
end

def useradd(sandbox_id, dhome = '/mnt/sandbox')
	command = ['/usr/sbin/useradd', sandbox_id, "-m", "-b #{dhome}", "--no-user-group", "-g sandbox", "--shell /bin/bash" ]

	TenxLabs::External.execute(command.join(' ')) do |line|
		puts line
	end
end

def userdel(sandbox_id, dhome = '/mnt/sandbox')
	command = ['/usr/sbin/userdel', '-f', "#{sandbox_id}" ]
	res = TenxLabs::External.execute(command.join(' '), false)

	puts command.join(' ')
	puts res.inspect

	command = ['/bin/rm', '-Rf', "#{dhome}/#{sandbox_id}" ]
	res = TenxLabs::External.execute(command.join(' '), false)

	puts command.join(' ')
	puts res.inspect
end

def generate_sandbox_id(length=24)
	_chars =  [('a'..'z'),('0'..'9')].map{|i| i.to_a}.flatten
	(0...length).map{ _chars[rand(_chars.length)] }.join
end

def sandbox_path(sandbox_id, file_name = nil, root = '/mnt/sandbox')
	sandbox_path = File.join(root, sandbox_id)

	if file_name
		return File.join(sandbox_path, file_name)
	end

	return sandbox_path
end

def sandbox_file(sandbox_id, file, content, mod = nil)
	file_name = sandbox_path(sandbox_id, file)
	File.open(file_name, 'w') do |f|
		f.puts content

		f.chmod(mod) if mod
	end

	user = Etc.getpwnam(sandbox_id)
	group = Etc.getgrnam('sandbox')
end

def ssh_identity(sandbox_id, key)
	dot_ssh = sandbox_path(sandbox_id, ".ssh")

	Dir.mkdir(dot_ssh, 0700)

	sandbox_file(sandbox_id, ".ssh/identity", key, 0600)
end