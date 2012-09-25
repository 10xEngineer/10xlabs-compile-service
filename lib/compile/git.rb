# encoding: utf-8
require 'compile/external'
require 'compile/utils'

# FIXME use ssh_identity to access private repositories

def sync_repo(sandbox_id, source_url, ssh_identity = nil)
	raise "Invalid repository format" unless valid_repository?(source_url, ssh_identity)

	target_path = sandbox_path(sandbox_id, 'repo')
	if File.exists? target_path
		command = ["cd #{target_path} &&", 'git', 'pull']
		res = TenxLabs::External.execute(command.join(' '), false)
	else
		command = ['git', 'clone', source_url, 'repo']
		res = TenxLabs::External.execute(command.join(' '), false)
	end

	return true if res[0] == 0
end

def valid_repository?(source_url, ssh_identity)
	command = ['git','ls-remote', source_url]

	res = TenxLabs::External.execute(command.join(' '), false)

	return true if res[0] == 0

	false
end