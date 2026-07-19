local Interpreter = require(script.Parent.Parent.src.Interpreter)

return function(rune)
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local ServerStorage = game:GetService("ServerStorage")
	local Lighting = game:GetService("Lighting")
	local Debris = game:GetService("Debris")
	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")
	local StarterGui = game:GetService("StarterGui")
	local StarterPack = game:GetService("StarterPack")
	local StarterPlayer = game:GetService("StarterPlayer")

	-- RuneU function values are plain tables ({__isFunction = true, ...}),
	-- not real Luau functions, so RBXScriptSignal:Connect/Once would reject
	-- them outright. This wraps a RuneU callback (or a native Luau function)
	-- into something Roblox can actually invoke.
	local function wrapCallback(fn)
		if type(fn) == "function" then
			return fn
		end
		return function(...)
			return Interpreter.callFunction(fn, { ... })
		end
	end

	rune.RegisterLibrary("rbx", {
		new = Instance.new,

		getService = function(_, name)
			return game:GetService(name)
		end,

		findFirstChild = function(self, name)
			return self:FindFirstChild(name)
		end,

		waitForChild = function(self, name, timeout)
			return self:WaitForChild(name, timeout)
		end,

		destroy = function(self)
			self:Destroy()
		end,

		clone = function(self)
			return self:Clone()
		end,

		isA = function(self, className)
			return self:IsA(className)
		end,

		getChildren = function(self)
			return self:GetChildren()
		end,

		getDescendants = function(self)
			return self:GetDescendants()
		end,

		findFirstAncestor = function(self, name)
			return self:FindFirstAncestor(name)
		end,

		findFirstAncestorOfClass = function(self, className)
			return self:FindFirstAncestorOfClass(className)
		end,

		findFirstAncestorWhichIsA = function(self, className)
			return self:FindFirstAncestorWhichIsA(className)
		end,

		getAttribute = function(self, name)
			return self:GetAttribute(name)
		end,

		setAttribute = function(self, name, value)
			self:SetAttribute(name, value)
		end,

		hasTag = function(self, tag)
			return self:HasTag(tag)
		end,
		
		setTag = function(self, tag)
			self:AddTag(tag)
		end,
		
		removeTag = function(self, tag)
			self:RemoveTag(tag)
		end,
		
		getTags = function(self)
			return self:GetTags()
		end,

		clearAllChildren = function(self)
			self:ClearAllChildren()
		end,

		-- RBXScriptSignal helpers -------------------------------------------------
		-- rbx.connect(part.Touched, func(other) ... end)
		connect = function(signal, fn)
			return signal:Connect(wrapCallback(fn))
		end,

		once = function(signal, fn)
			return signal:Once(wrapCallback(fn))
		end,

		wait = function(signal)
			return signal:Wait()
		end,

		disconnect = function(connection)
			connection:Disconnect()
		end,

		isConnected = function(connection)
			return connection.Connected
		end,

		Vector2 = Vector2.new,
		Vector3 = Vector3.new,
		UDim = UDim.new,
		UDim2 = UDim2.new,
		CFrame = CFrame.new,
		Color3 = Color3.new,
		Color3RGB = Color3.fromRGB,
		BrickColor = BrickColor.new,
		Ray = Ray.new,
		Rect = Rect.new,
		NumberSequence = NumberSequence.new,
		ColorSequence = ColorSequence.new,
		NumberRange = NumberRange.new,
		PhysicalProperties = PhysicalProperties.new,
		RaycastParams = RaycastParams.new,
		NumberSequenceKeypoint = NumberSequenceKeypoint.new,
		ColorSequenceKeypoint = ColorSequenceKeypoint.new,
		Region3int16 = Region3int16.new,
		Font = Font.new,
		DateTime = DateTime.fromUnixTimestamp,

		Enum = Enum,

		game = game,
		workspace = workspace,

		Players = Players,
		RunService = RunService,
		ReplicatedStorage = ReplicatedStorage,
		ServerStorage = ServerStorage,
		Lighting = Lighting,
		Debris = Debris,
		TweenService = TweenService,
		UserInputService = UserInputService,
		StarterGui = StarterGui,
		StarterPack = StarterPack,
		StarterPlayer = StarterPlayer,
		StarterCharacterScripts = StarterPlayer.StarterCharacterScripts,
		StarterPlayerScripts = StarterPlayer.StarterPlayerScripts,
	})
end
