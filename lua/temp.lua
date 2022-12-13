return function()
	local dir = "~/.config"
	local p = io.popen('find "' .. dir .. '" -type d') --Open directory look for files, save data in p. By giving '-type f' as parameter, it returns all files.
	for file in p:lines() do --Loop through all files
		print(file)
	end
end
