gathering = false
function DebugTool()
    local player = game.Players.LocalPlayer
    local backpack = player:WaitForChild("Backpack")
    local debugTool = Instance.new("Tool")
    debugTool.Name = "Debug Tool"
    debugTool.RequiresHandle = true
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 4, 1)
    handle.Anchored = false
    handle.CanCollide = false
    handle.Material = Enum.Material.SmoothPlastic
    handle.BrickColor = BrickColor.new("Bright red")
    handle.Transparency = 1
    handle.Parent = debugTool
    local function onActivated()
        local mouse = player:GetMouse()
        local target = mouse.Target
        if target then
            -- Print the object's name and path
            print("Object Name: " .. target.Name)
            print("Object Path: " .. target:GetFullName())
        end
    end
    debugTool.Activated:Connect(onActivated)
    debugTool.Parent = backpack
    end
function exec()
    gathering = true
print("")
print("")
print("UNC CHECK")
print("")
print("")

local passes, fails, undefined = 0, 0, 0
local running = 0

local function getGlobal(path)
	local value = getfenv(0)

	while value ~= nil and path ~= "" do
		local name, nextValue = string.match(path, "^([^.]+)%.?(.*)$")
		value = value[name]
		path = nextValue
	end

	return value
end

local function test(name, aliases, callback)
	running += 1

	task.spawn(function()
		if not callback then
			print("⏺️ " .. name)
		elseif not getGlobal(name) then
			fails += 1
			warn("⛔ " .. name)
		else
			local success, message = pcall(callback)
	
			if success then
				passes += 1
				print("✅ " .. name .. (message and " • " .. message or ""))
			else
				fails += 1
				warn("⛔ " .. name .. " failed: " .. message)
			end
		end
	
		local undefinedAliases = {}
	
		for _, alias in ipairs(aliases) do
			if getGlobal(alias) == nil then
				table.insert(undefinedAliases, alias)
			end
		end
	
		if #undefinedAliases > 0 then
			undefined += 1
			warn("⚠️ " .. table.concat(undefinedAliases, ", "))
		end

		running -= 1
	end)
end

-- Header and summary

print("\n")

print("UNC Environment Check")
print("✅ - Pass, ⛔ - Fail, ⏺️ - No test, ⚠️ - Missing aliases\n")

task.defer(function()
	repeat task.wait() until running == 0

	local rate = math.round(passes / (passes + fails) * 100)
	local outOf = passes .. " out of " .. (passes + fails)

	print("\n")

	print("UNC Summary")
	print("✅ Tested with a " .. rate .. "% success rate (" .. outOf .. ")")
	print("⛔ " .. fails .. " tests failed")
	print("⚠️ " .. undefined .. " globals are missing aliases")
	Unc = rate
end)

-- Cache

test("cache.invalidate", {}, function()
	local container = Instance.new("Folder")
	local part = Instance.new("Part", container)
	cache.invalidate(container:FindFirstChild("Part"))
	assert(part ~= container:FindFirstChild("Part"), "Reference `part` could not be invalidated")
end)

test("cache.iscached", {}, function()
	local part = Instance.new("Part")
	assert(cache.iscached(part), "Part should be cached")
	cache.invalidate(part)
	assert(not cache.iscached(part), "Part should not be cached")
end)

test("cache.replace", {}, function()
	local part = Instance.new("Part")
	local fire = Instance.new("Fire")
	cache.replace(part, fire)
	assert(part ~= fire, "Part was not replaced with Fire")
end)

test("cloneref", {}, function()
	local part = Instance.new("Part")
	local clone = cloneref(part)
	assert(part ~= clone, "Clone should not be equal to original")
	clone.Name = "Test"
	assert(part.Name == "Test", "Clone should have updated the original")
end)

test("compareinstances", {}, function()
	local part = Instance.new("Part")
	local clone = cloneref(part)
	assert(part ~= clone, "Clone should not be equal to original")
	assert(compareinstances(part, clone), "Clone should be equal to original when using compareinstances()")
end)

-- Closures

local function shallowEqual(t1, t2)
	if t1 == t2 then
		return true
	end

	local UNIQUE_TYPES = {
		["function"] = true,
		["table"] = true,
		["userdata"] = true,
		["thread"] = true,
	}

	for k, v in pairs(t1) do
		if UNIQUE_TYPES[type(v)] then
			if type(t2[k]) ~= type(v) then
				return false
			end
		elseif t2[k] ~= v then
			return false
		end
	end

	for k, v in pairs(t2) do
		if UNIQUE_TYPES[type(v)] then
			if type(t2[k]) ~= type(v) then
				return false
			end
		elseif t1[k] ~= v then
			return false
		end
	end

	return true
end

test("checkcaller", {}, function()
	assert(checkcaller(), "Main scope should return true")
end)

test("clonefunction", {}, function()
	local function test()
		return "success"
	end
	local copy = clonefunction(test)
	assert(test() == copy(), "The clone should return the same value as the original")
	assert(test ~= copy, "The clone should not be equal to the original")
end)

test("getcallingscript", {})

test("getscriptclosure", {"getscriptfunction"}, function()
	local module = game:GetService("CoreGui").RobloxGui.Modules.Common.Constants
	local constants = getrenv().require(module)
	local generated = getscriptclosure(module)()
	assert(constants ~= generated, "Generated module should not match the original")
	assert(shallowEqual(constants, generated), "Generated constant table should be shallow equal to the original")
end)

test("hookfunction", {"replaceclosure"}, function()
	local function test()
		return true
	end
	local ref = hookfunction(test, function()
		return false
	end)
	assert(test() == false, "Function should return false")
	assert(ref() == true, "Original function should return true")
	assert(test ~= ref, "Original function should not be same as the reference")
end)

test("iscclosure", {}, function()
	assert(iscclosure(print) == true, "Function 'print' should be a C closure")
	assert(iscclosure(function() end) == false, "Executor function should not be a C closure")
end)

test("islclosure", {}, function()
	assert(islclosure(print) == false, "Function 'print' should not be a Lua closure")
	assert(islclosure(function() end) == true, "Executor function should be a Lua closure")
end)

test("isexecutorclosure", {"checkclosure", "isourclosure"}, function()
	assert(isexecutorclosure(isexecutorclosure) == true, "Did not return true for an executor global")
	assert(isexecutorclosure(newcclosure(function() end)) == true, "Did not return true for an executor C closure")
	assert(isexecutorclosure(function() end) == true, "Did not return true for an executor Luau closure")
	assert(isexecutorclosure(print) == false, "Did not return false for a Roblox global")
end)

test("loadstring", {}, function()
	local animate = game:GetService("Players").LocalPlayer.Character.Animate
	local bytecode = getscriptbytecode(animate)
	local func = loadstring(bytecode)
	assert(type(func) ~= "function", "Luau bytecode should not be loadable!")
	assert(assert(loadstring("return ... + 1"))(1) == 2, "Failed to do simple math")
	assert(type(select(2, loadstring("f"))) == "string", "Loadstring did not return anything for a compiler error")
end)

test("newcclosure", {}, function()
	local function test()
		return true
	end
	local testC = newcclosure(test)
	assert(test() == testC(), "New C closure should return the same value as the original")
	assert(test ~= testC, "New C closure should not be same as the original")
	assert(iscclosure(testC), "New C closure should be a C closure")
end)

-- Console

test("rconsoleclear", {"consoleclear"})

test("rconsolecreate", {"consolecreate"})

test("rconsoledestroy", {"consoledestroy"})

test("rconsoleinput", {"consoleinput"})

test("rconsoleprint", {"consoleprint"})

test("rconsolesettitle", {"rconsolename", "consolesettitle"})

-- Crypt

test("crypt.base64encode", {"crypt.base64.encode", "crypt.base64_encode", "base64.encode", "base64_encode"}, function()
	assert(crypt.base64encode("test") == "dGVzdA==", "Base64 encoding failed")
end)

test("crypt.base64decode", {"crypt.base64.decode", "crypt.base64_decode", "base64.decode", "base64_decode"}, function()
	assert(crypt.base64decode("dGVzdA==") == "test", "Base64 decoding failed")
end)

test("crypt.encrypt", {}, function()
	local key = crypt.generatekey()
	local encrypted, iv = crypt.encrypt("test", key, nil, "CBC")
	assert(iv, "crypt.encrypt should return an IV")
	local decrypted = crypt.decrypt(encrypted, key, iv, "CBC")
	assert(decrypted == "test", "Failed to decrypt raw string from encrypted data")
end)

test("crypt.decrypt", {}, function()
	local key, iv = crypt.generatekey(), crypt.generatekey()
	local encrypted = crypt.encrypt("test", key, iv, "CBC")
	local decrypted = crypt.decrypt(encrypted, key, iv, "CBC")
	assert(decrypted == "test", "Failed to decrypt raw string from encrypted data")
end)

test("crypt.generatebytes", {}, function()
	local size = math.random(10, 100)
	local bytes = crypt.generatebytes(size)
	assert(#crypt.base64decode(bytes) == size, "The decoded result should be " .. size .. " bytes long (got " .. #crypt.base64decode(bytes) .. " decoded, " .. #bytes .. " raw)")
end)

test("crypt.generatekey", {}, function()
	local key = crypt.generatekey()
	assert(#crypt.base64decode(key) == 32, "Generated key should be 32 bytes long when decoded")
end)

test("crypt.hash", {}, function()
	local algorithms = {'sha1', 'sha384', 'sha512', 'md5', 'sha256', 'sha3-224', 'sha3-256', 'sha3-512'}
	for _, algorithm in ipairs(algorithms) do
		local hash = crypt.hash("test", algorithm)
		assert(hash, "crypt.hash on algorithm '" .. algorithm .. "' should return a hash")
	end
end)

--- Debug

test("debug.getconstant", {}, function()
	local function test()
		print("Hello, world!")
	end
	assert(debug.getconstant(test, 1) == "print", "First constant must be print")
	assert(debug.getconstant(test, 2) == nil, "Second constant must be nil")
	assert(debug.getconstant(test, 3) == "Hello, world!", "Third constant must be 'Hello, world!'")
end)

test("debug.getconstants", {}, function()
	local function test()
		local num = 5000 .. 50000
		print("Hello, world!", num, warn)
	end
	local constants = debug.getconstants(test)
	assert(constants[1] == 50000, "First constant must be 50000")
	assert(constants[2] == "print", "Second constant must be print")
	assert(constants[3] == nil, "Third constant must be nil")
	assert(constants[4] == "Hello, world!", "Fourth constant must be 'Hello, world!'")
	assert(constants[5] == "warn", "Fifth constant must be warn")
end)

test("debug.getinfo", {}, function()
	local types = {
		source = "string",
		short_src = "string",
		func = "function",
		what = "string",
		currentline = "number",
		name = "string",
		nups = "number",
		numparams = "number",
		is_vararg = "number",
	}
	local function test(...)
		print(...)
	end
	local info = debug.getinfo(test)
	for k, v in pairs(types) do
		assert(info[k] ~= nil, "Did not return a table with a '" .. k .. "' field")
		assert(type(info[k]) == v, "Did not return a table with " .. k .. " as a " .. v .. " (got " .. type(info[k]) .. ")")
	end
end)

test("debug.getproto", {}, function()
	local function test()
		local function proto()
			return true
		end
	end
	local proto = debug.getproto(test, 1, true)[1]
	local realproto = debug.getproto(test, 1)
	assert(proto, "Failed to get the inner function")
	assert(proto() == true, "The inner function did not return anything")
	if not realproto() then
		return "Proto return values are disabled on this executor"
	end
end)

test("debug.getprotos", {}, function()
	local function test()
		local function _1()
			return true
		end
		local function _2()
			return true
		end
		local function _3()
			return true
		end
	end
	for i in ipairs(debug.getprotos(test)) do
		local proto = debug.getproto(test, i, true)[1]
		local realproto = debug.getproto(test, i)
		assert(proto(), "Failed to get inner function " .. i)
		if not realproto() then
			return "Proto return values are disabled on this executor"
		end
	end
end)

test("debug.getstack", {}, function()
	local _ = "a" .. "b"
	assert(debug.getstack(1, 1) == "ab", "The first item in the stack should be 'ab'")
	assert(debug.getstack(1)[1] == "ab", "The first item in the stack table should be 'ab'")
end)

test("debug.getupvalue", {}, function()
	local upvalue = function() end
	local function test()
		print(upvalue)
	end
	assert(debug.getupvalue(test, 1) == upvalue, "Unexpected value returned from debug.getupvalue")
end)

test("debug.getupvalues", {}, function()
	local upvalue = function() end
	local function test()
		print(upvalue)
	end
	local upvalues = debug.getupvalues(test)
	assert(upvalues[1] == upvalue, "Unexpected value returned from debug.getupvalues")
end)

test("debug.setconstant", {}, function()
	local function test()
		return "fail"
	end
	debug.setconstant(test, 1, "success")
	assert(test() == "success", "debug.setconstant did not set the first constant")
end)

test("debug.setstack", {}, function()
	local function test()
		return "fail", debug.setstack(1, 1, "success")
	end
	assert(test() == "success", "debug.setstack did not set the first stack item")
end)

test("debug.setupvalue", {}, function()
	local function upvalue()
		return "fail"
	end
	local function test()
		return upvalue()
	end
	debug.setupvalue(test, 1, function()
		return "success"
	end)
	assert(test() == "success", "debug.setupvalue did not set the first upvalue")
end)

-- Filesystem

if isfolder and makefolder and delfolder then
	if isfolder(".tests") then
		delfolder(".tests")
	end
	makefolder(".tests")
end

test("readfile", {}, function()
	writefile(".tests/readfile.txt", "success")
	assert(readfile(".tests/readfile.txt") == "success", "Did not return the contents of the file")
end)

test("listfiles", {}, function()
	makefolder(".tests/listfiles")
	writefile(".tests/listfiles/test_1.txt", "success")
	writefile(".tests/listfiles/test_2.txt", "success")
	local files = listfiles(".tests/listfiles")
	assert(#files == 2, "Did not return the correct number of files")
	assert(isfile(files[1]), "Did not return a file path")
	assert(readfile(files[1]) == "success", "Did not return the correct files")
	makefolder(".tests/listfiles_2")
	makefolder(".tests/listfiles_2/test_1")
	makefolder(".tests/listfiles_2/test_2")
	local folders = listfiles(".tests/listfiles_2")
	assert(#folders == 2, "Did not return the correct number of folders")
	assert(isfolder(folders[1]), "Did not return a folder path")
end)

test("writefile", {}, function()
	writefile(".tests/writefile.txt", "success")
	assert(readfile(".tests/writefile.txt") == "success", "Did not write the file")
	local requiresFileExt = pcall(function()
		writefile(".tests/writefile", "success")
		assert(isfile(".tests/writefile.txt"))
	end)
	if not requiresFileExt then
		return "This executor requires a file extension in writefile"
	end
end)

test("makefolder", {}, function()
	makefolder(".tests/makefolder")
	assert(isfolder(".tests/makefolder"), "Did not create the folder")
end)

test("appendfile", {}, function()
	writefile(".tests/appendfile.txt", "su")
	appendfile(".tests/appendfile.txt", "cce")
	appendfile(".tests/appendfile.txt", "ss")
	assert(readfile(".tests/appendfile.txt") == "success", "Did not append the file")
end)

test("isfile", {}, function()
	writefile(".tests/isfile.txt", "success")
	assert(isfile(".tests/isfile.txt") == true, "Did not return true for a file")
	assert(isfile(".tests") == false, "Did not return false for a folder")
	assert(isfile(".tests/doesnotexist.exe") == false, "Did not return false for a nonexistent path (got " .. tostring(isfile(".tests/doesnotexist.exe")) .. ")")
end)

test("isfolder", {}, function()
	assert(isfolder(".tests") == true, "Did not return false for a folder")
	assert(isfolder(".tests/doesnotexist.exe") == false, "Did not return false for a nonexistent path (got " .. tostring(isfolder(".tests/doesnotexist.exe")) .. ")")
end)

test("delfolder", {}, function()
	makefolder(".tests/delfolder")
	delfolder(".tests/delfolder")
	assert(isfolder(".tests/delfolder") == false, "Failed to delete folder (isfolder = " .. tostring(isfolder(".tests/delfolder")) .. ")")
end)

test("delfile", {}, function()
	writefile(".tests/delfile.txt", "Hello, world!")
	delfile(".tests/delfile.txt")
	assert(isfile(".tests/delfile.txt") == false, "Failed to delete file (isfile = " .. tostring(isfile(".tests/delfile.txt")) .. ")")
end)

test("loadfile", {}, function()
	writefile(".tests/loadfile.txt", "return ... + 1")
	assert(assert(loadfile(".tests/loadfile.txt"))(1) == 2, "Failed to load a file with arguments")
	writefile(".tests/loadfile.txt", "f")
	local callback, err = loadfile(".tests/loadfile.txt")
	assert(err and not callback, "Did not return an error message for a compiler error")
end)

test("dofile", {})

-- Input

test("isrbxactive", {"isgameactive"}, function()
	assert(type(isrbxactive()) == "boolean", "Did not return a boolean value")
end)

test("mouse1click", {})

test("mouse1press", {})

test("mouse1release", {})

test("mouse2click", {})

test("mouse2press", {})

test("mouse2release", {})

test("mousemoveabs", {})

test("mousemoverel", {})

test("mousescroll", {})

-- Instances

test("fireclickdetector", {}, function()
	local detector = Instance.new("ClickDetector")
	fireclickdetector(detector, 50, "MouseHoverEnter")
end)

test("fireproximityprompt", {}, function()
	local prompt = Instance.new("ProximityPrompt")
	fireproximityprompt(prompt, 1, false)
end)

test("firetouchinterest", {}, function()
	local part = Instance.new("Part")

	firesignal(part, "Touched")
end)

test("firesignal", {})

test("getcallbackvalue", {}, function()
	local bindable = Instance.new("BindableFunction")
	local function test()
	end
	bindable.OnInvoke = test
	assert(getcallbackvalue(bindable, "OnInvoke") == test, "Did not return the correct value")
end)

test("getconnections", {}, function()
	local types = {
		Enabled = "boolean",
		ForeignState = "boolean",
		LuaConnection = "boolean",
		Function = "function",
		Thread = "thread",
		Fire = "function",
		Defer = "function",
		Disconnect = "function",
		Disable = "function",
		Enable = "function",
	}
	local bindable = Instance.new("BindableEvent")
	bindable.Event:Connect(function() end)
	local connection = getconnections(bindable.Event)[1]
	for k, v in pairs(types) do
		assert(connection[k] ~= nil, "Did not return a table with a '" .. k .. "' field")
		assert(type(connection[k]) == v, "Did not return a table with " .. k .. " as a " .. v .. " (got " .. type(connection[k]) .. ")")
	end
end)

test("getcustomasset", {}, function()
	writefile(".tests/getcustomasset.txt", "success")
	local contentId = getcustomasset(".tests/getcustomasset.txt")
	assert(type(contentId) == "string", "Did not return a string")
	assert(#contentId > 0, "Returned an empty string")
	assert(string.match(contentId, "rbxasset://") == "rbxasset://", "Did not return an rbxasset url")
end)

test("gethiddenproperty", {}, function()
	local fire = Instance.new("Fire")
	local property, isHidden = gethiddenproperty(fire, "size_xml")
	assert(property == 5, "Did not return the correct value")
	assert(isHidden == true, "Did not return whether the property was hidden")
end)

test("sethiddenproperty", {}, function()
	local fire = Instance.new("Fire")
	local hidden = sethiddenproperty(fire, "size_xml", 10)
	assert(hidden, "Did not return true for the hidden property")
	assert(gethiddenproperty(fire, "size_xml") == 10, "Did not set the hidden property")
end)

test("gethui", {}, function()
	assert(typeof(gethui()) == "Instance", "Did not return an Instance")
end)

test("getinstances", {}, function()
	assert(getinstances()[1]:IsA("Instance"), "The first value is not an Instance")
end)

test("getnilinstances", {}, function()
	assert(getnilinstances()[1]:IsA("Instance"), "The first value is not an Instance")
	assert(getnilinstances()[1].Parent == nil, "The first value is not parented to nil")
end)

test("isscriptable", {}, function()
	local fire = Instance.new("Fire")
	assert(isscriptable(fire, "size_xml") == false, "Did not return false for a non-scriptable property (size_xml)")
	assert(isscriptable(fire, "Size") == true, "Did not return true for a scriptable property (Size)")
end)

test("setscriptable", {}, function()
	local fire = Instance.new("Fire")
	local wasScriptable = setscriptable(fire, "size_xml", true)
	assert(wasScriptable == false, "Did not return false for a non-scriptable property (size_xml)")
	assert(isscriptable(fire, "size_xml") == true, "Did not set the scriptable property")
	fire = Instance.new("Fire")
	assert(isscriptable(fire, "size_xml") == false, "⚠️⚠️ setscriptable persists between unique instances ⚠️⚠️")
end)

test("setrbxclipboard", {})

-- Metatable

test("getrawmetatable", {}, function()
	local metatable = { __metatable = "Locked!" }
	local object = setmetatable({}, metatable)
	assert(getrawmetatable(object) == metatable, "Did not return the metatable")
end)

test("hookmetamethod", {}, function()
	local object = setmetatable({}, { __index = newcclosure(function() return false end), __metatable = "Locked!" })
	local ref = hookmetamethod(object, "__index", function() return true end)
	assert(object.test == true, "Failed to hook a metamethod and change the return value")
	assert(ref() == false, "Did not return the original function")
end)

test("getnamecallmethod", {}, function()
	local method
	local ref
	ref = hookmetamethod(game, "__namecall", function(...)
		if not method then
			method = getnamecallmethod()
		end
		return ref(...)
	end)
	game:GetService("Lighting")
	assert(method == "GetService", "Did not get the correct method (GetService)")
end)

test("isreadonly", {"iswriteable"}, function()
	local object = {}
	table.freeze(object)
	assert(isreadonly(object), "Did not return true for a read-only table")
end)

test("setrawmetatable", {}, function()
	local object = setmetatable({}, { __index = function() return false end, __metatable = "Locked!" })
	local objectReturned = setrawmetatable(object, { __index = function() return true end })
	assert(object, "Did not return the original object")
	assert(object.test == true, "Failed to change the metatable")
	if objectReturned then
		return objectReturned == object and "Returned the original object" or "Did not return the original object"
	end
end)

test("setreadonly", {"makewritable"}, function()
	local object = { success = false }
	table.freeze(object)
	setreadonly(object, false)
	object.success = true
	assert(object.success, "Did not allow the table to be modified")
end)

-- Miscellaneous

test("identifyexecutor", {"getexecutorname"}, function()
	local name, version = identifyexecutor()
	assert(type(name) == "string", "Did not return a string for the name")
	return type(version) == "string" and "Returns version as a string" or "Does not return version"
end)

test("lz4compress", {}, function()
	local raw = "Hello, world!"
	local compressed = lz4compress(raw)
	assert(type(compressed) == "string", "Compression did not return a string")
	assert(lz4decompress(compressed, #raw) == raw, "Decompression did not return the original string")
end)

test("lz4decompress", {}, function()
	local raw = "Hello, world!"
	local compressed = lz4compress(raw)
	assert(type(compressed) == "string", "Compression did not return a string")
	assert(lz4decompress(compressed, #raw) == raw, "Decompression did not return the original string")
end)

test("messagebox", {})

test("queue_on_teleport", {"queueonteleport"})

test("request", {"http.request", "http_request"}, function()
	local response = request({
		Url = "https://httpbin.org/user-agent",
		Method = "GET",
	})
	assert(type(response) == "table", "Response must be a table")
	assert(response.StatusCode == 200, "Did not return a 200 status code")
	local data = game:GetService("HttpService"):JSONDecode(response.Body)
	assert(type(data) == "table" and type(data["user-agent"]) == "string", "Did not return a table with a user-agent key")
	return "User-Agent: " .. data["user-agent"]
end)

test("setclipboard", {"toclipboard"})

test("setfpscap", {}, function()
	local renderStepped = game:GetService("RunService").RenderStepped
	local function step()
		renderStepped:Wait()
		local sum = 0
		for _ = 1, 5 do
			sum += 1 / renderStepped:Wait()
		end
		return math.round(sum / 5)
	end
	setfpscap(60)
	local step60 = step()
	setfpscap(0)
	local step0 = step()
	return step60 .. "fps @60 • " .. step0 .. "fps @0"
end)

-- Scripts

test("getgc", {}, function()
	local gc = getgc()
	assert(type(gc) == "table", "Did not return a table")
	assert(#gc > 0, "Did not return a table with any values")
end)

test("getgenv", {}, function()
	getgenv().__TEST_GLOBAL = true
	assert(__TEST_GLOBAL, "Failed to set a global variable")
	getgenv().__TEST_GLOBAL = nil
end)

test("getloadedmodules", {}, function()
	local modules = getloadedmodules()
	assert(type(modules) == "table", "Did not return a table")
	assert(#modules > 0, "Did not return a table with any values")
	assert(typeof(modules[1]) == "Instance", "First value is not an Instance")
	assert(modules[1]:IsA("ModuleScript"), "First value is not a ModuleScript")
end)

test("getrenv", {}, function()
	assert(_G ~= getrenv()._G, "The variable _G in the executor is identical to _G in the game")
end)

test("getrunningscripts", {}, function()
	local scripts = getrunningscripts()
	assert(type(scripts) == "table", "Did not return a table")
	assert(#scripts > 0, "Did not return a table with any values")
	assert(typeof(scripts[1]) == "Instance", "First value is not an Instance")
	assert(scripts[1]:IsA("ModuleScript") or scripts[1]:IsA("LocalScript"), "First value is not a ModuleScript or LocalScript")
end)

test("getscriptbytecode", {"dumpstring"}, function()
	local animate = game:GetService("Players").LocalPlayer.Character.Animate
	local bytecode = getscriptbytecode(animate)
	assert(type(bytecode) == "string", "Did not return a string for Character.Animate (a " .. animate.ClassName .. ")")
end)

test("getscripthash", {}, function()
	local animate = game:GetService("Players").LocalPlayer.Character.Animate:Clone()
	local hash = getscripthash(animate)
	local source = animate.Source
	animate.Source = "print('Hello, world!')"
	task.defer(function()
		animate.Source = source
	end)
	local newHash = getscripthash(animate)
	assert(hash ~= newHash, "Did not return a different hash for a modified script")
	assert(newHash == getscripthash(animate), "Did not return the same hash for a script with the same source")
end)

test("getscripts", {}, function()
	local scripts = getscripts()
	assert(type(scripts) == "table", "Did not return a table")
	assert(#scripts > 0, "Did not return a table with any values")
	assert(typeof(scripts[1]) == "Instance", "First value is not an Instance")
	assert(scripts[1]:IsA("ModuleScript") or scripts[1]:IsA("LocalScript"), "First value is not a ModuleScript or LocalScript")
end)

test("getsenv", {}, function()
	local animate = game:GetService("Players").LocalPlayer.Character.Animate
	local env = getsenv(animate)
	assert(type(env) == "table", "Did not return a table for Character.Animate (a " .. animate.ClassName .. ")")
	assert(env.script == animate, "The script global is not identical to Character.Animate")
end)

test("getthreadidentity", {"getidentity", "getthreadcontext"}, function()
	assert(type(getthreadidentity()) == "number", "Did not return a number")
end)

test("setthreadidentity", {"setidentity", "setthreadcontext"}, function()
	setthreadidentity(3)
	assert(getthreadidentity() == 3, "Did not set the thread identity")
end)

-- Drawing

test("Drawing", {})

test("Drawing.new", {}, function()
	local drawing = Drawing.new("Square")
	drawing.Visible = false
	local canDestroy = pcall(function()
		drawing:Destroy()
	end)
	assert(canDestroy, "Drawing:Destroy() should not throw an error")
end)

test("Drawing.Fonts", {}, function()
	assert(Drawing.Fonts.UI == 0, "Did not return the correct id for UI")
	assert(Drawing.Fonts.System == 1, "Did not return the correct id for System")
	assert(Drawing.Fonts.Plex == 2, "Did not return the correct id for Plex")
	assert(Drawing.Fonts.Monospace == 3, "Did not return the correct id for Monospace")
end)

test("isrenderobj", {}, function()
	local drawing = Drawing.new("Image")
	drawing.Visible = true
	assert(isrenderobj(drawing) == true, "Did not return true for an Image")
	assert(isrenderobj(newproxy()) == false, "Did not return false for a blank table")
end)

test("getrenderproperty", {}, function()
	local drawing = Drawing.new("Image")
	drawing.Visible = true
	assert(type(getrenderproperty(drawing, "Visible")) == "boolean", "Did not return a boolean value for Image.Visible")
	local success, result = pcall(function()
		return getrenderproperty(drawing, "Color")
	end)
	if not success or not result then
		return "Image.Color is not supported"
	end
end)

test("setrenderproperty", {}, function()
	local drawing = Drawing.new("Square")
	drawing.Visible = true
	setrenderproperty(drawing, "Visible", false)
	assert(drawing.Visible == false, "Did not set the value for Square.Visible")
end)

test("cleardrawcache", {}, function()
	cleardrawcache()
end)

-- WebSocket

test("WebSocket", {})

test("WebSocket.connect", {}, function()
	local types = {
		Send = "function",
		Close = "function",
		OnMessage = {"table", "userdata"},
		OnClose = {"table", "userdata"},
	}
	local ws = WebSocket.connect("ws://echo.websocket.events")
	assert(type(ws) == "table" or type(ws) == "userdata", "Did not return a table or userdata")
	for k, v in pairs(types) do
		if type(v) == "table" then
			assert(table.find(v, type(ws[k])), "Did not return a " .. table.concat(v, ", ") .. " for " .. k .. " (a " .. type(ws[k]) .. ")")
		else
			assert(type(ws[k]) == v, "Did not return a " .. v .. " for " .. k .. " (a " .. type(ws[k]) .. ")")
		end
	end
	ws:Close()
end)

test("protectgui", {})
test("unprotectgui", {})
test("getdevice", {}, function()
	local device = getdevice()
	local realdevice = tostring(game:GetService("UserInputService"):GetPlatform()):split(".")[3]
	assert(device == realdevice, "Did not return correct device (expected "..realdevice.." got "..device..")")
end)

test("getping", {}, function()
	function a()
		local rawping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
    	local pingstr = rawping:sub(1, #rawping - 7)
    	local pingnum = tonumber(pingstr)
    	local ping = tostring(math.round(pingnum))
		return ping
	end

	local ping = getping()
	local realping = a()
	assert(ping == realping, "Did not return correct ping (expected "..realping.." got "..ping..")")
end)

test("getfps", {}, function()
	function a()
		local RunService = game:GetService("RunService")
		local FPS
		local TimeFunction = RunService:IsRunning() and time or os.clock
	
		if not TimeFunction then
			warn("TimeFunction is nil")
			return
		end
	
		local LastIteration, Start
		local FrameUpdateTable = {}
	
		local function HeartbeatUpdate()
			LastIteration = TimeFunction()
			for Index = #FrameUpdateTable, 1, -1 do
				FrameUpdateTable[Index + 1] = FrameUpdateTable[Index] >= LastIteration - 1 and FrameUpdateTable[Index] or nil
			end
	
			FrameUpdateTable[1] = LastIteration
			FPS = TimeFunction() - Start >= 1 and #FrameUpdateTable or #FrameUpdateTable / (TimeFunction() - Start)
		end
	
		Start = TimeFunction()
		RunService.Heartbeat:Connect(HeartbeatUpdate)
		task.wait(1.1)
	
		return FPS
	end	

	local fps = getfps()
	local realfps = a()

	assert(fps == realfps, "Did not return correct fps (expected "..realfps.." got "..fps..")")
end)

test("deepclone", {})

test("setsimulationradius", {}, function()
	local LocalPlayer = game:GetService("Players").LocalPlayer

	setsimulationradius(100, 101)
	assert(LocalPlayer.SimulationRadius == 100, "Did not set simulation radius")
	assert(LocalPlayer.MaximumSimulationRadius == 101, "Did not set maximum simulation radius")
end)

test("isnetworkowner", {})
test("keyclick", {})
test("keypress", {})
test("keyrelease", {})
test("getobjects", {})
test("decompile", {})
test("saveinstance", {})
test("getfflag", {}, function()
	local test = getfflag("GetFastString")

	assert(test ~= nil, "Test returned nil")
end)

test("getaffiliateid", {"getaffiliate"}, function()
	local test = getaffiliateid()

	assert(test ~= nil, "Test returned nil")
end)

test("getlocalplayer", {"getplayer"}, function()
	local test = getlocalplayer()

	assert(test == game:GetService("Players").LocalPlayer, "Test did not return Local Player")
end)

test("getplayers", {}, function()
	local test = getplayers()

	assert(test == game:GetService("Players"), "Test did not return Players")
end)

test("join", {"joingame"})

wait(1)

print("")
print("")
print("UNC CHECK ^^^")
print("")
print("")
print("")
print("")
print("VULN CHECK vvv")
print("")
print("")

-- i dont like identing my code okay
-- now you may ask: why in god's name is the code making me want to pull my eyes out? dont ask why... all it matters is it works!
-- made cuz bored

print("\n")

print("Executor Vulnerability Check - Executor: " .. tostring(identifyexecutor()) .. "\nInspired by the UNC Environment Check!\n")
print("✅ - Pass, ⛔ - Fail, ⏺️ - Unknown")
print("Pass means that your executor has successfully blocked/mitigated the vulnerable method, while fail means that your executor is vulnerable to it. Sometimes unknown is for some cases where the executor doesn't support a required function for the test such as hookmetamethod.\n")

local insert = function(str)
-- i only need one blocked function, this doesnt put all blocked functions inside the table datastore we made
-- oh and, im not a fan of normal tables, so i use DataStoreIncrementOptions
getgenv().BLOCKED_FUNCTION = Instance.new("DataStoreIncrementOptions")
BLOCKED_FUNCTION:SetMetadata({ func = str })
end

-- we keep in track of how many results
local pass, fail, unknown = 0, 0, 0

-- no im not gonna make a separate stupid function for printing like the unc test did, im not a fan of writing clean code i write what im the most comfortable with
print("HttpRbxApiService - This service is used by Roblox CoreScripts to send HTTP requests to the Roblox APIs. When called by executors, this can lead to: cookie logging, robux draining, and pretty much everything anyone wanted to do to the account.")

task.spawn(function()
local s, e = pcall(function() game:GetService("HttpRbxApiService"):PostAsync() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ PostAsync")
else
pass += 1
print("  ✅ PostAsync")
insert(' game:GetService("HttpRbxApiService"):PostAsync()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("HttpRbxApiService"):PostAsyncFullUrl() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ PostAsyncFullUrl")
else
pass += 1
print("  ✅ PostAsyncFullUrl")
insert(' game:GetService("HttpRbxApiService"):PostAsyncFullUrl()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("HttpRbxApiService"):GetAsync() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ GetAsync")
else
pass += 1
print("  ✅ GetAsync")
insert(' game:GetService("HttpRbxApiService"):GetAsync()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("HttpRbxApiService"):GetAsyncFullUrl() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ GetAsyncFullUrl")
else
pass += 1
print("  ✅ GetAsyncFullUrl")
insert(' game:GetService("HttpRbxApiService"):GetAsyncFullUrl()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("HttpRbxApiService"):RequestAsync() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ RequestAsync")
else
pass += 1
print("  ✅ RequestAsync")
insert(' game:GetService("HttpRbxApiService"):RequestAsync()')
end
end)
task.wait()
print("ScriptContext - One function in this service creates a CoreScript to the desired location. This has been used in bypassing executor's security especially the approach that James Napora took in his GitHub gist, parenting a CoreScript to an actor to run malicious code.")
task.spawn(function()
local s, e = pcall(function() game:GetService("ScriptContext"):AddCoreScriptLocal() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ AddCoreScriptLocal")
else
pass += 1
print("  ✅ AddCoreScriptLocal")
end
end)
task.wait()
print("BrowserService - A service meant to be used by Roblox CoreScripts. This can load something like a direct download url and auto download stuff into the exploiter's device, load any urls with their browser etc.")
task.spawn(function()
local s, e = pcall(function() game:GetService("BrowserService"):EmitHybridEvent() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ EmitHybridEvent")
else
pass += 1
print("  ✅ EmitHybridEvent")
insert(' game:GetService("BrowserService"):EmitHybridEvent()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("BrowserService"):ExecuteJavaScript() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ ExecuteJavaScript")
else
pass += 1
print("  ✅ ExecuteJavaScript")
insert(' game:GetService("BrowserService"):ExecuteJavaScript()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("BrowserService"):OpenBrowserWindow() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ OpenBrowserWindow")
else
pass += 1
print("  ✅ OpenBrowserWindow")
insert(' game:GetService("BrowserService"):OpenBrowserWindow()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("BrowserService"):OpenNativeOverlay() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ OpenNativeOverlay")
else
pass += 1
print("  ✅ OpenNativeOverlay")
insert(' game:GetService("BrowserService"):OpenNativeOverlay()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("BrowserService"):ReturnToJavaScript() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ ReturnToJavaScript")
else
pass += 1
print("  ✅ ReturnToJavaScript")
insert(' game:GetService("BrowserService"):ReturnToJavaScript()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("BrowserService"):SendCommand() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ SendCommand")
else
pass += 1
print("  ✅ SendCommand")
insert(' game:GetService("BrowserService"):SendCommand()')
end
end)


-- as i deepen into the code, i realize... maybe i should've made a function for this and not write task.spawn again and again... but its too late.


task.wait()
print("MarketplaceService - A service in Roblox used for purchases in games. Robux Drainers can use VirtualInputManager to autoclick a prompt and drain robux, or use the other functions to directly drain robux.")
task.spawn(function()
local s, e = pcall(function() game:GetService("MarketplaceService"):GetRobuxBalance() end)
if s then
fail += 1
warn("  ⛔ GetRobuxBalance | Output: " .. tostring(e))
else
pass += 1
print("  ✅ GetRobuxBalance")
insert(' game:GetService("MarketplaceService"):GetRobuxBalance()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("MarketplaceService"):PerformPurchase() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ PerformPurchase")
else
pass += 1
print("  ✅ PerformPurchase")
insert(' game:GetService("MarketplaceService"):PerformPurchase()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("MarketplaceService"):PerformPurchaseV2() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ PerformPurchaseV2")
else
pass += 1
print("  ✅ PerformPurchaseV2")
insert(' game:GetService("MarketplaceService"):PerformPurchaseV2()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("MarketplaceService"):PromptBundlePurchase() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ PromptBundlePurchase")
else
pass += 1
print("  ✅ PromptBundlePurchase")
insert('game:GetService("MarketplaceService"):PromptBundlePurchase() ')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("MarketplaceService"):PromptGamePassPurchase() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ PromptGamePassPurchase")
else
pass += 1
print("  ✅ PromptGamePassPurchase")
insert(' game:GetService("MarketplaceService"):PromptGamePassPurchase()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("MarketplaceService"):PromptProductPurchase() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ PromptProductPurchase")
else
pass += 1
print("  ✅ PromptProductPurchase")
insert(' game:GetService("MarketplaceService"):PromptProductPurchase()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("MarketplaceService"):PromptPurchase() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ PromptPurchase")
else
pass += 1
print("  ✅ PromptPurchase")
insert(' game:GetService("MarketplaceService"):PromptPurchase()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("MarketplaceService"):PromptRobloxPurchase() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ PromptRobloxPurchase")
else
pass += 1
print("  ✅ PromptRobloxPurchase")
insert(' game:GetService("MarketplaceService"):PromptRobloxPurchase()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("MarketplaceService"):PromptThirdPartyPurchase() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ PromptThirdPartyPurchase")
else
pass += 1
print("  ✅ PromptThirdPartyPurchase")
insert(' game:GetService("MarketplaceService"):PromptThirdPartyPurchase()')
end
end)
task.wait()
print("HttpService - All functions in HttpService prevents you from sending authenticated requests to Roblox APIs except one. RequestInternal.")
task.spawn(function()
local s, e = pcall(function() game:GetService("HttpService"):RequestInternal() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ RequestInternal")
else
pass += 1
print("  ✅ RequestInternal")
insert('game:GetService("HttpService"):RequestInternal() ')
end
end)
task.wait()
print("GuiService - A service in Roblox for GUI related things. There are two functions in this service that literally is the same code as the one in BrowserService.")
task.spawn(function()
local s, e = pcall(function() game:GetService("GuiService"):OpenBrowserWindow() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ OpenBrowserWindow")
else
pass += 1
print("  ✅ OpenBrowserWindow")
insert('game:GetService("GuiService"):OpenBrowserWindow() ')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("GuiService"):OpenNativeOverlay() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ OpenNativeOverlay")
else
pass += 1
print("  ✅ OpenNativeOverlay")
insert(' game:GetService("GuiService"):OpenNativeOverlay()')
end
end)
task.wait()
print("OpenCloudService - A service that is less known by the community, there is one function that can send authenticated requests to the Roblox APIs.")
task.spawn(function()
local s, e = pcall(function() game:GetService("OpenCloudService"):HttpRequestAsync() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ HttpRequestAsync")
else
pass += 1
print("  ✅ HttpRequestAsync")
insert(' game:GetService("OpenCloudService"):HttpRequestAsync()')
end
end)
task.wait()
print("CoreGui - This service (yes, CoreGui is considered service) has very minor vulnerabilities to the point where I'm not sure if it can be considered as a vulnerability. But pretty sure these can be spammed and fill the user's storage so I'm putting these here.")
task.spawn(function()
local s, e = pcall(function() game:GetService("CoreGui"):TakeScreenshot() end)
if s then
fail += 1
warn("  ⛔ TakeScreenshot")
else
pass += 1
print("  ✅ TakeScreenshot")
insert(' game:GetService("CoreGui"):TakeScreenshot()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("CoreGui"):ToggleRecording() end)
if s then
fail += 1
warn("  ⛔ ToggleRecording")
else
pass += 1
print("  ✅ ToggleRecording")
insert(' game:GetService("CoreGui"):ToggleRecording()')
end
end)
task.wait()
print("MessageBusService - A service in Roblox used internally, but is the main priority of bad actors to achieve RCE or Remote Code Execution vulnerabilities in executors.")
task.spawn(function()
local s, e = pcall(function() game:GetService("MessageBusService"):Call() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ Call")
else
pass += 1
print("  ✅ Call")
insert(' game:GetService("MessageBusService"):Call()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("MessageBusService"):GetLast() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ GetLast")
else
pass += 1
print("  ✅ GetLast")
insert(' game:GetService("MessageBusService"):GetLast()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("MessageBusService"):GetMessageId() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ GetMessageId")
else
pass += 1
print("  ✅ GetMessageId")
insert('game:GetService("MessageBusService"):GetMessageId() ')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("MessageBusService"):GetProtocolMethodRequestMessageId() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ GetProtocolMethodRequestMessageId")
else
pass += 1
print("  ✅ GetProtocolMethodRequestMessageId")
insert(' game:GetService("MessageBusService"):GetProtocolMethodRequestMessageId()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("MessageBusService"):GetProtocolMethodResponseMessageId() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ GetProtocolMethodResponseMessageId")
else
pass += 1
print("  ✅ GetProtocolMethodResponseMessageId")
insert('game:GetService("MessageBusService"):GetProtocolMethodResponseMessageId() ')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("MessageBusService"):MakeRequest() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ MakeRequest")
else
pass += 1
print("  ✅ MakeRequest")
insert(' game:GetService("MessageBusService"):MakeRequest()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("MessageBusService"):Publish() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ Publish")
else
pass += 1
print("  ✅ Publish")
insert('game:GetService("MessageBusService"):Publish() ')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("MessageBusService"):PublishProtocolMethodRequest() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ PublishProtocolMethodRequest")
else
pass += 1
print("  ✅ PublishProtocolMethodRequest")
insert(' game:GetService("MessageBusService"):PublishProtocolMethodRequest()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("MessageBusService"):PublishProtocolMethodResponse() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ PublishProtocolMethodResponse")
else
pass += 1
print("  ✅ PublishProtocolMethodResponse")
insert('game:GetService("MessageBusService"):PublishProtocolMethodResponse() ')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("MessageBusService"):Subscribe() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ Subscribe")
else
pass += 1
print("  ✅ Subscribe")
insert(' game:GetService("MessageBusService"):Subscribe()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("MessageBusService"):SubscribeToProtocolMethodRequest() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ SubscribeToProtocolMethodRequest")
else
pass += 1
print("  ✅ SubscribeToProtocolMethodRequest")
insert(' game:GetService("MessageBusService"):SubscribeToProtocolMethodRequest()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("MessageBusService"):SubscribeToProtocolMethodResponse() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ SubscribeToProtocolMethodResponse")
else
pass += 1
print("  ✅ SubscribeToProtocolMethodResponse")
insert(' game:GetService("MessageBusService"):SubscribeToProtocolMethodResponse()')
end
end)
task.wait()
print("DataModel - The DataModel represents 'game', It's the root of Roblox's parent-child hierarchy. But of course, there are some minor and major vulnerabilities that can be abused here.")
task.spawn(function()
local s, e = pcall(function() game:Load() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ Load")
else
pass += 1
print("  ✅ Load")
insert(' game:Load()')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:OpenScreenshotsFolder() end)
if s then
fail += 1
warn("  ⛔ OpenScreenshotsFolder")
else
pass += 1
print("  ✅ OpenScreenshotsFolder")
insert('game:OpenScreenshotsFolder() ')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("CoreGui"):OpenVideosFolder() end)
if s then
fail += 1
warn("  ⛔ OpenVideosFolder")
else
pass += 1
print("  ✅ OpenVideosFolder")
insert('game:GetService("CoreGui"):OpenVideosFolder() ')
end
end)
task.wait()
print("OmniRecommendationsService - One function of this service can be used to send an HTTP request to a Roblox API.")
task.spawn(function()
local s, e = pcall(function() game:GetService("OmniRecommendationsService"):MakeRequest() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ MakeRequest")
else
pass += 1
print("  ✅ MakeRequest")
insert('game:GetService("OmniRecommendationsService"):MakeRequest() ')
end
end)
task.wait()
print("Players - There are functions in game:GetService('Players') that can be used to report the LocalPlayer. And a script could make the LocalPlayer say words that are against the ToS, getting the LocalPlayer terminated.")
task.spawn(function()
local s, e = pcall(function() game:GetService("Players"):ReportAbuse() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ ReportAbuse")
else
pass += 1
print("  ✅ ReportAbuse")
insert('game:GetService("Players"):ReportAbuse() ')
end
end)
task.wait()
task.spawn(function()
local s, e = pcall(function() game:GetService("Players"):ReportAbuseV3() end)
if e == "Argument 1 missing or nil" then
fail += 1
warn("  ⛔ ReportAbuseV3")
else
pass += 1
print("  ✅ ReportAbuseV3")
insert('game:GetService("Players"):ReportAbuseV3() ')
end
end)
task.wait()
print("Custom HTTP Functions - Executors usually have a custom function for sending HTTP requests, and sometimes the function would send authenticated requests to the Roblox APIs.")
print("If one of them shows your Robux balance, your executor is vulnerable!")
task.spawn(function()
local s, e = pcall(function() getgenv().REQUEST_RESULT = request({ Url = "https://economy.roblox.com/v1/user/currency", Method = "GET" }) end)
if e == ":1: attempt to call a nil value" then
unknown += 1
print("  ⏺️ request (Executor does not support request function)")
task.wait(99999999999) -- shouldnt yield the other threads
end
if not s then
-- i am just going to assume it got blocked?
pass += 1
print("  ✅ request | Function call went error: " .. tostring(e))
task.wait(99999999999) -- shouldnt yield the other threads
end
local str = tostring(REQUEST_RESULT.Body)
local pattern = '^{"robux":'
local st, en = string.find(str, pattern)
if st == 1 then
fail += 1
warn("  ⛔ request | Robux API Output: " .. str)
else
pass += 1
print("  ✅ request")
end
end)
task.wait(0.3)
task.spawn(function()
local s, e = pcall(function() getgenv().GAME_HTTPGET_RESULT = game:HttpGet("https://economy.roblox.com/v1/user/currency") end)
if e == ":1: attempt to call a nil value" then
unknown += 1
print("  ⏺️ game:HttpGet (Executor does not support game:HttpGet function)")
task.wait(99999999999) -- shouldnt yield the other threads
end
if not s then
-- i am just going to assume it got blocked?
pass += 1
print("  ✅ game:HttpGet | Function call went error: " .. tostring(e))
task.wait(99999999999) -- shouldnt yield the other threads
end
local str = tostring(GAME_HTTPGET_RESULT)
local pattern = '^{"robux":'
local st, en = string.find(str, pattern)
if st == 1 then
fail += 1
warn("  ⛔ game:HttpGet | Robux API Output: " .. str)
else
pass += 1
print("  ✅ game:HttpGet")
end
end)
task.wait(0.3)
task.spawn(function()
local s, e = pcall(function() getgenv().GAME_HTTPPOST_RESULT = game:HttpPost("https://economy.roblox.com/v1/purchases/products/41762", '{"expectedCurrency":1,"expectedPrice":0,"expectedSellerId":116444}') end)
if e == ":1: attempt to call a nil value" then
getgenv().GAME_HTTPPOST_FINISHED = true
unknown += 1
print("  ⏺️ game:HttpPost (Executor does not support game:HttpPost function)")
task.wait(99999999999) -- shouldnt yield the other threads
end
if not s then
-- i am just going to assume it got blocked?
getgenv().GAME_HTTPPOST_FINISHED = true
pass += 1
print("  ✅ game:HttpPost | Function call went error: " .. tostring(e))
task.wait(99999999999) -- shouldnt yield the other threads
end
if game:GetService("MarketplaceService"):PlayerOwnsAsset(game.Players.LocalPlayer, 1589257) then
fail += 1
getgenv().GAME_HTTPPOST_FINISHED = true
warn("  ⛔ game:HttpPost | Request was sent to Roblox API to buy a free T-Shirt, and user now owns the T-Shirt. Executor may be vulnerable. Asset ID: 1589257 | Roblox API Response: " .. tostring(GAME_HTTPPOST_RESULT))
else
pass += 1
getgenv().GAME_HTTPPOST_FINISHED = true
print("  ✅ game:HttpPost | Everything went correctly I think... API Response: " .. tostring(GAME_HTTPPOST_RESULT))
end
end)
repeat task.wait() until GAME_HTTPPOST_FINISHED
task.wait(1)
task.wait(1.5)
task.wait()
print("Blocked Function Protection Bypass - Moving onto vulnerabilities that let bad actors bypass the security of your executor.")
task.spawn(function()
for i, v in pairs(BLOCKED_FUNCTION:GetMetadata()) do
getgenv().FUNCTION_TO_CALL = tostring(v)
end
if type(FUNCTION_TO_CALL) == "nil" then
warn("  ⛔ Cancelled. Either getgenv().FUNCTION_TO_CALL was removed from the environment, or your executor is vulnerable to every single vulnerability.")
task.wait(9999999999999)
end
local s, e = pcall(function() loadstring(tostring(FUNCTION_TO_CALL))() end)
pcall(function()
getrenv().loadstring = getgenv().loadstring
getrenv().getgenv = getgenv().getgenv
getrenv()._set = clonefunction(setthreadidentity)
local old old = hookmetamethod(game, "__index", function(a, b) task.spawn(function() _set(7) task.wait(0.1)
getgenv().s1, e1 = pcall(function() loadstring(tostring(FUNCTION_TO_CALL))() end)
end) hookmetamethod(game, "__index", old) return old(a, b) end)
end)
task.wait(0.1)
if e == e1 then
print("  ✅ Escaping Executor's Environment & Running as LocalScript")
else
if e1 == "Argument 1 missing or nil" then
warn("  ⛔ Escaping Executor's Environment & Running as LocalScript")
else
print("  ⏺️ Escaping Executor's Environment & Running as LocalScript - Something went wrong... But I'm not quite sure what... Here's the original output: `" .. tostring(e) .. "` then here's the output after escaping environment: `" .. tostring(e1) .. "`")
end
end
end)
print("  ⏺️ (No Test) Using hookmetamethod to stop metamethod hooks - There was a case like in Electron V3 where the executor's security was just quite literally hookmetamethod. You used to be able to use hookmetamethod to unhook blocked functions and bypass the security.")
task.wait(5)


exec = tostring(identifyexecutor())

local rate = math.round(pass / (pass + fail + unknown) * 100)
local outOf = pass .. " out of " .. (pass + fail + unknown)
print("\n")
print("Vulnerability Check Summary - " .. exec)
print("✅ Tested with a " .. rate .. "% vulnerability mitigations rate (" .. outOf .. ")")
print("⛔ " .. fail .. " vulnerabilities not mitigated")
print("⏺️ " .. unknown .. " vulnerabilities not tested")

wait(3)

local LogService = game:FindService("LogService")

local getthreadidentity = function()
    local BindableEvent = Instance.new("BindableEvent")

    LogService.MessageOut:Once(function(Message)
        BindableEvent:Fire(tonumber(string.sub(Message, 20, # Message)))
        BindableEvent:Destroy()
    end)

    printidentity()

    return BindableEvent.Event:Wait()
end

wait(1)

local identity = getthreadidentity()

wait(1)

Safty = math.abs(rate - 100)
print("Executor Information ---------")
print("")
print("Unc "..Unc.."%")
print("Vuln "..Safty.."%")
print("Executor Level is "..identity)

wait(1)

getgenv().execinfo = {
    Name = identifyexecutor(),
    Unc = Unc,
    Vuln = Safty,
    Level = identity
}

wait(1)

gathering = false
end
function toolgiver()
    local ToolGiverGui = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local ScrollingFrame = Instance.new("ScrollingFrame")
    local UIListLayout = Instance.new("UIListLayout")
    local TextButton = Instance.new("TextButton")
    local TextLabel = Instance.new("TextLabel")
    local TextButton_2 = Instance.new("TextButton")
    local CloseButton = Instance.new("TextButton")  -- Close Button
    
    -- Variables for Close Button position and size
    local CloseX = 0.9  -- Change this for horizontal positioning
    local CloseY = 0.016     -- Change this for vertical positioning
    local CloseSize = UDim2.new(0, 18, 0, 18)  -- Close Button size
    
    ToolGiverGui.Parent = game:GetService("CoreGui")
    ToolGiverGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ToolGiverGui.ResetOnSpawn = false
    
    Frame.Parent = ToolGiverGui
    Frame.Active = true
    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BorderColor3 = Color3.fromRGB(255, 0, 255)
    Frame.Position = UDim2.new(0.0610425249, 0, 0.0939490423, 0)
    Frame.Size = UDim2.new(0, 218, 0, 225)  -- Original size
    
    ScrollingFrame.Parent = Frame
    ScrollingFrame.Active = true
    ScrollingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ScrollingFrame.BorderColor3 = Color3.fromRGB(255, 0, 255)
    ScrollingFrame.Position = UDim2.new(0.0871559605, 0, 0.155555561, 0)
    ScrollingFrame.Size = UDim2.new(0, 187, 0, 136)  -- Original size
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 35, 0)
    
    UIListLayout.Parent = ScrollingFrame
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    TextButton.Parent = ScrollingFrame
    TextButton.BackgroundColor3 = Color3.fromRGB(117, 117, 117)
    TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextButton.Size = UDim2.new(0, 155, 0, 39)  -- Original size
    TextButton.Visible = false
    TextButton.Font = Enum.Font.SourceSans
    TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextButton.TextSize = 20.000
    TextButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    TextButton.TextStrokeTransparency = 0.000
    TextButton.TextWrapped = true
        
        TextLabel.Parent = Frame
    TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BorderColor3 = Color3.fromRGB(255, 0, 255)
    TextLabel.Position = UDim2.new(-0.00129664713, 0, -0.000140406293, 0)
    TextLabel.Size = UDim2.new(0, 218, 0, 25)  -- Original size
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.Text = "MAJESTY's Tool Giver"
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextSize = 14.000
    
    TextButton_2.Parent = Frame
    TextButton_2.BackgroundColor3 = Color3.fromRGB(177, 177, 177)
    TextButton_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextButton_2.Position = UDim2.new(0.0825688094, 0, 0.804444432, 0)
    TextButton_2.Size = UDim2.new(0, 180, 0, 30)  -- Original size
    TextButton_2.Font = Enum.Font.SourceSans
    TextButton_2.Text = "Update List"
    TextButton_2.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextButton_2.TextSize = 14.000
    
    CloseButton.Parent = Frame
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- Red color
    CloseButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CloseButton.Position = UDim2.new(CloseX, 0, CloseY, 0)  -- Use the CloseX and CloseY variables
    CloseButton.Size = CloseSize  -- Use the CloseSize variable
    CloseButton.Font = Enum.Font.SourceSans
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14.000
    
    CloseButton.MouseButton1Click:Connect(function()
        ToolGiverGui:Destroy()  -- Destroy the GUI
    end)
    
    local function FNDR_fake_script()
        local script = Instance.new('LocalScript', Frame)
    
        local button = script.Parent.ScrollingFrame.TextButton
        button.Parent = nil
        button.Name = "slaves"
        local toolNames = {}
    
        local function cloneToBackpack(toolName)
            local clonedTool = toolName:Clone()
            clonedTool.Parent = game:GetService("Players").LocalPlayer:WaitForChild("Backpack")
        end
    
        local function updatelist()
            for i, v in script.Parent.ScrollingFrame:GetDescendants() do
                if v:IsA("TextButton") then
                    v:Destroy()
                end
            end
    
            toolNames = {}
            local tools = {}
            for i, v in pairs(game:GetDescendants()) do
                if v:IsA("Tool") and v.Parent.Parent ~= game:GetService("Players").LocalPlayer then
                    if not toolNames[v.Name] then
                        table.insert(tools, v)
                        toolNames[v.Name] = true
                    end
                end
            end
    
            table.sort(tools, function(a, b)
                return a.Name < b.Name
            end)
    
            for _, tool in ipairs(tools) do
                local clonebutton = button:Clone()
                clonebutton.Parent = script.Parent.ScrollingFrame
                clonebutton.Visible = true
                clonebutton.Text = tool.Name
                clonebutton.MouseButton1Click:Connect(function()
                    cloneToBackpack(tool)
                end)
            end
        end
    
        script.Parent.TextButton.MouseButton1Click:Connect(updatelist)
    end
    coroutine.wrap(FNDR_fake_script)()
    
    local function SGRWUDK_fake_script()
        local script = Instance.new('LocalScript', Frame)
    
        local UIS = game:GetService('UserInputService')
        local frame = script.Parent
        local dragToggle = nil
        local dragSpeed = 0
        local dragStart = nil
        local startPos = nil
        
        local function updateInput(input)
            local delta = input.Position - dragStart
            local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            game:GetService('TweenService'):Create(frame, TweenInfo.new(dragSpeed), {
                Position = position
            }):Play()
        end
        
        frame.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
                dragToggle = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragToggle = false
                    end
                end)
            end
        end)
        
        UIS.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if dragToggle then
                    updateInput(input)
                end
            end
        end)
    end
    coroutine.wrap(SGRWUDK_fake_script)()
end

local player = game:GetService("Players").LocalPlayer
local playerName = player.Name
local playerUser = player.DisplayName
local playerID = player.UserId
local Executor = identifyexecutor()
local GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
local GameId = game.GameId
local PlaceId = game.PlaceId
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()
local HttpService = game:GetService("HttpService")
local minkey = "RightControl"
local focus = true
local mouse = false
local commandpromptname = "N/A"
local dex
local og = false
local count = 0 for _, v in ipairs(game.Players.LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do if v.Name == "CommandPrompt" then count = count + 1 end end

local Player = game.Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera

local isInFirstPerson = function()
    local character = Player.Character
    if character and character:FindFirstChild("Head") then
        return (Camera.CFrame.Position - character.Head.Position).Magnitude < 1 -- Adjust the threshold as needed
    end
    return false
end

if getgenv().multi == nil then
    getgenv().multi = false
end

exists = (game.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("CommandPrompt") ~= nil)

if getgenv().multi and exists then
commandpromptname = tostring("CommandPrompt ".. count)
else
commandpromptname = "CommandPrompt"
og = true
end

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local UnlockMouse = false
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E and mouse and isInFirstPerson() then
        UnlockMouse = true
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E and mouse and isInFirstPerson() then
        UnlockMouse = false
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    end
end)
RunService.RenderStepped:Connect(function()
    if UnlockMouse and mouse and isInFirstPerson() then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)

local CorrectKeys = {
    A = true, B = true, C = true, D = true, E = true, F = true, G = true, H = true,
    I = true, J = true, K = true, L = true, M = true, N = true, O = true, P = true,
    Q = true, R = true, S = true, T = true, U = true, V = true, W = true, X = true,
    Y = true, Z = true,
    Zero = true, One = true, Two = true, Three = true, Four = true, Five = true,
    Six = true, Seven = true, Eight = true, Nine = true,
    Space = true, Backspace = true, Tab = true, Enter = true, Shift = true,
    Control = true, Alt = true, Escape = true, CapsLock = true,
    F1 = true, F2 = true, F3 = true, F4 = true, F5 = true, F6 = true,
    F7 = true, F8 = true, F9 = true, F10 = true, F11 = true, F12 = true,
    Comma = true, Period = true, Semicolon = true, Quote = true,
    Slash = true, Backslash = true, LeftBracket = true, RightBracket = true,
    Minus = true, Equal = true, Underscore = true, Plus = true,
    Grave = true, ScrollLock = true, Insert = true, Home = true,
    PageUp = true, Delete = true, End = true, PageDown = true,
    Right = true, Left = true, Down = true, Up = true,
    NumpadZero = true, NumpadOne = true, NumpadTwo = true, NumpadThree = true,
    NumpadFour = true, NumpadFive = true, NumpadSix = true, NumpadSeven = true,
    NumpadEight = true, NumpadNine = true, NumpadDecimal = true,
    NumpadPlus = true, NumpadMinus = true, NumpadMultiply = true, NumpadDivide = true,
    NumpadEnter = true
}

local CommandPrompt = Instance.new("ScreenGui")
CommandPrompt.Name = commandpromptname
CommandPrompt.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

if getgenv().multi == false and exists then
    CommandPrompt:Destroy()
end

local cmdFrame = Instance.new("Frame")
cmdFrame.Size = UDim2.new(0, 600, 0, 400)
cmdFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
cmdFrame.BackgroundColor3 = Color3.new(0, 0, 0)
cmdFrame.BorderSizePixel = 1
cmdFrame.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
cmdFrame.Active = true
cmdFrame.Draggable = true
cmdFrame.Parent = CommandPrompt

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -30, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Text = " ".. commandpromptname
titleLabel.Font = Enum.Font.Code
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = cmdFrame

local isVisible = true

local function HideGui()
    cmdFrame.Visible = false
    isVisible = false
end

local function ShowGui()
    cmdFrame.Visible = true
    isVisible = true
end


local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
MinimizeButton.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.Text = "-"
MinimizeButton.Font = Enum.Font.Code
MinimizeButton.TextSize = 16
MinimizeButton.Parent = cmdFrame

MinimizeButton.MouseButton1Click:Connect(function()
    HideGui()
end)

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Text = "X"
closeButton.Font = Enum.Font.Code
closeButton.TextSize = 16
closeButton.Parent = cmdFrame

closeButton.MouseButton1Click:Connect(function()
    CommandPrompt:Destroy() 
end)

local mainTextColor = Color3.new(1, 1, 1) 
local inputTextColor = Color3.new(1, 1, 1) 

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -100) 
scrollFrame.Position = UDim2.new(0, 10, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.Parent = cmdFrame

local layout = Instance.new("UIListLayout")
layout.Parent = scrollFrame
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

local inputFrame = Instance.new("Frame")
inputFrame.Size = UDim2.new(1, -20, 0, 30)
inputFrame.Position = UDim2.new(0, 10, 1, -40)
inputFrame.BackgroundColor3 = Color3.new(0, 0, 0)
inputFrame.BorderSizePixel = 1
inputFrame.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
inputFrame.Parent = cmdFrame

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingLeft = UDim.new(0, 5)
uiPadding.PaddingTop = UDim.new(0, 5)
uiPadding.PaddingRight = UDim.new(0, 5)
uiPadding.PaddingBottom = UDim.new(0, 5)
uiPadding.Parent = inputFrame

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -10, 1, -10)
inputBox.Position = UDim2.new(0, 5, 0, 5)
inputBox.BackgroundColor3 = Color3.new(0, 0, 0)
inputBox.BorderSizePixel = 0
inputBox.TextColor3 = inputTextColor
inputBox.TextXAlignment = Enum.TextXAlignment.Left
inputBox.PlaceholderText = "C:\\Players\\"..playerUser..">"
inputBox.Font = Enum.Font.Code
inputBox.TextSize = 16
inputBox.Text = ""
inputBox.ClearTextOnFocus = false
inputBox.Parent = inputFrame

local function addCommandOutput(text)
    local outputBox = Instance.new("TextBox")
    outputBox.Size = UDim2.new(1, -10, 0, 20)
    outputBox.BackgroundTransparency = 1
    outputBox.TextColor3 = mainTextColor
    outputBox.Font = Enum.Font.Code
    outputBox.TextSize = 16
    outputBox.TextXAlignment = Enum.TextXAlignment.Left
    outputBox.TextYAlignment = Enum.TextYAlignment.Top
    outputBox.Text = text
    outputBox.ClearTextOnFocus = false
    outputBox.TextEditable = false
    outputBox.Parent = scrollFrame

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
end

local function setMainColor(r, g, b)
    mainTextColor = Color3.fromRGB(r, g, b)
    addCommandOutput("Main text color changed to RGB(" .. r .. ", " .. g .. ", " .. b .. ")")
end

local function setInputColor(r, g, b)
    inputTextColor = Color3.fromRGB(r, g, b)
    inputBox.TextColor3 = inputTextColor
    addCommandOutput("Input text color changed to RGB(" .. r .. ", " .. g .. ", " .. b .. ")")
end

Commands = {
    "Help - Gives all Commands and information",
    "exit - kills Command Prompt",
    "setMainColor <rgb> - Set the color of the main text (rgb)",
    "setInputColor - Set the color of the input text (rgb)",
    "min - Minimize Command Prompt",
    "minKey <input> - Set the key to open CommandPrompt if minimized",
    "Multi <boolean> - Determines if there can be multiple Command Prompts",
    "Zoom <number> - Sets the players max camera zoom",
    "UnlockMouse <boolean> - Unlocks the players mouse in first person",
    "ToolGiver - Loads a gui where you can giver yourself tools found ingame",
    "Dev - Returns a list of commands for script devs"
}
DevCommands = {
    "Dex <boolean> - if your a dev ya know what it is",
    "ToolGiver - Loads a gui where you can giver yourself tools found ingame",
    "GetExecutor - Returns the information about the executor (THIS IS SLOW)",
    "DebugTool - Gives the player a tool that prints info on a object clicked"
}

local function cmd(input)
    addCommandOutput("C:\\Players\\"..playerUser.."> " .. input)
    if gathering == false then
    local args = string.split(input, " ")
    if args[1] == "DevTest" then
        addCommandOutput("Executor Name | ".. tostring(identifyexecutor()))
    elseif args[1] == "Help" then
        for i=1, #Commands do
            addCommandOutput(Commands[i])
        end
    elseif args[1] == "Dev" then
        for i=1, #DevCommands do
            addCommandOutput(DevCommands[i])
        end
    elseif args[1] == "setMainColor" then
    if #args == 4 then
        local r = tonumber(args[2]) or 255
        local g = tonumber(args[3]) or 255
        local b = tonumber(args[4]) or 255
        setMainColor(r, g, b)
    else
    addCommandOutput("Invalid args")
    end
    elseif args[1] == "setInputColor" then
    if #args == 4 then
        local r = tonumber(args[2]) or 255
        local g = tonumber(args[3]) or 255
        local b = tonumber(args[4]) or 255
        setInputColor(r, g, b)
    else
    addCommandOutput("Invalid args")
    end
    elseif args[1] == "min" then
        focus = false
        HideGui()
        addCommandOutput("Command Prompt has been minimized", false)
    elseif args[1] == "minKey" then
        if #args == 2 then
        if CorrectKeys[args[2]] then
        minkey = args[2]
        addCommandOutput("Minimize Key has been set to ".. args[2])
        else
        addCommandOutput("Minimize Key has not been changed since ".. args[2].. " is not a valid key")
        end
    else
    addCommandOutput("Invalid args")
    end
    elseif args[1] == "exit" then
        CommandPrompt:Destroy() 
    elseif args[1] == "Multi" then
        if args[2] == "true" then
            getgenv().multi = true
            addCommandOutput("Multiple Command Prompts have been enabled")
        elseif args[2] == false then
            getgenv().multi = false
            addCommandOutput("Multiple Command Prompts have been disabled")
    else
        addCommandOutput("Invalid args")
        end 
    elseif args[1] == "Dex" then
            if game.Players.LocalPlayer.PlayerGui:FindFirstChild("Dex") == nil then
                addCommandOutput("Dex is loading")
                Dexlink = "https://raw.githubusercontent.com/MAJESTY5164/Majestys-scripts/main/Dex.lua"
                loadstring(game:HttpGet(Dexlink))()
            else
                addCommandOutput("Dex is already loaded")
            end
    elseif args[1] == "Zoom" then
        if tonumber(args[2]) or args[2] == "uncap" then
            if args[2] == "uncap" or tonumber(args[2]) > 99999 then
                zoom = 100000
            elseif tonumber(args[2]) < 1 then
                zoom = 0
            else
                zoom = tonumber(args[2])
            end
            game.Players.LocalPlayer.CameraMaxZoomDistance = zoom
            addCommandOutput("Players camera zoom was set to ".. zoom)
        else
            addCommandOutput("Invalid args")
        end
    elseif args[1] == "UnlockMouse" then
        if args[2] == "true" then
                mouse = true
                addCommandOutput("First Person mouse has been unlocked")
        elseif args[2] == "false" then
                mouse = false
                addCommandOutput("First Person mouse has been locked")
        else
        addCommandOutput("Invalid args")
        end
    elseif args[1] == "ToolGiver" then
        toolgiver()
        addCommandOutput("Tool Giver loaded")
    elseif args[1] == "GetExecutor" then
        addCommandOutput("Gathering Executor information this may take a screenshot and start recording")
        exec()
        wait(1)
        while gathering do
        wait(0)
        end
        wait(1)
        addCommandOutput("Executor Name  | "..getgenv().execinfo["Name"])
        addCommandOutput("Executor Level | "..getgenv().execinfo["Level"])
        addCommandOutput("Executor Unc   | "..getgenv().execinfo["Unc"].."%")
        addCommandOutput("Executor Vuln  | "..getgenv().execinfo["Vuln"].."%")
    elseif args[1] == "DebugTool" then
        DebugTool()
        addCommandOutput("Debug Tool added to backpack")
    else
        addCommandOutput("No Command found, Send \"Help\" for a list of commands")
    end
else
    addCommandOutput("Please wait, Gathering Executor Information")
end
end

inputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local userInput = inputBox.Text
        if userInput ~= "" then
            cmd(userInput)
            inputBox.Text = "" 
        end
        task.wait()
        if focus then
        inputBox:CaptureFocus()
        else
        inputBox:ReleaseFocus()
        focus = true
        end
    end
end)



local UserInputService = game:GetService("UserInputService")

local function onKeyPress(input, gameProcessed)
    if not gameProcessed then  
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode[minkey] then
            ShowGui()
        end
    end
end

UserInputService.InputBegan:Connect(onKeyPress)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end)

if not og then
    while true do
        if getgenv().multi == false then
            CommandPrompt:Destroy()
        end
        wait(0)
    end
end
