local ADDON_NAME = ...

-- Constants for the target subzone and sound ID ranges
local TARGET_ZONE = 2339
local SOUND_RANGES = {
	{ Start = 1393680, End = 1394257 },
	{ Start = 567619, End = 567916 },

	{ Start = 1302923, End = 1302932 },
	{ Start = 1302596, End = 1302605 },
	{ Start = 5919829, End = 5919837 },

	{ Start = 5919829, End = 5919837 },
	{ Start = 5919761, End = 5919779 },
	{ Start = 5919528, End = 5919549 },
	{ Start = 5919592, End = 5919626 },
}

-- Boolean to keep track of whether sounds are muted or not
local isMuted = false

-- Function to mute a specific sound by ID
local function MuteSound(soundID)
	pcall(MuteSoundFile, soundID)
end

-- Function to unmute a specific sound by ID
local function UnmuteSound(soundID)
	pcall(UnmuteSoundFile, soundID)
end

-- Function to mute all sounds in the defined ranges
local function MuteSounds()
	for _, range in ipairs(SOUND_RANGES) do
		for soundID = range.Start, range.End do
			MuteSound(soundID)
		end
	end
	isMuted = true
end

-- Function to unmute all sounds in the defined ranges
local function UnmuteSounds()
	for _, range in ipairs(SOUND_RANGES) do
		for soundID = range.Start, range.End do
			UnmuteSound(soundID)
		end
	end
	isMuted = false
end

-- Function to check the current zone and mute/unmute sounds accordingly
local function CheckZone()
	if C_Map.GetBestMapForUnit("player") == TARGET_ZONE then
		if not isMuted then
			MuteSounds()
		end
	else
		if isMuted then
			UnmuteSounds()
		end
	end
end

-- Function to initialize the addon and set up event handlers
local function InitializeAddon()
	local frame = CreateFrame("Frame", "ContendersGateSoundMute")
	frame:SetScript("OnEvent", CheckZone)
	frame:RegisterEvent("ZONE_CHANGED")
	frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")

	-- Initial check to mute/unmute sounds when the addon loads
	C_Timer.After(1, CheckZone)
end

-- Call the initialization function when the addon is loaded
InitializeAddon()
