local Tooltip = require(script.Parent)

local RANDOMIZE_CHARACTERS = false
local RANDOMIZE_CHARACTERS_LENGTH = 200

return function(rootObject: ScreenGui)
	local root = Instance.new("Frame")
	root.BackgroundTransparency = 1
	root.BorderSizePixel = 0
	root.Size = UDim2.fromScale(1, 1)
	root.Parent = rootObject

	local tooltip = Tooltip.new(root, "So basic, yet so useful!")

	local randomizeCharactersCorotine: thread?
	if RANDOMIZE_CHARACTERS then
		randomizeCharactersCorotine = coroutine.create(function()
			while true do
				local newText = ""
				for _ = 1, RANDOMIZE_CHARACTERS_LENGTH do
					newText ..= string.char(math.random(65, 90))
					if math.random(1, 10) == 1 then
						newText ..= " "
					end
				end
				tooltip:SetText(newText)
				task.wait(0.1)
			end
		end)
		if randomizeCharactersCorotine then coroutine.resume(randomizeCharactersCorotine) end
	end

	return function()
		tooltip:Destroy()
		root:Destroy()
		if randomizeCharactersCorotine then
			coroutine.close(randomizeCharactersCorotine)
			randomizeCharactersCorotine = nil
		end
	end
end
