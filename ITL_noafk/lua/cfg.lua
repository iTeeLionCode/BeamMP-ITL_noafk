local MODULE = {}
local pluginPath = debug.getinfo(1).source:match("@?(.*/)") .. "../config/"

local function readFile(path)
    local file = io.open(path, "rb")
    if not file then
       return nil
    else
       local content = file:read "*a"
       file:close()
       return content
    end
end

function MODULE.getGlobal(filePath)
    local config = nil

    if (FS.IsFile(filePath)) then
        config = Util.JsonDecode(readFile(filePath))
    end

    local overrideFilePath = FS.GetParentFolder(filePath) .. "/override_" .. FS.GetFilename(filePath)
    if (FS.IsFile(overrideFilePath)) then
        configOverride = Util.JsonDecode(readFile(overrideFilePath))
        for key, value in pairs(configOverride) do
            config[key] = value
        end
    end

    return config
end

function MODULE.get(fileName)
    local filePath = pluginPath .. fileName
    return MODULE.getGlobal(filePath)
end

return MODULE