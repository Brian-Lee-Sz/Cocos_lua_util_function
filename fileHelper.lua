--region fileHelper.lua
--Author : brianlee
--Date   : 2017/9/15
FileHelper = {}

FileHelper.rootPath = device.writablePath

if device.platform == "android" and string.len(device.android_sd_Path) > 0 then
	FileHelper.rootPath = device.android_sd_Path
end

FileHelper.STORE_ID = 1                     --商场存储数据文件目录

FileHelper.CASPASUSUN_CONFIG_ID = 2         --caspasusun选场配置文件

FileHelper.ERROR_FILE_ID = 3                --错误信息文件

FileHelper.default_path = {}

FileHelper.default_path[FileHelper.STORE_ID] = string.format(".%s%s%s%d%s", PACKAGE_NAME, device.directorySeparator, "store_", userid or 0, ".json")

FileHelper.default_path[FileHelper.CASPASUSUN_CONFIG_ID] = string.format(".%s%s%s%d%s", PACKAGE_NAME, device.directorySeparator, "game_select_", GAMEID.THIRTEEN_ID, ".json")

FileHelper.default_path[FileHelper.ERROR_FILE_ID] = string.format(".%s%s%s%s", PACKAGE_NAME, device.directorySeparator, "game_lua_error", ".json")

FileHelper.USER_INFO_CONFIG = string.format(".%s%s%s%s", PACKAGE_NAME, device.directorySeparator, "user_config", ".json")


--[[    path:文件名或者相对路径
]]
function FileHelper:readFile(path)
	local path = path or "unKnow.json"
	local path = FileHelper.default_path[path] or path
	local filePath = string.format("%s%s", FileHelper.rootPath, path)
	local file = io.open(filePath, "r")
	if file then
		local content = file:read("*a")
		io.close(file)
		return content
	end
	return nil
end

function FileHelper:writeFile(path, content)
	if not content or content == "" then
		return false
	end
	local path = path or "unKnow.json"
	local path = FileHelper.default_path[path] or path
	local temp = string.split(path, device.directorySeparator)
	local temp_path = FileHelper.rootPath
	local table_len = #(temp or {})
	for index, _path in pairs(temp or {}) do
		if index ~= table_len and string.len(_path) > 0 then
			temp_path = string.format("%s%s%s", temp_path, _path, device.directorySeparator)
			cc.FileUtils:getInstance():createDirectory(temp_path)
		end
	end
	local filePath = string.format("%s%s", FileHelper.rootPath, path)
	local file = io.open(filePath, "w")
	if file then
		if file:write(content) == nil then return false end
		io.close(file)
		return true
	else
		return false
	end
end

function FileHelper:appendFile(path, content, isNewLine)
	if not content or content == "" then
		return false
	end
	if isNewLine then
		content = string.format("%s%s", "\n", content)
	end
	local path = path or "unKnow.json"
	local path = FileHelper.default_path[path] or path
	local temp = string.split(path, device.directorySeparator)
	local temp_path = FileHelper.rootPath
	local table_len = #(temp or {})
	for index, _path in pairs(temp or {}) do
		if index ~= table_len and string.len(_path) > 0 then
			temp_path = string.format("%s%s%s", temp_path, _path, device.directorySeparator)
			cc.FileUtils:getInstance():createDirectory(temp_path)
		end
	end
	local filePath = string.format("%s%s", FileHelper.rootPath, path)
	local file = io.open(filePath, "a")
	if file then
		if file:write(content) == nil then return false end
		io.close(file)
		return true
	else
		return false
	end
end

function FileHelper:setStringForKey(key, value)
	if key and string.len(key) > 0 and value then
		local config = cjson.decode(self:readFile(FileHelper.USER_INFO_CONFIG) or "{}")
		config[key] = value
		self:writeFile(FileHelper.USER_INFO_CONFIG, cjson.encode(config))
	end
end

function FileHelper:getStringForKey(key, defaultValue)
	if key then
		local config = cjson.decode(self:readFile(FileHelper.USER_INFO_CONFIG) or "{}")
		if config[key] then
			return config[key]
		else
			return defaultValue
		end
	end
end

--获取聊天信息记录
function FileHelper:getChatRecord(uid)
	if uid then
		local path = string.format(".%s%s%d_%s%d", PACKAGE_NAME, device.directorySeparator, UserDataController.getUserID(), "temp_", uid)
		local temp = string.split(self:readFile(path) or "", "&&")
		local config = {}
		for k, v in pairs(temp) do
			if string.len(v) > 0 then
				table.insert(config, cjson.decode(v))
			end
		end
		if uid == 120 and #config == 0 then
			table.insert(config, {msg = "Hoan nghênh đến với Halo Binh.Chúc các bạn vui vẻ!\nNếu có vấn đề hãy liên hệ với CSKH nhé!", uid = 120, msgType = 4, userName = "Hệ Thống", iconPath = "common/system_icon.png"})
		end
		return config
	end
end

function FileHelper:saveChatRecord(uid, msg, isAppend)
	if uid and msg and type(msg) == "table" then
		local path = string.format(".%s%s%d_%s%d", PACKAGE_NAME, device.directorySeparator, UserDataController.getUserID(), "temp_", uid)
		if isAppend then
			self:appendFile(path, string.format("%s%s", "&&", cjson.encode(msg)))
		else
			local isStart = true
			local str = ""
			local r_len = #msg - 30 > 0 and #msg - 30 or 0
			for k, v in pairs(msg) do
				if k > r_len then
					str = isStart and string.format("%s%s", str, cjson.encode(v)) or string.format("%s&&%s", str, cjson.encode(v))
					isStart = false
				end
			end
			self:writeFile(path, str)
		end
	end
end 
