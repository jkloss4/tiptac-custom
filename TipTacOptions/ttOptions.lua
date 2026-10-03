-- create addon
local MOD_NAME = ...;
local PARENT_MOD_NAME = "TipTac";
-- The options page: a canvas in Blizzard's Settings panel (Options > AddOns > TipTac), built entirely from
-- TipTacOptions' own frames (Blizzard's pooled Settings controls would run our code inside Blizzard's, which taints).
local f = CreateFrame("Frame", MOD_NAME);
f:Hide(); -- start hidden, so the Settings panel showing it fires OnShow (which fills in the current values)

-- get libs
local LibFroznFunctions = LibStub:GetLibrary("LibFroznFunctions-1.0");

-- set config
local configDb, cfg = LibFroznFunctions:CreateDbWithLibAceDB("TipTac_Config");

-- DropDown Lists: { label, value } in display order
local DROPDOWN_ANCHORTYPE = {
	{ "Normal Anchor", "normal" },
	{ "Mouse Anchor", "mouse" },
	{ "Parent Anchor", "parent" },
};

local DROPDOWN_ANCHORPOS = {
	{ "Top Left", "TOPLEFT" },
	{ "Top", "TOP" },
	{ "Top Right", "TOPRIGHT" },
	{ "Left", "LEFT" },
	{ "Center", "CENTER" },
	{ "Right", "RIGHT" },
	{ "Bottom Left", "BOTTOMLEFT" },
	{ "Bottom", "BOTTOM" },
	{ "Bottom Right", "BOTTOMRIGHT" },
};

-- Options: "y" adds space above an item; "x" puts a checkbox in the second column of the row above.

-- Anchors
-- offset slider for the given anchor frame ("WorldUnit", "WorldTip", "FrameUnit", "FrameTip") and axis ("X", "Y")
local function GetOffsetOption(anchorFrameName, axis)
	return { type = "Slider", var = "mouseOffset" .. anchorFrameName .. axis, label = axis .. " Offset", tip = "Offset of the tooltip from its anchor position, for any anchor type", min = -200, max = 200, step = 1, fontSizeDelta = -2, enabled = function(factory) return factory:GetConfigValue("enableAnchor") end };
end

local ttOptionsAnchors = {
	{ type = "DropDown", var = "anchorWorldUnitType", label = "World Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") end },
	{ type = "DropDown", var = "anchorWorldUnitPoint", label = "World Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") end },
	GetOffsetOption("WorldUnit", "X"),
	GetOffsetOption("WorldUnit", "Y"),

	{ type = "DropDown", var = "anchorWorldTipType", label = "World Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 },
	{ type = "DropDown", var = "anchorWorldTipPoint", label = "World Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") end },
	GetOffsetOption("WorldTip", "X"),
	GetOffsetOption("WorldTip", "Y"),

	{ type = "DropDown", var = "anchorFrameUnitType", label = "Frame Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 },
	{ type = "DropDown", var = "anchorFrameUnitPoint", label = "Frame Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") end },
	GetOffsetOption("FrameUnit", "X"),
	GetOffsetOption("FrameUnit", "Y"),

	{ type = "DropDown", var = "anchorFrameTipType", label = "Frame Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 },
	{ type = "DropDown", var = "anchorFrameTipPoint", label = "Frame Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") end },
	GetOffsetOption("FrameTip", "X"),
	GetOffsetOption("FrameTip", "Y")
};

local priority = 0;

if (LibFroznFunctions.hasWoWFlavor.challengeMode) then
	priority = priority + 1;
	tinsert(ttOptionsAnchors, { type = "Header", label = "Priority #" .. priority .. ": Anchor Overrides During Challenge Mode", tip = "Special anchor overrides during challenge mode (Mythic+) in and out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end });
	
	tinsert(ttOptionsAnchors, { type = "TextOnly", label = "In Combat" });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldUnitDuringChallengeModeInCombat", label = "World Unit during challenge mode in combat", tip = "This option will override the anchor for World Unit during challenge mode (Mythic+) in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitTypeDuringChallengeModeInCombat", label = "World Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitDuringChallengeModeInCombat") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitPointDuringChallengeModeInCombat", label = "World Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitDuringChallengeModeInCombat") end });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldTipDuringChallengeModeInCombat", label = "World Tip during challenge mode in combat", tip = "This option will override the anchor for World Tip during challenge mode (Mythic+) in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipTypeDuringChallengeModeInCombat", label = "World Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipDuringChallengeModeInCombat") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipPointDuringChallengeModeInCombat", label = "World Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipDuringChallengeModeInCombat") end });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameUnitDuringChallengeModeInCombat", label = "Frame Unit during challenge mode in combat", tip = "This option will override the anchor for Frame Unit during challenge mode (Mythic+) in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitTypeDuringChallengeModeInCombat", label = "Frame Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitDuringChallengeModeInCombat") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitPointDuringChallengeModeInCombat", label = "Frame Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitDuringChallengeModeInCombat") end });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameTipDuringChallengeModeInCombat", label = "Frame Tip during challenge mode in combat", tip = "This option will override the anchor for Frame Tip during challenge mode (Mythic+) in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipTypeDuringChallengeModeInCombat", label = "Frame Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipDuringChallengeModeInCombat") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipPointDuringChallengeModeInCombat", label = "Frame Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipDuringChallengeModeInCombat") end });
	
	tinsert(ttOptionsAnchors, { type = "TextOnly", label = "Out Of Combat", y = 10 });

	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldUnitDuringChallengeMode", label = "World Unit during challenge mode out of combat", tip = "This option will override the anchor for World Unit during challenge mode (Mythic+) out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitTypeDuringChallengeMode", label = "World Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitDuringChallengeMode") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitPointDuringChallengeMode", label = "World Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitDuringChallengeMode") end });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldTipDuringChallengeMode", label = "World Tip during challenge mode out of combat", tip = "This option will override the anchor for World Tip during challenge mode (Mythic+) out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipTypeDuringChallengeMode", label = "World Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipDuringChallengeMode") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipPointDuringChallengeMode", label = "World Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipDuringChallengeMode") end });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameUnitDuringChallengeMode", label = "Frame Unit during challenge mode out of combat", tip = "This option will override the anchor for Frame Unit during challenge mode (Mythic+) out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitTypeDuringChallengeMode", label = "Frame Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitDuringChallengeMode") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitPointDuringChallengeMode", label = "Frame Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitDuringChallengeMode") end });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameTipDuringChallengeMode", label = "Frame Tip during challenge mode out of combat", tip = "This option will override the anchor for Frame Tip during challenge mode (Mythic+) out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipTypeDuringChallengeMode", label = "Frame Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipDuringChallengeMode") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipPointDuringChallengeMode", label = "Frame Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipDuringChallengeMode") end });
end

priority = priority + 1;
tinsert(ttOptionsAnchors, { type = "Header", label = "Priority #" .. priority .. ": Anchor Overrides During An Instance", tip = "Special anchor overrides during an instance (Dungeon, Raid, PvP, Arena, Scenario) in and out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end });

tinsert(ttOptionsAnchors, { type = "TextOnly", label = "In Combat" });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldUnitDuringInstanceInCombat", label = "World Unit during an instance in combat", tip = "This option will override the anchor for World Unit during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitTypeDuringInstanceInCombat", label = "World Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitDuringInstanceInCombat") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitPointDuringInstanceInCombat", label = "World Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitDuringInstanceInCombat") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldTipDuringInstanceInCombat", label = "World Tip during an instance in combat", tip = "This option will override the anchor for World Tip during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipTypeDuringInstanceInCombat", label = "World Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipDuringInstanceInCombat") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipPointDuringInstanceInCombat", label = "World Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipDuringInstanceInCombat") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameUnitDuringInstanceInCombat", label = "Frame Unit during an instance in combat", tip = "This option will override the anchor for Frame Unit during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitTypeDuringInstanceInCombat", label = "Frame Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitDuringInstanceInCombat") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitPointDuringInstanceInCombat", label = "Frame Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitDuringInstanceInCombat") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameTipDuringInstanceInCombat", label = "Frame Tip during an instance in combat", tip = "This option will override the anchor for Frame Tip during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipTypeDuringInstanceInCombat", label = "Frame Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipDuringInstanceInCombat") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipPointDuringInstanceInCombat", label = "Frame Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipDuringInstanceInCombat") end });

tinsert(ttOptionsAnchors, { type = "TextOnly", label = "Out Of Combat", y = 10 });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldUnitDuringInstance", label = "World Unit during an instance out of combat", tip = "This option will override the anchor for World Unit during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitTypeDuringInstance", label = "World Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitDuringInstance") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitPointDuringInstance", label = "World Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitDuringInstance") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldTipDuringInstance", label = "World Tip during an instance out of combat", tip = "This option will override the anchor for World Tip during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipTypeDuringInstance", label = "World Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipDuringInstance") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipPointDuringInstance", label = "World Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipDuringInstance") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameUnitDuringInstance", label = "Frame Unit during an instance out of combat", tip = "This option will override the anchor for Frame Unit during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitTypeDuringInstance", label = "Frame Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitDuringInstance") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitPointDuringInstance", label = "Frame Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitDuringInstance") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameTipDuringInstance", label = "Frame Tip during an instance out of combat", tip = "This option will override the anchor for Frame Tip during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipTypeDuringInstance", label = "Frame Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipDuringInstance") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipPointDuringInstance", label = "Frame Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipDuringInstance") end });

if (LibFroznFunctions.hasWoWFlavor.skyriding) then
	priority = priority + 1;
	tinsert(ttOptionsAnchors, { type = "Header", label = "Priority #" .. priority .. ": Anchor Overrides During Skyriding", tip = "Special anchor overrides during skyriding", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldUnitDuringSkyriding", label = "World Unit during skyriding", tip = "This option will override the anchor for World Unit during skyriding", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitTypeDuringSkyriding", label = "World Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitDuringSkyriding") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitPointDuringSkyriding", label = "World Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitDuringSkyriding") end });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldTipDuringSkyriding", label = "World Tip during skyriding", tip = "This option will override the anchor for World Tip during skyriding", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipTypeDuringSkyriding", label = "World Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipDuringSkyriding") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipPointDuringSkyriding", label = "World Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipDuringSkyriding") end });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameUnitDuringSkyriding", label = "Frame Unit during skyriding", tip = "This option will override the anchor for Frame Unit during skyriding", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitTypeDuringSkyriding", label = "Frame Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitDuringSkyriding") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitPointDuringSkyriding", label = "Frame Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitDuringSkyriding") end });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameTipDuringSkyriding", label = "Frame Tip during skyriding", tip = "This option will override the anchor for Frame Tip during skyriding", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipTypeDuringSkyriding", label = "Frame Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipDuringSkyriding") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipPointDuringSkyriding", label = "Frame Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipDuringSkyriding") end });
end

priority = priority + 1;
tinsert(ttOptionsAnchors, { type = "Header", label = "Priority #" .. priority .. ": Anchor Overrides For In Combat", tip = "Special anchor overrides for in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldUnitInCombat", label = "World Unit in combat", tip = "This option will override the anchor for World Unit in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitTypeInCombat", label = "World Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitInCombat") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitPointInCombat", label = "World Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitInCombat") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldTipInCombat", label = "World Tip in combat", tip = "This option will override the anchor for World Tip in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipTypeInCombat", label = "World Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipInCombat") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipPointInCombat", label = "World Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipInCombat") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameUnitInCombat", label = "Frame Unit in combat", tip = "This option will override the anchor for Frame Unit in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitTypeInCombat", label = "Frame Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitInCombat") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitPointInCombat", label = "Frame Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitInCombat") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameTipInCombat", label = "Frame Tip in combat", tip = "This option will override the anchor for Frame Tip in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipTypeInCombat", label = "Frame Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipInCombat") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipPointInCombat", label = "Frame Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipInCombat") end });

tinsert(ttOptionsAnchors, { type = "Header", label = "Other Anchor Overrides", tip = "Other special anchor overrides", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideCF", label = "(Guild & Community) ChatFrame", tip = "This option will override the anchor for (Guild & Community, addon WIM) ChatFrame", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorOverrideCFType", label = "Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideCF") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorOverrideCFPoint", label = "Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideCF") end });

-- Hiding
local ttOptionsHiding = {};
priority = 0;

if (LibFroznFunctions.hasWoWFlavor.challengeMode) then
	priority = priority + 1;
	tinsert(ttOptionsHiding, { type = "Header", var = "hideTipsDuringChallengeModeHeader", label = "Priority #" .. priority .. ": Hide Tips During Challenge Mode" });
	
	tinsert(ttOptionsHiding, { type = "TextOnly", var = "hideTipsDuringChallengeModeInCombat", label = "In Combat", belongsTo = "hideTipsDuringChallengeModeHeader" });
	
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeInCombatWorldUnits", label = "Hide World Units", tip = "When you have this option checked, World Units will be hidden during challenge mode (Mythic+) in combat.", y = 10, belongsTo = "hideTipsDuringChallengeModeInCombat" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeInCombatFrameUnits", label = "Hide Frame Units", tip = "When you have this option checked, Frame Units will be hidden during challenge mode (Mythic+) in combat.", x = 160, belongsTo = "hideTipsDuringChallengeModeInCombatWorldUnits" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeInCombatWorldTips", label = "Hide World Tips", tip = "When you have this option checked, World Tips will be hidden during challenge mode (Mythic+) in combat.", belongsTo = "hideTipsDuringChallengeModeInCombat" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeInCombatFrameTips", label = "Hide Frame Tips", tip = "When you have this option checked, Frame Tips will be hidden during challenge mode (Mythic+) in combat.", x = 160, belongsTo = "hideTipsDuringChallengeModeInCombatWorldTips" });
	
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeInCombatUnitTips", label = "Hide Unit Tips", tip = "When you have this option checked, Unit Tips will be hidden during challenge mode (Mythic+) in combat.", y = 10, belongsTo = "hideTipsDuringChallengeModeInCombat" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeInCombatSpellTips", label = "Hide Spell Tips", tip = "When you have this option checked, Spell Tips will be hidden during challenge mode (Mythic+) in combat.", x = 160, belongsTo = "hideTipsDuringChallengeModeInCombatUnitTips" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeInCombatItemTips", label = "Hide Item Tips", tip = "When you have this option checked, Item Tips will be hidden during challenge mode (Mythic+) in combat.", belongsTo = "hideTipsDuringChallengeModeInCombat" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeInCombatActionTips", label = "Hide Action Bar Tips", tip = "When you have this option checked, Action Bar Tips will be hidden during challenge mode (Mythic+) in combat.", belongsTo = "hideTipsDuringChallengeModeInCombat" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeInCombatExpBarTips", label = "Hide Exp Bar Tips", tip = "When you have this option checked, Experience Bar Tips will be hidden during challenge mode (Mythic+) in combat.", x = 160, belongsTo = "hideTipsDuringChallengeModeInCombatActionTips" });
	
	tinsert(ttOptionsHiding, { type = "TextOnly", var = "hideTipsDuringChallengeMode", label = "Out Of Combat", y = 10, belongsTo = "hideTipsDuringChallengeModeHeader" });
	
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeWorldUnits", label = "Hide World Units", tip = "When you have this option checked, World Units will be hidden during challenge mode (Mythic+) out of combat.", y = 10, belongsTo = "hideTipsDuringChallengeMode" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeFrameUnits", label = "Hide Frame Units", tip = "When you have this option checked, Frame Units will be hidden during challenge mode (Mythic+) out of combat.", x = 160, belongsTo = "hideTipsDuringChallengeModeWorldUnits" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeWorldTips", label = "Hide World Tips", tip = "When you have this option checked, World Tips will be hidden during challenge mode (Mythic+) out of combat.", belongsTo = "hideTipsDuringChallengeMode" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeFrameTips", label = "Hide Frame Tips", tip = "When you have this option checked, Frame Tips will be hidden during challenge mode (Mythic+) out of combat.", x = 160, belongsTo = "hideTipsDuringChallengeModeWorldTips" });
	
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeUnitTips", label = "Hide Unit Tips", tip = "When you have this option checked, Unit Tips will be hidden during challenge mode (Mythic+) out of combat.", y = 10, belongsTo = "hideTipsDuringChallengeMode" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeSpellTips", label = "Hide Spell Tips", tip = "When you have this option checked, Spell Tips will be hidden during challenge mode (Mythic+) out of combat.", x = 160, belongsTo = "hideTipsDuringChallengeModeUnitTips" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeItemTips", label = "Hide Item Tips", tip = "When you have this option checked, Item Tips will be hidden during challenge mode (Mythic+) out of combat.", belongsTo = "hideTipsDuringChallengeMode" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeActionTips", label = "Hide Action Bar Tips", tip = "When you have this option checked, Action Bar Tips will be hidden during challenge mode (Mythic+) out of combat.", belongsTo = "hideTipsDuringChallengeMode" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeExpBarTips", label = "Hide Exp Bar Tips", tip = "When you have this option checked, Experience Bar Tips will be hidden during challenge mode (Mythic+) out of combat.", x = 160, belongsTo = "hideTipsDuringChallengeModeActionTips" });
end

priority = priority + 1;
tinsert(ttOptionsHiding, { type = "Header", var = "hideTipsDuringInstanceHeader", label = "Priority #" .. priority .. ": Hide Tips During An Instance" });

tinsert(ttOptionsHiding, { type = "TextOnly", var = "hideTipsDuringInstanceInCombat", label = "In Combat", belongsTo = "hideTipsDuringInstanceHeader" });

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceInCombatWorldUnits", label = "Hide World Units", tip = "When you have this option checked, World Units will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat.", y = 10, belongsTo = "hideTipsDuringInstanceInCombat" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceInCombatFrameUnits", label = "Hide Frame Units", tip = "When you have this option checked, Frame Units will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat.", x = 160, belongsTo = "hideTipsDuringInstanceInCombatWorldUnits" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceInCombatWorldTips", label = "Hide World Tips", tip = "When you have this option checked, World Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat.", belongsTo = "hideTipsDuringInstanceInCombat" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceInCombatFrameTips", label = "Hide Frame Tips", tip = "When you have this option checked, Frame Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat.", x = 160, belongsTo = "hideTipsDuringInstanceInCombatWorldTips" });

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceInCombatUnitTips", label = "Hide Unit Tips", tip = "When you have this option checked, Unit Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat.", y = 10, belongsTo = "hideTipsDuringInstanceInCombat" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceInCombatSpellTips", label = "Hide Spell Tips", tip = "When you have this option checked, Spell Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat.", x = 160, belongsTo = "hideTipsDuringInstanceInCombatUnitTips" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceInCombatItemTips", label = "Hide Item Tips", tip = "When you have this option checked, Item Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat.", belongsTo = "hideTipsDuringInstanceInCombat" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceInCombatActionTips", label = "Hide Action Bar Tips", tip = "When you have this option checked, Action Bar Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat.", belongsTo = "hideTipsDuringInstanceInCombat" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceInCombatExpBarTips", label = "Hide Exp Bar Tips", tip = "When you have this option checked, Experience Bar Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat.", x = 160, belongsTo = "hideTipsDuringInstanceInCombatActionTips" });

tinsert(ttOptionsHiding, { type = "TextOnly", var = "hideTipsDuringInstance", label = "Out Of Combat", y = 10, belongsTo = "hideTipsDuringInstanceHeader" });

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceWorldUnits", label = "Hide World Units", tip = "When you have this option checked, World Units will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat.", y = 10, belongsTo = "hideTipsDuringInstance" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceFrameUnits", label = "Hide Frame Units", tip = "When you have this option checked, Frame Units will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat.", x = 160, belongsTo = "hideTipsDuringInstanceWorldUnits" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceWorldTips", label = "Hide World Tips", tip = "When you have this option checked, World Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat.", belongsTo = "hideTipsDuringInstance" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceFrameTips", label = "Hide Frame Tips", tip = "When you have this option checked, Frame Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat.", x = 160, belongsTo = "hideTipsDuringInstanceWorldTips" });

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceUnitTips", label = "Hide Unit Tips", tip = "When you have this option checked, Unit Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat.", y = 10, belongsTo = "hideTipsDuringInstance" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceSpellTips", label = "Hide Spell Tips", tip = "When you have this option checked, Spell Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat.", x = 160, belongsTo = "hideTipsDuringInstanceUnitTips" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceItemTips", label = "Hide Item Tips", tip = "When you have this option checked, Item Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat.", belongsTo = "hideTipsDuringInstance" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceActionTips", label = "Hide Action Bar Tips", tip = "When you have this option checked, Action Bar Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat.", belongsTo = "hideTipsDuringInstance" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceExpBarTips", label = "Hide Exp Bar Tips", tip = "When you have this option checked, Experience Bar Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat.", x = 160, belongsTo = "hideTipsDuringInstanceActionTips" });

if (LibFroznFunctions.hasWoWFlavor.skyriding) then
	priority = priority + 1;
	tinsert(ttOptionsHiding, { type = "Header", var = "hideTipsDuringSkyridingHeader", label = "Priority #" .. priority .. ": Hide Tips During Skyriding" });
	
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringSkyridingWorldUnits", label = "Hide World Units", tip = "When you have this option checked, World Units will be hidden during skyriding.", belongsTo = "hideTipsDuringSkyridingHeader" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringSkyridingFrameUnits", label = "Hide Frame Units", tip = "When you have this option checked, Frame Units will be hidden during skyriding.", x = 160, belongsTo = "hideTipsDuringSkyridingWorldUnits" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringSkyridingWorldTips", label = "Hide World Tips", tip = "When you have this option checked, World Tips will be hidden during skyriding.", belongsTo = "hideTipsDuringSkyridingHeader" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringSkyridingFrameTips", label = "Hide Frame Tips", tip = "When you have this option checked, Frame Tips will be hidden during skyriding.", x = 160, belongsTo = "hideTipsDuringSkyridingWorldTips" });
	
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringSkyridingUnitTips", label = "Hide Unit Tips", tip = "When you have this option checked, Unit Tips will be hidden during skyriding.", y = 10, belongsTo = "hideTipsDuringSkyridingHeader" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringSkyridingSpellTips", label = "Hide Spell Tips", tip = "When you have this option checked, Spell Tips will be hidden during skyriding.", x = 160, belongsTo = "hideTipsDuringSkyridingUnitTips" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringSkyridingItemTips", label = "Hide Item Tips", tip = "When you have this option checked, Item Tips will be hidden during skyriding.", belongsTo = "hideTipsDuringSkyridingHeader" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringSkyridingActionTips", label = "Hide Action Bar Tips", tip = "When you have this option checked, Action Bar Tips will be hidden during skyriding.", belongsTo = "hideTipsDuringSkyridingHeader" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringSkyridingExpBarTips", label = "Hide Exp Bar Tips", tip = "When you have this option checked, Experience Bar Tips will be hidden during skyriding.", x = 160, belongsTo = "hideTipsDuringSkyridingActionTips" });
end

priority = priority + 1;
tinsert(ttOptionsHiding, { type = "Header", var = "hideTipsInCombatHeader", label = "Priority #" .. priority .. ": Hide Tips In Combat" });

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatWorldUnits", label = "Hide World Units", tip = "When you have this option checked, World Units will be hidden in combat.", belongsTo = "hideTipsInCombatHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatFrameUnits", label = "Hide Frame Units", tip = "When you have this option checked, Frame Units will be hidden in combat.", x = 160, belongsTo = "hideTipsInCombatWorldUnits" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatWorldTips", label = "Hide World Tips", tip = "When you have this option checked, World Tips will be hidden in combat.", belongsTo = "hideTipsInCombatHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatFrameTips", label = "Hide Frame Tips", tip = "When you have this option checked, Frame Tips will be hidden in combat.", x = 160, belongsTo = "hideTipsInCombatWorldTips" });

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatUnitTips", label = "Hide Unit Tips", tip = "When you have this option checked, Unit Tips will be hidden in combat.", y = 10, belongsTo = "hideTipsInCombatHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatSpellTips", label = "Hide Spell Tips", tip = "When you have this option checked, Spell Tips will be hidden in combat.", x = 160, belongsTo = "hideTipsInCombatUnitTips" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatItemTips", label = "Hide Item Tips", tip = "When you have this option checked, Item Tips will be hidden in combat.", belongsTo = "hideTipsInCombatHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatActionTips", label = "Hide Action Bar Tips", tip = "When you have this option checked, Action Bar Tips will be hidden in combat.", belongsTo = "hideTipsInCombatHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatExpBarTips", label = "Hide Exp Bar Tips", tip = "When you have this option checked, Experience Bar Tips will be hidden in combat.", x = 160, belongsTo = "hideTipsInCombatActionTips" });

tinsert(ttOptionsHiding, { type = "Header", var = "hideTipsHeader", label = "Priority #" .. priority .. ": Hide Tips Out Of Combat" });

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsWorldUnits", label = "Hide World Units", tip = "When you have this option checked, World Units will be hidden.", belongsTo = "hideTipsHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsFrameUnits", label = "Hide Frame Units", tip = "When you have this option checked, Frame Units will be hidden.", x = 160, belongsTo = "hideTipsWorldUnits" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsWorldTips", label = "Hide World Tips", tip = "When you have this option checked, World Tips will be hidden.", belongsTo = "hideTipsHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsFrameTips", label = "Hide Frame Tips", tip = "When you have this option checked, Frame Tips will be hidden.", x = 160, belongsTo = "hideTipsWorldTips" });

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsUnitTips", label = "Hide Unit Tips", tip = "When you have this option checked, Unit Tips will be hidden.", y = 10, belongsTo = "hideTipsHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsSpellTips", label = "Hide Spell Tips", tip = "When you have this option checked, Spell Tips will be hidden.", x = 160, belongsTo = "hideTipsUnitTips" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsItemTips", label = "Hide Item Tips", tip = "When you have this option checked, Item Tips will be hidden.", belongsTo = "hideTipsHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsActionTips", label = "Hide Action Bar Tips", tip = "When you have this option checked, Action Bar Tips will be hidden.", belongsTo = "hideTipsHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsExpBarTips", label = "Hide Exp Bar Tips", tip = "When you have this option checked, Experience Bar Tips will be hidden.", x = 160, belongsTo = "hideTipsActionTips" });

tinsert(ttOptionsHiding, { type = "Header", label = "Hide Other Tips" });

if (LibFroznFunctions:IsAddOnEnabled("Blizzard_EncounterJournal")) then
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsEJDungeonRaidSetItemsSTT", label = "Hide Shopping Tips of Dungeon/Raid/Set Items in Adventure Guide", tip = "When you have this option checked, Shopping Tips of Dungeon/Raid/Set Items in Adventure Guide will be hidden." });
end

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsForOwnPets", label = "Hide Tips for My Own Pets/Minions", tip = "When you have this option checked, unit tooltips will be hidden for your own combat pets/minions (e.g. hunter pets including a 2nd Beast Mastery pet, warlock demons, death knight ghouls, mage water elementals). Pets/minions owned by other players are not affected." });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsForOwnCompanions", label = "Hide Tips for My Own Companion Pets", tip = "When you have this option checked, unit tooltips will be hidden for your own summoned non-combat companion (vanity) pets. Companion pets owned by other players are not affected." });

tinsert(ttOptionsHiding, { type = "Header", label = "Others" });

tinsert(ttOptionsHiding, { type = "DropDown", var = "showHiddenModifierKey", label = "Show Hidden Tips While Holding", tip = "Hidden tips still show while this modifier key is held.", list = { { "Shift", "shift" }, { "Ctrl", "ctrl" }, { "Alt", "alt" }, { "|cffffa0a0None", "none" } } });

-- build options
local options = {
	-- Fading
	{
		category = "Fading",
		options = {
			{ type = "Header", label = "Fading for Unit Tooltips" },
			
			{ type = "Check", var = "overrideFade", label = "Enable Override Default GameTooltip Fade for Unit Tooltips", tip = "Overrides the default fadeout function of the GameTooltip for units. If you are seeing problems regarding fadeout, please disable." },
			
			{ type = "Slider", var = "preFadeTime", label = "Prefade Time", min = 0, max = 5, step = 0.05, enabled = function(factory) return factory:GetConfigValue("overrideFade") end, y = 10 },
			{ type = "Slider", var = "fadeTime", label = "Fadeout Time", min = 0, max = 5, step = 0.05, enabled = function(factory) return factory:GetConfigValue("overrideFade") end },
			
			{ type = "Header", label = "Others" },
			
			{ type = "Check", var = "hideWorldTips", label = "Instantly Hide World Frame Tips", tip = "This option will make most tips which appear from objects in the world disappear instantly when you take the mouse off the object. Examples such as mailboxes, herbs or chests.\nNOTE: Does not work for all world objects." },
		}
	},
	-- Anchors
	{
		category = "Anchors",
		enabled = { type = "Check", var = "enableAnchor", tip = "Turns on or off all modifications of the anchor" },
		options = ttOptionsAnchors
	},
	-- Hiding
	{
		category = "Hiding",
		options = ttOptionsHiding
	},
};

--------------------------------------------------------------------------------------------------------
--                                            Options Page                                            --
--------------------------------------------------------------------------------------------------------
-- One page with a tab per category (Fading, Anchors, Hiding), styled like the other addons' pages: Blizzard's
-- checkboxes, dropdowns and sliders, laid out top to bottom in a scrollable pane.

local TipTac = _G[PARENT_MOD_NAME];

local LEFT_MARGIN = 16;
local COLUMN2_X = 300;   -- second-column checkboxes ("x" option)
local LABEL_COL_W = 190; -- labels before dropdowns and sliders, so the controls line up

-- passed to the options' enabled() functions, which expect the old options factory
local factory = {
	GetConfigValue = function(_, var) return cfg[var]; end,
};

local refreshers = {};

local function RefreshAll()
	for _, refresh in ipairs(refreshers) do
		refresh();
	end
end

local function SetConfigValue(var, value)
	cfg[var] = value;
	TipTac:ApplyConfig();
	RefreshAll();
end

local function IsEnabled(option)
	return (not option.enabled) or (not not option.enabled(factory, nil, option, cfg[option.var]));
end

local function SetTooltip(region, title, text)
	if (not text) then
		return;
	end
	region:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:AddLine(title, 1, 1, 1);
		GameTooltip:AddLine(text, nil, nil, nil, true);
		GameTooltip:Show();
	end);
	region:HookScript("OnLeave", GameTooltip_Hide);
end

-- title, version and the page buttons
local title = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightHuge");
title:SetPoint("TOPLEFT", LEFT_MARGIN, -16);
title:SetText(PARENT_MOD_NAME);

local version = f:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall");
version:SetPoint("BOTTOMLEFT", title, "BOTTOMRIGHT", 10, 2);
version:SetText(C_AddOns.GetAddOnMetadata(PARENT_MOD_NAME, "Version") .. "  ·  WoW " .. (GetBuildInfo()));

-- tabs on a bordered pane, like Wayfinder's (BlizzMove's Ace3 tab groups)
local pane = CreateFrame("Frame", nil, f, "BackdropTemplate");
pane:SetPoint("TOPLEFT", f, "TOPLEFT", LEFT_MARGIN - 6, -76);
pane:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 10);
pane:SetBackdrop({
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 3, right = 3, top = 5, bottom = 3 },
});
pane:SetBackdropColor(0.1, 0.1, 0.1, 0.5);
pane:SetBackdropBorderColor(0.4, 0.4, 0.4);

local ACTIVE_TAB_TEXTURE = "Interface\\OptionsFrame\\UI-OptionsFrame-ActiveTab";
local INACTIVE_TAB_TEXTURE = "Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab";

-- the three pieces (left cap, stretching middle, right cap) of one tab look
local function CreateTabPieces(tab, file, offsetY)
	local left = tab:CreateTexture(nil, "BORDER");
	left:SetTexture(file);
	left:SetTexCoord(0, 0.15625, 0, 1);
	left:SetSize(20, 24);
	left:SetPoint("BOTTOMLEFT", 0, offsetY);

	local right = tab:CreateTexture(nil, "BORDER");
	right:SetTexture(file);
	right:SetTexCoord(0.84375, 1, 0, 1);
	right:SetSize(20, 24);
	right:SetPoint("BOTTOMRIGHT", 0, offsetY);

	local middle = tab:CreateTexture(nil, "BORDER");
	middle:SetTexture(file);
	middle:SetTexCoord(0.15625, 0.84375, 0, 1);
	middle:SetPoint("TOPLEFT", left, "TOPRIGHT");
	middle:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT");

	return { left, middle, right };
end

local function CreateTab(text)
	local tab = CreateFrame("Button", nil, f);
	tab:SetHeight(24);
	tab.activePieces = CreateTabPieces(tab, ACTIVE_TAB_TEXTURE, -3);
	tab.inactivePieces = CreateTabPieces(tab, INACTIVE_TAB_TEXTURE, 0);

	local label = tab:CreateFontString(nil, "OVERLAY");
	tab:SetFontString(label);
	tab:SetNormalFontObject(GameFontNormalSmall);
	tab:SetHighlightFontObject(GameFontHighlightSmall);
	tab:SetDisabledFontObject(GameFontHighlightSmall);
	tab:SetText(text);
	tab:SetWidth(math.max(80, label:GetStringWidth() + 40));

	tab:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight", "ADD");
	local highlight = tab:GetHighlightTexture();
	highlight:ClearAllPoints();
	highlight:SetPoint("LEFT", tab, "LEFT", 10, -4);
	highlight:SetPoint("RIGHT", tab, "RIGHT", -10, -4);

	-- show the tab as selected (raised, not clickable) or not
	function tab:SetSelected(selected)
		for _, piece in ipairs(self.activePieces) do piece:SetShown(selected); end
		for _, piece in ipairs(self.inactivePieces) do piece:SetShown(not selected); end
		self:SetEnabled(not selected);
		label:ClearAllPoints();
		label:SetPoint("CENTER", 0, selected and -2 or -3);
	end

	return tab;
end

local tabs, tabContents = {}, {};
local selectedTab = 1;

local function SelectTab(index)
	selectedTab = index;
	for i, tab in ipairs(tabs) do
		tab:SetSelected(i == index);
		tabContents[i]:SetShown(i == index);
	end
end

-- Layout state while building a tab: the content frame and the offset of its next row from the top.
local page, nextY, rowY;

-- Anchor a region at the next free row and move the cursor below it.
local function PlaceNext(region, x, height, gap)
	nextY = nextY - gap;
	rowY = nextY;
	region:SetPoint("TOPLEFT", page, "TOPLEFT", LEFT_MARGIN + x, nextY);
	nextY = nextY - height;
end

-- Anchor a region on the row placed last, at the given x.
local function PlaceBeside(region, x)
	region:SetPoint("TOPLEFT", page, "TOPLEFT", LEFT_MARGIN + x, rowY);
end

local function AddHeader(option)
	local header = page:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
	header:SetText(option.label);
	PlaceNext(header, 0, 18, nextY == 0 and 12 or 22);
	tinsert(refreshers, function()
		header:SetFontObject(IsEnabled(option) and "GameFontNormalLarge" or "GameFontDisableLarge");
	end);
end

local function AddText(option)
	if (not option.label) or (option.label == "") then
		return;
	end
	local text = page:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	text:SetText(option.label);
	PlaceNext(text, 4, 14, 10 + (option.y or 0));
end

local function AddCheckbox(option, label)
	local checkbox = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate");
	checkbox:SetSize(26, 26);
	if (option.x) then
		PlaceBeside(checkbox, COLUMN2_X);
	else
		PlaceNext(checkbox, 0, 26, 2 + (option.y or 0));
	end

	local text = checkbox.text or checkbox.Text;
	text:SetFontObject("GameFontHighlight");
	text:SetText(label or option.label);
	SetTooltip(checkbox, label or option.label, option.tip);

	checkbox:SetScript("OnClick", function(self)
		SetConfigValue(option.var, self:GetChecked() and true or false);
	end);

	tinsert(refreshers, function()
		checkbox:SetChecked(cfg[option.var] and true or false);
		local enabled = IsEnabled(option);
		checkbox:SetEnabled(enabled);
		text:SetFontObject(enabled and "GameFontHighlight" or "GameFontDisable");
	end);
end

local function AddDropdown(option)
	local label = page:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	label:SetWidth(LABEL_COL_W);
	label:SetJustifyH("LEFT");
	label:SetText(option.label);
	PlaceNext(label, 4, 16, 14 + (option.y or 0));

	local dropdown = CreateFrame("DropdownButton", nil, page, "WowStyle1DropdownTemplate");
	dropdown:SetWidth(180);
	dropdown:SetPoint("LEFT", label, "RIGHT", 8, 0);
	dropdown:SetupMenu(function(_, root)
		for _, entry in ipairs(option.list) do
			local text, value = entry[1], entry[2];
			root:CreateRadio(text, function() return cfg[option.var] == value; end, function() SetConfigValue(option.var, value); end);
		end
	end);
	SetTooltip(dropdown, option.label, option.tip);

	tinsert(refreshers, function()
		dropdown:GenerateMenu();
		local enabled = IsEnabled(option);
		dropdown:SetEnabled(enabled);
		label:SetFontObject(enabled and "GameFontHighlight" or "GameFontDisable");
	end);
end

local function FormatSliderValue(option, value)
	if (option.step >= 1) then
		return ("%d"):format(value);
	end
	return ("%.2f"):format(value);
end

local function AddSlider(option)
	local label = page:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	label:SetWidth(LABEL_COL_W);
	label:SetJustifyH("LEFT");
	label:SetText(option.label);
	PlaceNext(label, 4, 20, 10 + (option.y or 0));

	local slider = CreateFrame("Frame", nil, page, "MinimalSliderWithSteppersTemplate");
	slider:SetSize(180, 20);
	slider:SetPoint("LEFT", label, "RIGHT", 8, 0);

	local valueText = page:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	valueText:SetPoint("LEFT", slider, "RIGHT", 8, 0);
	valueText:SetWidth(50);
	valueText:SetJustifyH("LEFT");
	SetTooltip(slider, option.label, option.tip);

	-- the template's value-changed callback also fires when the value is set from code; `syncing` marks those
	local syncing = false;
	slider:Init(cfg[option.var] or option.min, option.min, option.max, math.floor((option.max - option.min) / option.step + 0.5), {});
	slider:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, function(_, value)
		value = math.floor(value / option.step + 0.5) * option.step;
		valueText:SetText(FormatSliderValue(option, value));
		if (not syncing) then
			SetConfigValue(option.var, value);
		end
	end, slider);

	tinsert(refreshers, function()
		local value = cfg[option.var] or option.min;
		syncing = true;
		slider:SetValue(value);
		syncing = false;
		valueText:SetText(FormatSliderValue(option, value));
		local enabled = IsEnabled(option);
		slider:SetEnabled(enabled);
		label:SetFontObject(enabled and "GameFontHighlight" or "GameFontDisable");
		valueText:SetFontObject(enabled and "GameFontHighlight" or "GameFontDisable");
	end);
end

local BUILDERS = {
	Header = AddHeader,
	TextOnly = AddText,
	Check = AddCheckbox,
	DropDown = AddDropdown,
	Slider = AddSlider,
};

-- Reset one category's options to their defaults (cleared values read the default from the metatable)
local function ResetCategory(category)
	for _, option in ipairs(category.options or {}) do
		if (option.var) then
			cfg[option.var] = nil;
		end
	end
	if (category.enabled) and (category.enabled.var) then
		cfg[category.enabled.var] = nil;
	end
	configDb:RegisterDefaults(configDb.defaults);
	TipTac:ApplyConfig();
	RefreshAll();
end

-- build the tabs
for index, category in ipairs(options) do
	local tab = CreateTab(category.category);
	if (index == 1) then
		tab:SetPoint("BOTTOMLEFT", pane, "TOPLEFT", 6, -4);
	else
		tab:SetPoint("LEFT", tabs[index - 1], "RIGHT", -10, 0);
	end
	tab:SetScript("OnClick", function() SelectTab(index); end);
	tabs[index] = tab;

	-- scrollable content inside the pane
	local scroll = CreateFrame("ScrollFrame", nil, pane, "ScrollFrameTemplate");
	scroll:SetPoint("TOPLEFT", 4, -6);
	scroll:SetPoint("BOTTOMRIGHT", -26, 6);
	scroll:Hide();
	local content = CreateFrame("Frame", nil, scroll);
	content:SetSize(1, 1);
	scroll:SetScrollChild(content);
	scroll:SetScript("OnSizeChanged", function(_, width) content:SetWidth(width); end);
	tabContents[index] = scroll;

	page, nextY, rowY = content, 0, 0;

	-- category-wide switch (e.g. Anchors)
	if (category.enabled) then
		AddCheckbox(category.enabled, category.enabled.label or ("Enable " .. category.category));
	end

	for _, option in ipairs(category.options or {}) do
		local build = BUILDERS[option.type];
		if (build) then
			build(option);
		end
	end

	-- defaults for this tab
	local reset = CreateFrame("Button", nil, content, "UIPanelButtonTemplate");
	reset:SetSize(140, 22);
	reset:SetText("Reset " .. category.category);
	PlaceNext(reset, 4, 22, 24);
	reset:SetScript("OnClick", function() ResetCategory(category); end);
	SetTooltip(reset, "Reset " .. category.category, "Reset the options on this tab to their defaults.");

	content:SetHeight(-nextY + 16);
end

-- page buttons, top right
local anchorButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate");
anchorButton:SetSize(120, 22);
anchorButton:SetPoint("TOPRIGHT", f, "TOPRIGHT", -14, -20);
anchorButton:SetText("Toggle Anchor");
anchorButton:SetScript("OnClick", function() TipTac:SetShown(not TipTac:IsShown()); end);
SetTooltip(anchorButton, "Toggle Anchor", "Show or hide " .. PARENT_MOD_NAME .. "'s anchor, to set the position of tooltips using the Normal Anchor.");

f:SetScript("OnShow", function()
	SelectTab(selectedTab);
	RefreshAll();
end);

-- register in Options > AddOns
local category = Settings.RegisterCanvasLayoutCategory(f, PARENT_MOD_NAME);
Settings.RegisterAddOnCategory(category);

-- open the options page (used by /tip, the addon compartment and TipTac:ToggleOptions)
function f:Open()
	Settings.OpenToCategory(category:GetID());
end
