BadCoderz.GMA_DB = {}

local function nextzero(file, _return)
	local byte = file:ReadByte()
	local str = ""

	while (byte ~= 0) do
		if (_return) then
			str = str .. string.char(byte)
		end

		byte = file:ReadByte()
	end

	if _return then return str end
end

local function parseFileList(gma_path)
	local gma = file.Open(gma_path, "rb", "GAME")
	if not gma then return nil end
	local filelist = {}
	gma:Skip(22)
	nextzero(gma)
	nextzero(gma)
	nextzero(gma)
	gma:Skip(4)

	while (true) do
		local finenum = gma:ReadLong()
		if (finenum == 0) then break end -- 2019 hack
		local fileName = nextzero(gma, true)

		if string.EndsWith(fileName, ".lua") then
			table.insert(filelist, fileName)
		end

		gma:Skip(12)
	end

	gma:Close()

	return filelist
end

local function buildDataBase()
	for k, v in ipairs(engine.GetAddons()) do
		if v.mounted == false then continue end
		local fileList = parseFileList(v.file)
		BadCoderz.GMA_DB[v.file] = fileList
	end
end

hook.Add("Initialize", "BadCoderzBuildDB", buildDataBase)