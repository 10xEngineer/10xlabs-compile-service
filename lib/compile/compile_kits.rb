# encoding: utf-8
require 'ap'

def get_compile_kits(compile_root = '/opt/compile')
	registry = {}

	_kits = Dir.entries(compile_root).select {|entry| File.directory? File.join(compile_root,entry) and !(entry =='.' || entry == '..') }

	# build compile kit list
	_kits.each do |kit_dir|
		next unless is_valid_compile_kit?(File.join(compile_root, kit_dir))

		registry[kit_dir] = {
			:allows => [],
			:depends_on => []
		}
	end

	_kits.each do |kit_dir|
		dependencies = kit_depends_on(File.join(compile_root, kit_dir))

		dependencies.each do |d| 
			registry[d][:allows] << kit_dir
			registry[kit_dir][:depends_on] << d
		end
	end

	ap registry

	registry
end

def kit_depends_on(kit_path)
	depends_file = File.join(kit_path, "etc/depends")

	depends_on = []

	if File.exists?(depends_file)
		dependencies = File.open(depends_file, &:readline).strip

		depends_on = depends_on + dependencies.split(',')
	end

	depends_on
end

def is_valid_compile_kit?(kit_path)
	files = ["bin", "etc/version"]

	files.each do |f|
		file_path = File.join(kit_path, f)
		return false unless File.exists?(file_path)
	end

	true
end