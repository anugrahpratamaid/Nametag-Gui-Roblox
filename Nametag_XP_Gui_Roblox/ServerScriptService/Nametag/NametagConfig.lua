local config = {}

local Titles = {
	{min = 300, text = "Lumber Realm"},
	{min = 200, text = "Axe Glory"},
	{min = 110, text = "Timber tap"},
	{min = 50,  text = "Lumber Man"},
	{min = 20,  text = "Axe Mastery"},
	{min = 0,   text = "Beginner"},
}

-- Table untuk Warna
local Colors = {
	{min = 700, color = Color3.fromRGB(213, 5, 255)},
	{min = 500, color = Color3.fromRGB(255, 5, 5)},
	{min = 300, color = Color3.fromRGB(240, 106, 16)},
	{min = 150, color = Color3.fromRGB(33, 154, 229)},
	{min = 50,  color = Color3.fromRGB(0, 194, 0)},
	{min = 0,   color = Color3.fromRGB(255, 255, 255)},
}

-- Fungsi Title
function config.getTitle(level)
	for _, data in ipairs(Titles) do
		if level >= data.min then
			return data.text
		end
	end
	return "Beginner"
end

-- Fungsi Warna
function config.getLevelColor(level)
	for _, data in ipairs(Colors) do
		if level >= data.min then
			return data.color
		end
	end
	return Color3.fromRGB(255, 255, 255)
end

return config
