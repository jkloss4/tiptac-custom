-- create addon
local MOD_NAME = ...;
local PARENT_MOD_NAME = "TipTac";
local f = CreateFrame("Frame",MOD_NAME,UIParent,BackdropTemplateMixin and "BackdropTemplate");	-- 9.0.1: Using BackdropTemplate

-- get libs
local LibFroznFunctions = LibStub:GetLibrary("LibFroznFunctions-1.0");

-- set config
local configDb, cfg = LibFroznFunctions:CreateDbWithLibAceDB("TipTac_Config");

-- constants
local TT_OPTIONS_CATEGORY_LIST_WIDTH = 117;

-- DropDown Lists
local DROPDOWN_ANCHORTYPE = {
	["Normal Anchor"] = "normal",
	["Mouse Anchor"] = "mouse",
	["Parent Anchor"] = "parent",
};

local DROPDOWN_ANCHORPOS = {
	["Top"] = "TOP",
	["Top Left"] = "TOPLEFT",
	["Top Right"] = "TOPRIGHT",
	["Bottom"] = "BOTTOM",
	["Bottom Left"] = "BOTTOMLEFT",
	["Bottom Right"] = "BOTTOMRIGHT",
	["Left"] = "LEFT",
	["Right"] = "RIGHT",
	["Center"] = "CENTER",
};

-- Options -- The "y" value of a category subtable, will further increase the vertical offset position of the item
--
-- hint for layouting options:
-- to set pixel perfect scale for options to adjust option elements:
-- /run local psw, psh = GetPhysicalScreenSize(); local uf = 768 / psh; local uis = UIParent:GetEffectiveScale(); local ttos = uf / uis; _G["TipTacOptions"]:SetScale(ttos);
local activePage = 1;
local options = {};
local option;

-- Anchors
-- mouse offset slider for the given anchor frame ("WorldUnit", "WorldTip", "FrameUnit", "FrameTip") and axis ("X", "Y")
local function GetMouseOffsetOption(anchorFrameName, axis)
	return { type = "Slider", var = "mouseOffset" .. anchorFrameName .. axis, label = "Mouse " .. axis .. " Offset", tip = "Offset from the mouse cursor when the anchor type is \"mouse\"", min = -200, max = 200, step = 1, fontSizeDelta = -2, enabled = function(factory) return factory:GetConfigValue("enableAnchor") end };
end

local ttOptionsAnchors = {
	{ type = "DropDown", var = "anchorWorldUnitType", label = "World Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") end },
	{ type = "DropDown", var = "anchorWorldUnitPoint", label = "World Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") end },
	GetMouseOffsetOption("WorldUnit", "X"),
	GetMouseOffsetOption("WorldUnit", "Y"),

	{ type = "DropDown", var = "anchorWorldTipType", label = "World Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 },
	{ type = "DropDown", var = "anchorWorldTipPoint", label = "World Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") end },
	GetMouseOffsetOption("WorldTip", "X"),
	GetMouseOffsetOption("WorldTip", "Y"),

	{ type = "DropDown", var = "anchorFrameUnitType", label = "Frame Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 },
	{ type = "DropDown", var = "anchorFrameUnitPoint", label = "Frame Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") end },
	GetMouseOffsetOption("FrameUnit", "X"),
	GetMouseOffsetOption("FrameUnit", "Y"),

	{ type = "DropDown", var = "anchorFrameTipType", label = "Frame Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 },
	{ type = "DropDown", var = "anchorFrameTipPoint", label = "Frame Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") end },
	GetMouseOffsetOption("FrameTip", "X"),
	GetMouseOffsetOption("FrameTip", "Y")
};

local priority = 0;

if (LibFroznFunctions.hasWoWFlavor.challengeMode) then
	priority = priority + 1;
	tinsert(ttOptionsAnchors, { type = "Header", label = "Prio #" .. priority .. ": Anchor Overrides During Challenge Mode", tip = "Special anchor overrides during challenge mode (Mythic+) in and out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end });
	
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
tinsert(ttOptionsAnchors, { type = "Header", label = "Prio #" .. priority .. ": Anchor Overrides During An Instance", tip = "Special anchor overrides during an instance (Dungeon, Raid, PvP, Arena, Scenario) in and out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end });

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
	tinsert(ttOptionsAnchors, { type = "Header", label = "Prio #" .. priority .. ": Anchor Overrides During Skyriding", tip = "Special anchor overrides during skyriding", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end });
	
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
tinsert(ttOptionsAnchors, { type = "Header", label = "Prio #" .. priority .. ": Anchor Overrides For In Combat", tip = "Special anchor overrides for in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end });

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
	tinsert(ttOptionsHiding, { type = "Header", var = "hideTipsDuringChallengeModeHeader", label = "Prio #" .. priority .. ": Hide Tips During Challenge Mode" });
	
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
tinsert(ttOptionsHiding, { type = "Header", var = "hideTipsDuringInstanceHeader", label = "Prio #" .. priority .. ": Hide Tips During An Instance" });

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
	tinsert(ttOptionsHiding, { type = "Header", var = "hideTipsDuringSkyridingHeader", label = "Prio #" .. priority .. ": Hide Tips During Skyriding" });
	
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
tinsert(ttOptionsHiding, { type = "Header", var = "hideTipsInCombatHeader", label = "Prio #" .. priority .. ": Hide Tips In Combat" });

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatWorldUnits", label = "Hide World Units", tip = "When you have this option checked, World Units will be hidden in combat.", belongsTo = "hideTipsInCombatHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatFrameUnits", label = "Hide Frame Units", tip = "When you have this option checked, Frame Units will be hidden in combat.", x = 160, belongsTo = "hideTipsInCombatWorldUnits" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatWorldTips", label = "Hide World Tips", tip = "When you have this option checked, World Tips will be hidden in combat.", belongsTo = "hideTipsInCombatHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatFrameTips", label = "Hide Frame Tips", tip = "When you have this option checked, Frame Tips will be hidden in combat.", x = 160, belongsTo = "hideTipsInCombatWorldTips" });

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatUnitTips", label = "Hide Unit Tips", tip = "When you have this option checked, Unit Tips will be hidden in combat.", y = 10, belongsTo = "hideTipsInCombatHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatSpellTips", label = "Hide Spell Tips", tip = "When you have this option checked, Spell Tips will be hidden in combat.", x = 160, belongsTo = "hideTipsInCombatUnitTips" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatItemTips", label = "Hide Item Tips", tip = "When you have this option checked, Item Tips will be hidden in combat.", belongsTo = "hideTipsInCombatHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatActionTips", label = "Hide Action Bar Tips", tip = "When you have this option checked, Action Bar Tips will be hidden in combat.", belongsTo = "hideTipsInCombatHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatExpBarTips", label = "Hide Exp Bar Tips", tip = "When you have this option checked, Experience Bar Tips will be hidden in combat.", x = 160, belongsTo = "hideTipsInCombatActionTips" });

tinsert(ttOptionsHiding, { type = "Header", var = "hideTipsHeader", label = "Prio #" .. priority .. ": Hide Tips Out Of Combat" });

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
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsEJDungeonRaidSetItemsSTT", label = "Hide Shopping Tips of Dungeon/Raid/Set Items\nin Adventure Guide", tip = "When you have this option checked, Shopping Tips of Dungeon/Raid/Set Items in Adventure Guide will be hidden." });
end

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsForOwnPets", label = "Hide Tips for My Own Pets/Minions", tip = "When you have this option checked, unit tooltips will be hidden for your own combat pets/minions (e.g. hunter pets including a 2nd Beast Mastery pet, warlock demons, death knight ghouls, mage water elementals). Pets/minions owned by other players are not affected." });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsForOwnCompanions", label = "Hide Tips for My Own Companion Pets", tip = "When you have this option checked, unit tooltips will be hidden for your own summoned non-combat companion (vanity) pets. Companion pets owned by other players are not affected." });

tinsert(ttOptionsHiding, { type = "Header", label = "Others" });

tinsert(ttOptionsHiding, { type = "DropDown", var = "showHiddenModifierKey", label = "Still Show Hidden Tips\nwhen Holding\nModifier Key", list = { ["Shift"] = "shift", ["Ctrl"] = "ctrl", ["Alt"] = "alt", ["|cffffa0a0None"] = "none" } });
tinsert(ttOptionsHiding, { type = "TextOnly", label = "", y = -12 }); -- spacer for multi-line label above

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
--                                          Initialize Frame                                          --
--------------------------------------------------------------------------------------------------------

tinsert(UISpecialFrames, f:GetName()); -- hopefully no taint

f.options = options;

f:SetSize(360 + TT_OPTIONS_CATEGORY_LIST_WIDTH,398);
f:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 } });
f:SetBackdropColor(0.1,0.22,0.35,1);
f:SetBackdropBorderColor(0.1,0.1,0.1,1);
f:EnableMouse(true);
f:SetMovable(true);
f:SetFrameStrata("DIALOG");
f:SetToplevel(true);
f:SetClampedToScreen(true);
f:SetScript("OnShow", function(self)
	f.searchBox:SetText("");
	f.searchBox:ClearFocus();
	
	self:BuildCategoryList();
	self:BuildCategoryPage();
end);
f:Hide();

f.outline = CreateFrame("Frame",nil,f,BackdropTemplateMixin and "BackdropTemplate");	-- 9.0.1: Using BackdropTemplate
f.outline:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = 1, tileSize = 16, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } });
f.outline:SetBackdropColor(0.1,0.1,0.2,1);
f.outline:SetBackdropBorderColor(0.8,0.8,0.9,0.4);
f.outline:SetPoint("TOPLEFT",12,-12);
f.outline:SetPoint("BOTTOMLEFT",12,12);
f.outline:SetWidth(TT_OPTIONS_CATEGORY_LIST_WIDTH);

f:SetScript("OnMouseDown",f.StartMoving);
f:SetScript("OnMouseUp",function(self) self:StopMovingOrSizing(); cfg.optionsLeft = self:GetLeft(); cfg.optionsBottom = self:GetBottom(); end);

if (cfg.optionsLeft) and (cfg.optionsBottom) then
	f:SetPoint("BOTTOMLEFT",UIParent,"BOTTOMLEFT",cfg.optionsLeft,cfg.optionsBottom);
else
	f:SetPoint("CENTER");
end

f.header = f:CreateFontString(nil,"ARTWORK","GameFontHighlight");
f.header:SetFont(GameFontNormal:GetFont(),22,"THICKOUTLINE");
f.header:SetPoint("TOPLEFT",f.outline,"TOPRIGHT",9,-4);
f.header:SetText(CreateTextureMarkup("Interface\\AddOns\\" .. PARENT_MOD_NAME .. "\\media\\tiptac_logo", 256, 256, nil, nil, 0, 1, 0, 1) .. " " .. PARENT_MOD_NAME.." Options");

f.vers = f:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
f.vers:SetPoint("TOPRIGHT",-15,-15);
local versionTipTac = C_AddOns.GetAddOnMetadata(PARENT_MOD_NAME, "Version");
local versionWoW, build = GetBuildInfo();
f.vers:SetText(PARENT_MOD_NAME .. ": " .. versionTipTac .. "\nWoW: " .. versionWoW);
f.vers:SetTextColor(1,1,0.5);

local function SearchBox_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:AddLine("Search all Categories", 1, 1, 1);
	GameTooltip:AddLine("Label and tooltip of options will be searched", nil, nil, nil, 1);
	GameTooltip:Show();
end

local function SearchBox_OnLeave(self)
	GameTooltip:Hide();
end

local function SearchBox_OnTextChanged(self)
	f:BuildCategoryPage();
end

f.searchBox = CreateFrame("EditBox", nil, f, "SearchBoxTemplate");
f.searchBox:SetSize(160, 20);
f.searchBox:SetPoint("TOPRIGHT", f, "TOPRIGHT", -12, -42);
f.searchBox:SetAutoFocus(false);
f.searchBox.Instructions:SetText("Search all Categories");
f.searchBox:SetScript("OnEnter", SearchBox_OnEnter);
f.searchBox:SetScript("OnLeave", SearchBox_OnLeave);
f.searchBox:HookScript("OnTextChanged", function(self, userInput)
	if (userInput) then
		SearchBox_OnTextChanged(self);
	end
end);
f.searchBox.clearButton:HookScript("OnClick", function(self)
	SearchBox_OnTextChanged(self:GetParent());
end);
f.searchBox:HookScript("OnEscapePressed", function(self)
	self:SetText("");
	self:ClearFocus();
	
	f:BuildCategoryPage();
end);

local function Anchor_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:AddLine("Anchor", 1, 1, 1);
	GameTooltip:AddLine("Click to toggle visibility of " .. PARENT_MOD_NAME .. "'s anchor to set the position for default anchored tooltips.", nil, nil, nil, 1);
	GameTooltip:Show();
end

local function Anchor_OnLeave(self)
	GameTooltip:Hide();
end

f.btnAnchor = CreateFrame("Button",nil,f,"UIPanelButtonTemplate");
f.btnAnchor:SetSize(75,24);
f.btnAnchor:SetPoint("BOTTOMLEFT",f.outline,"BOTTOMRIGHT",9,1);
local TipTac = _G[PARENT_MOD_NAME];
f.btnAnchor:SetScript("OnClick",function() TipTac:SetShown(not TipTac:IsShown()) end);
f.btnAnchor:SetScript("OnEnter", Anchor_OnEnter);
f.btnAnchor:SetScript("OnLeave", Anchor_OnLeave);
f.btnAnchor:SetText("Anchor");

local function Reset_OnClick(self)
	for index, option in ipairs(f.options[activePage].options or {}) do
		if (option.var) then
			cfg[option.var] = nil;	-- when cleared, they will read the default value from the metatable
		end
	end
	configDb:RegisterDefaults(configDb.defaults);
	TipTac:ApplyConfig();
	
	f:BuildCategoryList();
	f:BuildCategoryPage();
end

local function Reset_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:AddLine("Defaults", 1, 1, 1);
	GameTooltip:AddLine("Reset options of current page to default settings.", nil, nil, nil, 1);
	GameTooltip:Show();
end

local function Reset_OnLeave(self)
	GameTooltip:Hide();
end

f.btnReset = CreateFrame("Button",nil,f,"UIPanelButtonTemplate");
f.btnReset:SetSize(75,24);
f.btnReset:SetPoint("LEFT",f.btnAnchor,"RIGHT",9,0);
f.btnReset:SetScript("OnClick",Reset_OnClick);
f.btnReset:SetScript("OnEnter", Reset_OnEnter);
f.btnReset:SetScript("OnLeave", Reset_OnLeave);
f.btnReset:SetText("Defaults");

f.btnClose = CreateFrame("Button",nil,f,"UIPanelButtonTemplate");
f.btnClose:SetSize(75,24);
f.btnClose:SetPoint("LEFT",f.btnReset,"RIGHT",9,0);
f.btnClose:SetScript("OnClick",function() f:Hide(); end);
f.btnClose:SetText("Close");

local function SetScroll(value)
	local status = f.scrollFrame.status or f.scrollFrame.localstatus;
	local viewheight = f.scrollFrame:GetHeight();
	local height = f.content:GetHeight();
	local offset;

	if viewheight > height then
		offset = 0;
	else
		offset = floor((height - viewheight) / 1000.0 * value);
	end
	f.content:ClearAllPoints();
	f.content:SetPoint("TOPLEFT", 0, offset);
	f.content:SetPoint("TOPRIGHT", 0, offset);
	status.offset = offset;
	status.scrollvalue = value;
end

local function MoveScroll(self, value)
	local status = f.scrollFrame.status or f.scrollFrame.localstatus;
	local height, viewheight = f.scrollFrame:GetHeight(), f.content:GetHeight();

	if self.scrollBarShown then
		local diff = height - viewheight;
		local delta = 1;
		if value < 0 then
			delta = -1;
		end
		f.scrollBar:SetValue(min(max(status.scrollvalue + delta*(1000/(diff/45)),0), 1000));
	end
end

local function FixScroll(self)
	if self.updateLock then return end
	self.updateLock = true;
	local status = f.scrollFrame.status or f.scrollFrame.localstatus;
	local height, viewheight = f.scrollFrame:GetHeight(), f.content:GetHeight();
	local offset = status.offset or 0;
	-- Give us a margin of error of 2 pixels to stop some conditions that i would blame on floating point inaccuracys
	-- No-one is going to miss 2 pixels at the bottom of the frame, anyhow!
	if viewheight < height + 2 then
		if self.scrollBarShown then
			self.scrollBarShown = nil;
			f.scrollBar:Hide();
			f.scrollBar:SetValue(0);
			local scrollFrameBottomRightPoint, scrollFrameBottomRightRelativeTo, scrollFrameBottomRightRelativePoint, scrollFrameBottomRightXOfs, scrollFrameBottomRightYOfs = f.scrollFrame:GetPoint(3);
			scrollFrameBottomRightXOfs = -13;
			f.scrollFrame:SetPoint(scrollFrameBottomRightPoint, scrollFrameBottomRightRelativeTo, scrollFrameBottomRightRelativePoint, scrollFrameBottomRightXOfs, scrollFrameBottomRightYOfs);
			if f.content.original_width then
				f.content:SetWidth(f.content.original_width);
			end
		end
	else
		if not self.scrollBarShown then
			self.scrollBarShown = true;
			f.scrollBar:Show();
			local scrollFrameBottomRightPoint, scrollFrameBottomRightRelativeTo, scrollFrameBottomRightRelativePoint, scrollFrameBottomRightXOfs, scrollFrameBottomRightYOfs = f.scrollFrame:GetPoint(3);
			scrollFrameBottomRightXOfs = -33;
			f.scrollFrame:SetPoint(scrollFrameBottomRightPoint, scrollFrameBottomRightRelativeTo, scrollFrameBottomRightRelativePoint, scrollFrameBottomRightXOfs, scrollFrameBottomRightYOfs);
			if f.content.original_width then
				f.content:SetWidth(f.content.original_width - 20);
			end
		end
		local value = (offset / (viewheight - height) * 1000);
		if value > 1000 then value = 1000 end
		f.scrollBar:SetValue(value);
		SetScroll(value);
		if value < 1000 then
			f.content:ClearAllPoints();
			f.content:SetPoint("TOPLEFT", 0, offset);
			f.content:SetPoint("TOPRIGHT", 0, offset);
			status.offset = offset;
		end
	end
	self.updateLock = nil;
end

local function FixScrollOnUpdate(frame)
	frame:SetScript("OnUpdate", nil);
	FixScroll(frame);
end

local function ScrollFrame_OnMouseWheel(frame, value)
	MoveScroll(frame, value);
end

local function ScrollFrame_OnSizeChanged(frame)
	frame:SetScript("OnUpdate", FixScrollOnUpdate);
end

f.scrollFrame = CreateFrame("ScrollFrame", nil, f);
f.scrollFrame.status = {};
f.scrollFrame:SetPoint("TOP", f.searchBox, "BOTTOM", 0, -8);
f.scrollFrame:SetPoint("LEFT", f.outline, "RIGHT", 0, 9);
f.scrollFrame:SetPoint("BOTTOM", f.btnClose, "TOP", 0, 9);
f.scrollFrame:SetPoint("RIGHT", f, "RIGHT", -13, 0);
f.scrollFrame:EnableMouseWheel(true);
f.scrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel);
f.scrollFrame:SetScript("OnSizeChanged", ScrollFrame_OnSizeChanged);

local function ScrollBar_OnScrollValueChanged(frame, value)
	SetScroll(value);
end

f.scrollBar = CreateFrame("Slider", nil, f.scrollFrame, "UIPanelScrollBarTemplate");
f.scrollBar:SetPoint("TOPLEFT", f.scrollFrame, "TOPRIGHT", 4, -16);
f.scrollBar:SetPoint("BOTTOMLEFT", f.scrollFrame, "BOTTOMRIGHT", 4, 16);
f.scrollBar:SetMinMaxValues(0, 1000);
f.scrollBar:SetValueStep(1);
f.scrollBar:SetValue(0);
f.scrollBar:SetWidth(16);
f.scrollBar:Hide();
-- set the script as the last step, so it doesn't fire yet
f.scrollBar:SetScript("OnValueChanged", ScrollBar_OnScrollValueChanged);

f.scrollBg = f.scrollBar:CreateTexture(nil, "BACKGROUND");
f.scrollBg:SetAllPoints(f.scrollBar);
f.scrollBg:SetColorTexture(0, 0, 0, 0.4);

--Container Support
f.content = CreateFrame("Frame", nil, f.scrollFrame)
f.content:SetHeight(400);
f.content:SetScript("OnSizeChanged", function(self, ...)
	ScrollFrame_OnSizeChanged(f.scrollFrame, ...);
end);
f.scrollFrame:SetScrollChild(f.content);
f.content:SetPoint("TOPLEFT");
f.content:SetPoint("TOPRIGHT");

--------------------------------------------------------------------------------------------------------
--                                        Build Option Category                                       --
--------------------------------------------------------------------------------------------------------

-- Get Setting
local function GetConfigValue(self,var)
	return cfg[var];
end

-- called when a setting is changed, do not allow
local function SetConfigValue(self,var,value,noBuildCategoryPage)
	if (not self.isBuildingOptions) then
		cfg[var] = value;
		local TipTac = _G[PARENT_MOD_NAME];
		TipTac:ApplyConfig();
		if (not noBuildCategoryPage) then
			f:BuildCategoryPage(true);
			f:BuildCategoryList();
		end
	end
end

-- determine options to display (search box or current category)
local function addOptionToCategoryOptionMatchesFn(category, categoryOptionMatches, option)
	-- check if option has already been added
	for _, categoryOptionMatch in ipairs(categoryOptionMatches) do
		if (categoryOptionMatch == option) then
			return;
		end
	end
	
	-- add belongsTo option before if available
	local belongsTo = option.belongsTo;
	
	if (belongsTo) then
		for _, _option in ipairs(category.options or {}) do
			if (_option.var == belongsTo) then
				addOptionToCategoryOptionMatchesFn(category, categoryOptionMatches, _option);
				break;
			end
		end
	end
	
	-- add option
	tinsert(categoryOptionMatches, option);
end

local function GetOptionsToShow()
	local optionsToShow;
	
	local searchText = f.searchBox:GetText();
	local searchWords = {};
	for word in strlower(searchText):gmatch("%S+") do
		tinsert(searchWords, word);
	end
	
	local searchActive = (#searchWords > 0);
	
	if (searchActive) then
		optionsToShow = {};
		
		for _, category in ipairs(f.options) do
			local categoryOptionMatches = {};
			
			for _, option in ipairs(category.options or {}) do
				if (option.type) and (option.type ~= "Header") and (option.type ~= "TextOnly") then
					-- use label if present. otherwise call get() for dynamic label.
					local labelText = (option.label) or (option.get and LibFroznFunctions:RemoveColorsFromText(option.get(f.factory, option.var)));
					
					if (labelText) and (labelText ~= "") then
						local haystack = strlower(labelText .. " " .. (option.tip or ""));
						local matched = true;
						
						for _, word in ipairs(searchWords) do
							if (not haystack:find(word, 1, true)) then
								matched = false;
								break;
							end
						end
						
						if (matched) then
							addOptionToCategoryOptionMatchesFn(category, categoryOptionMatches, option);
						end
					end
				end
			end
			
			if (#categoryOptionMatches > 0) then
				tinsert(optionsToShow, { type = "Header", label = "Category: " .. category.category });
				
				for _, _option in ipairs(categoryOptionMatches) do
					tinsert(optionsToShow, _option);
				end
			end
		end
		
		if (#optionsToShow == 0) then
			optionsToShow = { { type = "TextOnly", label = "No options found." } };
		end
	else
		optionsToShow = f.options[activePage].options;
	end
	
	return optionsToShow, searchActive;
end

-- create new factory instance
local factory = AzOptionsFactory:New(f.content,GetConfigValue,SetConfigValue);
f.factory = factory; 

-- Build Page
function f:BuildCategoryPage(noUpdateScrollFrame)
	-- update scroll frame
	if (not noUpdateScrollFrame) then
		f.scrollBar:SetValue(0);
	end

	-- determine options to display (search box or current category)
	local optionsToShow, searchActive = GetOptionsToShow();
	
	-- build page
	factory:BuildOptionsPage(optionsToShow, f.content, 0, 0);
	
	-- set new content height
	local contentChildren = { f.content:GetChildren() };
	local newContentHeight = nil;
	local contentChildMostBottom = nil;
	
	for index, contentChild in ipairs(contentChildren) do
		local contentChildTopLeftPoint, contentChildTopLeftRelativeTo, contentChildTopLeftRelativePoint, contentChildTopLeftXOfs, contentChildTopLeftYOfs = contentChild:GetPoint();
		if (contentChild:IsShown()) and ((not newContentHeight) or (-contentChildTopLeftYOfs >= newContentHeight)) then
			newContentHeight = -contentChildTopLeftYOfs;
			contentChildMostBottom = contentChild;
		end
	end
	
	local finalContentHeight = (newContentHeight or 0) + (contentChildMostBottom and contentChildMostBottom:GetHeight() or 0);
	
	f.content:SetHeight(finalContentHeight > 0 and finalContentHeight or 1);
	
	-- disable btnReset if search active or page has it disabled
	f.btnReset:SetEnabled((not searchActive) and (not f.options[activePage].btnResetDisabled));
end

--------------------------------------------------------------------------------------------------------
--                                        Options Category List                                       --
--------------------------------------------------------------------------------------------------------

local listButtons = {};

local function CategoryButton_OnClick(self,button)
	f.searchBox:SetText("");
	f.searchBox:ClearFocus();
	if (not listButtons[activePage].check.option) or (GetConfigValue(f.factory, listButtons[activePage].check.option.var)) then
		listButtons[activePage].text:SetTextColor(1, 0.82, 0);
	else
		listButtons[activePage].text:SetTextColor(0.5, 0.5, 0.5);
	end
	listButtons[activePage]:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight");
	listButtons[activePage]:GetHighlightTexture():SetAlpha(0.3);
	listButtons[activePage]:UnlockHighlight();
	activePage = self.index;
	if (not self.check.option) or (GetConfigValue(f.factory, self.check.option.var)) then
		self.text:SetTextColor(1, 1, 1);
	else
		self.text:SetTextColor(0.5, 0.5, 0.5);
	end
	self:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
	self:GetHighlightTexture():SetAlpha(0.7);
	self:LockHighlight();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);	-- "igMainMenuOptionCheckBoxOn"
	f:BuildCategoryPage();
end

local function CheckButton_OnClick(self, button)
	local checked = (self:GetChecked() and true or false); -- WoD patch made GetChecked() return bool instead of 1/nil
	local b = self:GetParent();
	
	SetConfigValue(f.factory, self.option.var, checked);
	
	CategoryButton_OnClick(b, button);
	
	if (checked) then
		b.text:SetTextColor(1, 1, 1);
	else
		b.text:SetTextColor(0.5, 0.5, 0.5);
	end
end

local function CheckButton_OnEnter(self)
	if (self.option.tip) then
		GameTooltip:SetOwner(self,"ANCHOR_RIGHT");
		GameTooltip:AddLine(self.option.label,1,1,1);
		GameTooltip:AddLine(self.option.tip,nil,nil,nil,1);
		GameTooltip:Show();
	end
end

local function CheckButton_OnLeave(self)
	GameTooltip:Hide();
end

local buttonWidth = (f.outline:GetWidth() - 8);
local function CreateCategoryButtonEntry(parent)
	local b = CreateFrame("Button",nil,parent);
	b:SetSize(buttonWidth,18);
	b:SetScript("OnClick",CategoryButton_OnClick);
	b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight");
	b:GetHighlightTexture():SetAlpha(0.3);
	b.text = b:CreateFontString(nil,"ARTWORK","GameFontNormal");
	b.text:SetPoint("LEFT",3,0);
	b.check = CreateFrame("CheckButton", nil, b);
	b.check:SetPoint("TOPLEFT", buttonWidth - 22, 2);
	b.check:SetPoint("BOTTOMRIGHT", 0, -2);
	b.check:SetScript("OnClick", CheckButton_OnClick);
	b.check:SetScript("OnEnter", CheckButton_OnEnter);
	b.check:SetScript("OnLeave", CheckButton_OnLeave);
	b.check:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up");
	b.check:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down");
	b.check:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight");
	b.check:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled");
	b.check:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check");
	b.check:Hide();
	tinsert(listButtons, b);
	return b;
end

-- Build Category List
function f:BuildCategoryList()
	for index, table in ipairs(f.options) do
		local button = listButtons[index] or CreateCategoryButtonEntry(f.outline);
		button.text:SetText(table.category);
		button.text:SetTextColor(1,0.82,0);
		if (table.enabled) then
			local option = table.enabled;
			local cfgValue = GetConfigValue(f.factory, option.var);
			button.check.option = option;
			if (not option.label) then
				option.label = table.category;
			end
			button.check:SetChecked(cfgValue);
			local enabled = (not option.enabled) or (not not option.enabled(f.factory, button.check, option, cfgValue));
			button.check:SetEnabled(enabled);
			if (not cfgValue) or (not enabled) then
				button.text:SetTextColor(0.5, 0.5, 0.5);
			end
			button.check:Show();
		end
		button.index = index;
		if (index == 1) then
			button:SetPoint("TOPLEFT",f.outline,"TOPLEFT",5,-6);
		else
			button:SetPoint("TOPLEFT",listButtons[index - 1],"BOTTOMLEFT");
		end
		if (index == activePage) then
			if (not button.check.option) or (GetConfigValue(f.factory, button.check.option.var)) then
				button.text:SetTextColor(1, 1, 1);
			else
				button.text:SetTextColor(0.5, 0.5, 0.5);
			end
			button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
			button:GetHighlightTexture():SetAlpha(0.7);
			button:LockHighlight();
		end
	end
end
