--[[
    Put this in RuneU Folder
]]

local runeu = require(script.Parent.Parent.Init)
local libraries = script.Parent:WaitForChild("libraries")

for _, library in ipairs(libraries:GetChildren()) do
	if library:IsA("StringValue") then
		task.spawn(function()
			local success, err = pcall(function()
				runeu.Run(library.Value)
			end)

			if not success then
				warn("RuneU library failed:", library.Name, err)
			end
		end)
	end
end
