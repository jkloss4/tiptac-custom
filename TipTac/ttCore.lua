-----------------------------------------------------------------------
-- TipTac - Core
--
-- TipTac is a tooltip enhancement addon, it allows you to configure various aspects of the tooltip, such as moving where it's shown, the font, the scale of tips, plus many more features.
--

-- create addon
local MOD_NAME = ...;
local tt = CreateFrame("Frame", MOD_NAME, UIParent, BackdropTemplateMixin and "BackdropTemplate");
tt:Hide();

-- get libs
local LibFroznFunctions = LibStub:GetLibrary("LibFroznFunctions-1.0");

----------------------------------------------------------------------------------------------------
--                                             Config                                             --
----------------------------------------------------------------------------------------------------

-- config
local configDb, cfg;

-- default config
local TT_DefaultConfig = {
	-- TipTac anchor
	left = nil,  -- set during custom event OnConfigLoaded
	top = nil,   -- set during custom event OnConfigLoaded
	
	-- TipTac options anchor
	optionsLeft = nil,    -- set during custom event OnConfigLoaded
	optionsBottom = nil,  -- set during custom event OnConfigLoaded
	
	-- version of TipTac_Config (used if e.g. options are renamed or reused differently)
	version_TipTac_Config = nil,  -- set during custom event OnConfigLoaded
	
	-- fading
	overrideFade = true,
	preFadeTime = 0.1,
	fadeTime = 0.1,
	hideWorldTips = true,
	
	-- anchors
	enableAnchor = true,
	
	anchorWorldUnitType = "normal",
	anchorWorldUnitPoint = "BOTTOMRIGHT",
	anchorWorldTipType = "normal",
	anchorWorldTipPoint = "BOTTOMRIGHT",
	anchorFrameUnitType = "normal",
	anchorFrameUnitPoint = "BOTTOMRIGHT",
	anchorFrameTipType = "normal",
	anchorFrameTipPoint = "BOTTOMRIGHT",
	
	enableAnchorOverrideWorldUnitDuringChallengeModeInCombat = false,
	anchorWorldUnitTypeDuringChallengeModeInCombat = "normal",
	anchorWorldUnitPointDuringChallengeModeInCombat = "BOTTOMRIGHT",
	enableAnchorOverrideWorldTipDuringChallengeModeInCombat = false,
	anchorWorldTipTypeDuringChallengeModeInCombat = "normal",
	anchorWorldTipPointDuringChallengeModeInCombat = "BOTTOMRIGHT",
	enableAnchorOverrideFrameUnitDuringChallengeModeInCombat = false,
	anchorFrameUnitTypeDuringChallengeModeInCombat = "normal",
	anchorFrameUnitPointDuringChallengeModeInCombat = "BOTTOMRIGHT",
	enableAnchorOverrideFrameTipDuringChallengeModeInCombat = false,
	anchorFrameTipTypeDuringChallengeModeInCombat = "normal",
	anchorFrameTipPointDuringChallengeModeInCombat = "BOTTOMRIGHT",
	
	enableAnchorOverrideWorldUnitDuringChallengeMode = false,
	anchorWorldUnitTypeDuringChallengeMode = "normal",
	anchorWorldUnitPointDuringChallengeMode = "BOTTOMRIGHT",
	enableAnchorOverrideWorldTipDuringChallengeMode = false,
	anchorWorldTipTypeDuringChallengeMode = "normal",
	anchorWorldTipPointDuringChallengeMode = "BOTTOMRIGHT",
	enableAnchorOverrideFrameUnitDuringChallengeMode = false,
	anchorFrameUnitTypeDuringChallengeMode = "normal",
	anchorFrameUnitPointDuringChallengeMode = "BOTTOMRIGHT",
	enableAnchorOverrideFrameTipDuringChallengeMode = false,
	anchorFrameTipTypeDuringChallengeMode = "normal",
	anchorFrameTipPointDuringChallengeMode = "BOTTOMRIGHT",
	
	enableAnchorOverrideWorldUnitDuringInstance = false,
	anchorWorldUnitTypeDuringInstance = "normal",
	anchorWorldUnitPointDuringInstance = "BOTTOMRIGHT",
	enableAnchorOverrideWorldTipDuringInstance = false,
	anchorWorldTipTypeDuringInstance = "normal",
	anchorWorldTipPointDuringInstance = "BOTTOMRIGHT",
	enableAnchorOverrideFrameUnitDuringInstance = false,
	anchorFrameUnitTypeDuringInstance = "normal",
	anchorFrameUnitPointDuringInstance = "BOTTOMRIGHT",
	enableAnchorOverrideFrameTipDuringInstance = false,
	anchorFrameTipTypeDuringInstance = "normal",
	anchorFrameTipPointDuringInstance = "BOTTOMRIGHT",
	
	enableAnchorOverrideWorldUnitDuringInstanceInCombat = false,
	anchorWorldUnitTypeDuringInstanceInCombat = "normal",
	anchorWorldUnitPointDuringInstanceInCombat = "BOTTOMRIGHT",
	enableAnchorOverrideWorldTipDuringInstanceInCombat = false,
	anchorWorldTipTypeDuringInstanceInCombat = "normal",
	anchorWorldTipPointDuringInstanceInCombat = "BOTTOMRIGHT",
	enableAnchorOverrideFrameUnitDuringInstanceInCombat = false,
	anchorFrameUnitTypeDuringInstanceInCombat = "normal",
	anchorFrameUnitPointDuringInstanceInCombat = "BOTTOMRIGHT",
	enableAnchorOverrideFrameTipDuringInstanceInCombat = false,
	anchorFrameTipTypeDuringInstanceInCombat = "normal",
	anchorFrameTipPointDuringInstanceInCombat = "BOTTOMRIGHT",
	
	enableAnchorOverrideWorldUnitDuringSkyriding = false,
	anchorWorldUnitTypeDuringSkyriding = "normal",
	anchorWorldUnitPointDuringSkyriding = "BOTTOMRIGHT",
	enableAnchorOverrideWorldTipDuringSkyriding = false,
	anchorWorldTipTypeDuringSkyriding = "normal",
	anchorWorldTipPointDuringSkyriding = "BOTTOMRIGHT",
	enableAnchorOverrideFrameUnitDuringSkyriding = false,
	anchorFrameUnitTypeDuringSkyriding = "normal",
	anchorFrameUnitPointDuringSkyriding = "BOTTOMRIGHT",
	enableAnchorOverrideFrameTipDuringSkyriding = false,
	anchorFrameTipTypeDuringSkyriding = "normal",
	anchorFrameTipPointDuringSkyriding = "BOTTOMRIGHT",
	
	enableAnchorOverrideWorldUnitInCombat = false,
	anchorWorldUnitTypeInCombat = "normal",
	anchorWorldUnitPointInCombat = "BOTTOMRIGHT",
	enableAnchorOverrideWorldTipInCombat = false,
	anchorWorldTipTypeInCombat = "normal",
	anchorWorldTipPointInCombat = "BOTTOMRIGHT",
	enableAnchorOverrideFrameUnitInCombat = false,
	anchorFrameUnitTypeInCombat = "normal",
	anchorFrameUnitPointInCombat = "BOTTOMRIGHT",
	enableAnchorOverrideFrameTipInCombat = false,
	anchorFrameTipTypeInCombat = "normal",
	anchorFrameTipPointInCombat = "BOTTOMRIGHT",
	
	enableAnchorOverrideCF = false,
	anchorOverrideCFType = "normal",
	anchorOverrideCFPoint = "BOTTOMRIGHT",
	
	mouseOffsetWorldUnitX = 0,
	mouseOffsetWorldUnitY = 0,
	mouseOffsetWorldTipX = 0,
	mouseOffsetWorldTipY = 0,
	mouseOffsetFrameUnitX = 0,
	mouseOffsetFrameUnitY = 0,
	mouseOffsetFrameTipX = 0,
	mouseOffsetFrameTipY = 0,

	-- hiding
	hideTipsDuringChallengeModeInCombatWorldUnits = false,
	hideTipsDuringChallengeModeInCombatWorldTips = false,
	hideTipsDuringChallengeModeInCombatFrameUnits = false,
	hideTipsDuringChallengeModeInCombatFrameTips = false,
	hideTipsDuringChallengeModeInCombatUnitTips = false,
	hideTipsDuringChallengeModeInCombatSpellTips = false,
	hideTipsDuringChallengeModeInCombatItemTips = false,
	hideTipsDuringChallengeModeInCombatActionTips = false,
	hideTipsDuringChallengeModeInCombatExpBarTips = false,
	
	hideTipsDuringChallengeModeWorldUnits = false,
	hideTipsDuringChallengeModeWorldTips = false,
	hideTipsDuringChallengeModeFrameUnits = false,
	hideTipsDuringChallengeModeFrameTips = false,
	hideTipsDuringChallengeModeUnitTips = false,
	hideTipsDuringChallengeModeSpellTips = false,
	hideTipsDuringChallengeModeItemTips = false,
	hideTipsDuringChallengeModeActionTips = false,
	hideTipsDuringChallengeModeExpBarTips = false,
	
	hideTipsDuringInstanceInCombatWorldUnits = false,
	hideTipsDuringInstanceInCombatWorldTips = false,
	hideTipsDuringInstanceInCombatFrameUnits = false,
	hideTipsDuringInstanceInCombatFrameTips = false,
	hideTipsDuringInstanceInCombatUnitTips = false,
	hideTipsDuringInstanceInCombatSpellTips = false,
	hideTipsDuringInstanceInCombatItemTips = false,
	hideTipsDuringInstanceInCombatActionTips = false,
	hideTipsDuringInstanceInCombatExpBarTips = false,
	
	hideTipsDuringInstanceWorldUnits = false,
	hideTipsDuringInstanceWorldTips = false,
	hideTipsDuringInstanceFrameUnits = false,
	hideTipsDuringInstanceFrameTips = false,
	hideTipsDuringInstanceUnitTips = false,
	hideTipsDuringInstanceSpellTips = false,
	hideTipsDuringInstanceItemTips = false,
	hideTipsDuringInstanceActionTips = false,
	hideTipsDuringInstanceExpBarTips = false,
	
	hideTipsDuringSkyridingWorldUnits = false,
	hideTipsDuringSkyridingWorldTips = false,
	hideTipsDuringSkyridingFrameUnits = false,
	hideTipsDuringSkyridingFrameTips = false,
	hideTipsDuringSkyridingUnitTips = false,
	hideTipsDuringSkyridingSpellTips = false,
	hideTipsDuringSkyridingItemTips = false,
	hideTipsDuringSkyridingActionTips = false,
	hideTipsDuringSkyridingExpBarTips = false,
	
	hideTipsInCombatWorldUnits = false,
	hideTipsInCombatWorldTips = false,
	hideTipsInCombatFrameUnits = false,
	hideTipsInCombatFrameTips = false,
	hideTipsInCombatUnitTips = false,
	hideTipsInCombatSpellTips = false,
	hideTipsInCombatItemTips = false,
	hideTipsInCombatActionTips = false,
	hideTipsInCombatExpBarTips = false,
	
	hideTipsWorldUnits = false,
	hideTipsWorldTips = false,
	hideTipsFrameUnits = false,
	hideTipsFrameTips = false,
	hideTipsUnitTips = false,
	hideTipsSpellTips = false,
	hideTipsItemTips = false,
	hideTipsActionTips = false,
	hideTipsExpBarTips = false,
	
	hideTipsEJDungeonRaidSetItemsSTT = false,

	hideTipsForOwnPets = false,
	hideTipsForOwnCompanions = false,

	showHiddenModifierKey = "shift",
	
};

-- extended config
local TT_ExtendedConfig = {};

-- tooltip default anchor type and anchor point
TT_ExtendedConfig.defaultAnchorType = "normal";
TT_ExtendedConfig.defaultAnchorPoint = "BOTTOMRIGHT";

-- tips to modify in appearance and hooking config. other mods can use TipTac:AddModifiedTip(tip, noHooks) or TipTac:AddModifiedTipExtended(tip, tipParams) to register their own tooltips.
--
-- 1st key = addon name
-- 3rd key = frame name
--
-- params for 1st key:
-- frames                 optional. frames to modify in appearance and hooking config
-- hookFnForAddOn         optional. individual function for hooking for addon, nil otherwise. parameters: TT_CacheForFrames
-- waitSecondsForHooking  optional. float with number of seconds to wait before hooking for addon, nil otherwise.
--
-- params for 3rd key:
-- applyAnchor                    true if anchoring should be applied, false/nil otherwise.
-- waitSecondsForLookupFrameName  optional. float with number of seconds to wait before looking up frame name, nil otherwise.
-- noHooks                        optional. true if no hooks should be applied to the frame directly, false/nil otherwise.
-- hookFnForFrame                 optional. individual function for hooking for frame, nil otherwise. parameters: TT_CacheForFrames, tip
-- waitSecondsForHooking          optional. float with number of seconds to wait before hooking for frame, nil otherwise.
-- isFromLibQTip                  optional. true if frame belongs to LibQTip-1.0, false/nil otherwise.
--
-- hint: determined frames will be added to TT_CacheForFrames with key as resolved real frame. The params will be added under ".config", the frame name under ".frameName".
TT_ExtendedConfig.tipsToModify = {
	[MOD_NAME] = {
		frames = {
			["GameTooltip"] = { applyAnchor = true },
			["ShoppingTooltip1"] = { applyAnchor = false },
			["ShoppingTooltip2"] = { applyAnchor = false },
			["ItemRefTooltip"] = { applyAnchor = false },
			["ItemRefShoppingTooltip1"] = { applyAnchor = false },
			["ItemRefShoppingTooltip2"] = { applyAnchor = false },
			["EmbeddedItemTooltip"] = { applyAnchor = true },
			["NamePlateTooltip"] = { applyAnchor = true },
			["BattlePetTooltip"] = { applyAnchor = true },
			["FloatingBattlePetTooltip"] = { applyAnchor = true },
			["FloatingPetBattleAbilityTooltip"] = { applyAnchor = true },
			["FriendsTooltip"] = { applyAnchor = true },
			["QueueStatusFrame"] = { applyAnchor = true },
			["QuestScrollFrame.StoryTooltip"] = { applyAnchor = true },
			["QuestScrollFrame.CampaignTooltip"] = { applyAnchor = true },
			["WorldMapTooltip"] = { applyAnchor = true },
			["SettingsTooltip"] = { applyAnchor = true },
			
			-- 3rd party addon tooltips
			["AceConfigDialogTooltip"] = { applyAnchor = true },
			["LibDBIconTooltip"] = { applyAnchor = true },
			["AtlasLootTooltip"] = { applyAnchor = true },
			["QuestHelperTooltip"] = { applyAnchor = true },
			["QuestGuru_QuestWatchTooltip"] = { applyAnchor = true },
			["PlaterNamePlateAuraTooltip"] = { applyAnchor = true }
		}
	},
	["Blizzard_CharacterCustomize"] = {
		frames = {
			["CharCustomizeTooltip"] = { applyAnchor = true },
			["CharCustomizeNoHeaderTooltip"] = { applyAnchor = true }
		}
	},
	["Blizzard_Collections"] = {
		frames = {
			["PetJournalPrimaryAbilityTooltip"] = { applyAnchor = true },
			["PetJournalSecondaryAbilityTooltip"] = { applyAnchor = true }
		},
		hookFnForAddOn = function(TT_CacheForFrames)
			-- HOOK: SharedPetBattleAbilityTooltip_UpdateSize() to re-hook OnUpdate for PetJournalPrimaryAbilityTooltip and PetJournalSecondaryAbilityTooltip
			LibFroznFunctions:HookSecureFuncIfExists("SharedPetBattleAbilityTooltip_UpdateSize", function(self)
				-- re-hook OnUpdate for PetJournalPrimaryAbilityTooltip and PetJournalSecondaryAbilityTooltip to anchor tip to mouse position
				if (LibFroznFunctions:ExistsInTable(self, { PetJournalPrimaryAbilityTooltip, PetJournalSecondaryAbilityTooltip })) then
					tt:AnchorTipToMouseOnUpdate(self);
				end
			end);
		end
	},
	["Blizzard_Contribution"] = {
		frames = {
			["ContributionBuffTooltip"] = { applyAnchor = true }
		}
	},
	["Blizzard_EncounterJournal"] = {
		frames = {
			["EncounterJournalTooltip"] = { applyAnchor = true }
		}
	},
	["Blizzard_PerksProgram"] = {
		frames = {
			["PerksProgramTooltip"] = { applyAnchor = true }
		}
	},
	["Blizzard_PetBattleUI"] = {
		frames = {
			["PetBattlePrimaryUnitTooltip"] = { applyAnchor = true },
			["PetBattlePrimaryAbilityTooltip"] = { applyAnchor = true }
		},
		hookFnForAddOn = function(TT_CacheForFrames)
			-- HOOK: PetBattleAbilityButton_OnEnter to re-anchor tooltip of pet ability buttons in bottom frame
			hooksecurefunc("PetBattleAbilityButton_OnEnter", function(self)
				if (PetBattlePrimaryAbilityTooltip:IsShown()) then
					PetBattlePrimaryAbilityTooltip:ClearAllPoints();
					PetBattlePrimaryAbilityTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 0, 0);
				end
			end);
		end
	},
	["ElvUI"] = {
		frames = {
			["ElvUI_SpellBookTooltip"] = { applyAnchor = true }
		}
	}
};

----------------------------------------------------------------------------------------------------
--                                           Variables                                            --
----------------------------------------------------------------------------------------------------

-- colors
local TT_COLOR = {
	text = {
		default = HIGHLIGHT_FONT_COLOR, -- white
		highlight = LIGHTYELLOW_FONT_COLOR,
		caption = NORMAL_FONT_COLOR, -- yellow
		chat = BRIGHTBLUE_FONT_COLOR,
		error = RED_FONT_COLOR
	},
	anchor = {
		backdrop = CreateColor(0.1, 0.1, 0.2, 1),
		backdropBorder = CreateColor(0.1, 0.1, 0.1, 1)
	}
};

-- tips to modify from other mods with TipTac:AddModifiedTip()
--
-- key = real frame
--
-- params: see params for 3rd key from "TT_ExtendedConfig.tipsToModify"
--
-- hint: frames will be added to TT_CacheForFrames. The params will be added under ".config", the frame name under ".frameName".
local TT_TipsToModifyFromOtherMods = {};

-- cache for frames
--
-- 1st key = real frame
--
-- params for 1st key:
-- frameName                                       frame name, nil for anonymous frames without a parent.
-- config                                          see params from "TT_ExtendedConfig.tipsToModify"
-- currentDisplayParams                            current display parameters

-- params for 2nd key (currentDisplayParams):
-- isSet                                             true if current display parameters are set, false otherwise.
-- isSetTemporarily                                  true if current display parameters are temporarily set, false otherwise.
--
-- isSetTimestamp                                    timestamp of current display parameters were set, nil otherwise.
--
-- ignoreNextSetCurrentDisplayParams                 true if ignoring next tooltip's current display parameters to be set, nil otherwise.
-- tipContent                                        see TT_TIP_CONTENT
-- hideTip                                           true if tip will be hidden, false otherwise.
-- hideShoppingTips                                  true if shopping tips will be hidden, false otherwise.
--
-- defaultAnchored                                   true if tip is default anchored, false otherwise.
-- defaultAnchoredParentFrame                        tip's parent frame if default anchored, nil otherwise.
-- anchorFrameName                                   anchor frame name of tip, values "WorldUnit", "WorldTip", "FrameUnit", "FrameTip"
-- anchorType                                        anchor type for tip
-- anchorPoint                                       anchor point for tip
--
-- unitRecord                                        table with information about the displayed unit, nil otherwise, see LibFroznFunctions:CreateUnitRecord()
-- timestampStartCustomUnitFadeout                   timestamp of start of custom unit fadeout, nil otherwise.
--
-- hint: resolved frames from "TT_ExtendedConfig.tipsToModify" will be added here. frames from other mods added with TipTac:AddModifiedTip(tip, noHooks) will be added here, too.
local TT_CacheForFrames = {};

-- tip content
local TT_TIP_CONTENT = {
	unit = 1,
	aura = 2,
	spell = 3,
	item = 4,
	action = 5,
	others = 6,
	unknownOnShow = 7,
	unknownOnCleared = 8
};

-- others
local TT_IsConfigLoaded = false;
local TT_IsApplyTipAppearanceAndHooking = false;

----------------------------------------------------------------------------------------------------
--                                        Helper Functions                                        --
----------------------------------------------------------------------------------------------------

-- add message to (selected) chat frame
local replacementsForChatFrame = {
	["{caption:"] = TT_COLOR.text.caption:GenerateHexColorMarkup(),
	["{highlight:"] = TT_COLOR.text.highlight:GenerateHexColorMarkup(),
	["{error:"] = TT_COLOR.text.error:GenerateHexColorMarkup(),
	["}"] = FONT_COLOR_CODE_CLOSE
};

function tt:AddMessageToChatFrame(message, ...)
	LibFroznFunctions:AddMessageToChatFrame(LibFroznFunctions:ReplaceText(message, replacementsForChatFrame, ...), TT_COLOR.text.chat:GetRGB());
end

----------------------------------------------------------------------------------------------------
--                                  Setup Frames - TipTac anchor                                  --
----------------------------------------------------------------------------------------------------

tt:SetSize(114, 24);
tt:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 8,
	tileEdge = false,
	edgeSize = 12,
	insets = { left = 2, right = 2, top = 2, bottom = 2 }
});
tt:SetBackdropColor(TT_COLOR.anchor.backdrop:GetRGBA());
tt:SetBackdropBorderColor(TT_COLOR.anchor.backdropBorder:GetRGBA());
tt:SetMovable(true);
tt:EnableMouse(true);
tt:SetToplevel(true);
tt:SetClampedToScreen(true);

tt.text = tt:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
tt.text:SetText(MOD_NAME .. "Anchor");
tt.text:SetPoint("LEFT", 6, 0);

tt.close = CreateFrame("Button", nil, tt, "UIPanelCloseButton");
tt.close:SetSize(24, 24);
tt.close:SetPoint("RIGHT");

-- handlers
tt:SetScript("OnShow", function(self)
	cfg.left, cfg.top = self:GetLeft(), self:GetTop();
end);

tt:SetScript("OnMouseDown", function(self)
	self:StartMoving();
end);

tt:SetScript("OnMouseUp", function(self)
	self:StopMovingOrSizing();
	cfg.left, cfg.top = self:GetLeft(), self:GetTop();
end);

-- show TipTac anchor on default position
local function showTipTacAnchorOnDefaultPosition()
	tt:ClearAllPoints();
	-- tt:SetPoint("CENTER");
	tt.SetOwner = function() end;
	GameTooltip_SetDefaultAnchor(tt);
	tt.SetOwner = nil;
	
	tt:Show();
end

-- register for group events
LibFroznFunctions:RegisterForGroupEvents(MOD_NAME, {
	OnConfigLoaded = function(self, TT_CacheForFrames, configDb, cfg, TT_ExtendedConfig)
		-- show TipTac anchor on default position if no position for it is set
		if (not cfg.left) or (not cfg.top) then
			showTipTacAnchorOnDefaultPosition()
		
		-- set position of TipTac anchor if position for it is set
		else
			tt:ClearAllPoints();
			tt:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", cfg.left, cfg.top);
		
		end
	end,
	OnApplyConfig = function(self, TT_CacheForFrames, configDb, cfg, TT_ExtendedConfig)
		-- show TipTac anchor on default position if no position for it is set
		if (not cfg.left) or (not cfg.top) then
			showTipTacAnchorOnDefaultPosition()
		end
	end
}, MOD_NAME .. " - TipTac Anchor");

tt:Hide();

----------------------------------------------------------------------------------------------------
--                                          Setup Addon                                           --
----------------------------------------------------------------------------------------------------

-- EVENT: addon loaded
function tt:ADDON_LOADED(event, addOnName, containsBindings)
	if (TT_IsConfigLoaded) then
		-- apply config
		self:ApplyConfig();
		return;
	end
	
	-- not this addon
	if (addOnName ~= MOD_NAME) then
		return;
	end
	
	-- setup config
	self:SetupConfig();
	
	-- inform group that the config is about to be loaded
	LibFroznFunctions:FireGroupEvent(MOD_NAME, "OnConfigPreLoaded", TT_CacheForFrames, configDb, cfg, TT_ExtendedConfig);
	
	-- inform group that the config has been loaded
	TT_IsConfigLoaded = true;
	
	LibFroznFunctions:FireGroupEvent(MOD_NAME, "OnConfigLoaded", TT_CacheForFrames, configDb, cfg, TT_ExtendedConfig);
end

-- EVENT: player login (one-time-event)
function tt:PLAYER_LOGIN(event)
	TT_IsApplyTipAppearanceAndHooking = true;
	
	-- apply config
	self:ApplyConfig();
	
	-- inform group that the tooltip's appearance and hooking needs to be applied
	LibFroznFunctions:FireGroupEvent(MOD_NAME, "OnApplyTipAppearanceAndHooking", TT_CacheForFrames, configDb, cfg, TT_ExtendedConfig);
	
	-- cleanup
	self:UnregisterEvent(event);
	self[event] = nil;
end

-- register events
tt:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...);
end);

tt:RegisterEvent("ADDON_LOADED");
tt:RegisterEvent("PLAYER_LOGIN");

----------------------------------------------------------------------------------------------------
--                                         Custom Events                                          --
----------------------------------------------------------------------------------------------------

-- group events: TipTac (see MOD_NAME)
--
-- eventName                           description                                                                             additional payload
-- ----------------------------------  --------------------------------------------------------------------------------------  ------------------------------------------------------------
-- OnConfigPreLoaded                   before config has been loaded                                                           TT_CacheForFrames, configDb, cfg, TT_ExtendedConfig
-- OnConfigLoaded                      config has been loaded                                                                  TT_CacheForFrames, configDb, cfg, TT_ExtendedConfig
-- OnApplyConfig                       config settings need to be applied                                                      TT_CacheForFrames, configDb, cfg, TT_ExtendedConfig
-- OnApplyTipAppearanceAndHooking      every tooltip's appearance and hooking needs to be applied                              TT_CacheForFrames, configDb, cfg, TT_ExtendedConfig
--                                                                                                                             
-- OnTipAddedToCache                   tooltip has been added to cache for frames                                              TT_CacheForFrames, tooltip
--                                                                                                                             
-- OnTipSetCurrentDisplayParams        tooltip's current display parameters has to be set                                      TT_CacheForFrames, tooltip, currentDisplayParams, tipContent
-- OnTipPostSetCurrentDisplayParams    after tooltip's current display parameters has to be set                                TT_CacheForFrames, tooltip, currentDisplayParams, tipContent
--                                                                                                                             
-- OnTipSetHidden                      check if tooltip needs to be hidden                                                     TT_CacheForFrames, tooltip, currentDisplayParams, tipContent
-- OnTipSetStyling                     tooltip's styling needs to be set                                                       TT_CacheForFrames, tooltip, currentDisplayParams, tipContent
--                                                                                                                             
--                                                                                                                             
-- OnTipPostSetStyling                 after tooltip's styling has been set                                                 TT_CacheForFrames, tooltip, currentDisplayParams, tipContent
--                                                                                                                             
--                                                                                                                             
-- OnTipResetCurrentDisplayParams      tooltip's current display parameters has to be reset                                    TT_CacheForFrames, tooltip, currentDisplayParams
-- OnTipPostResetCurrentDisplayParams  after tooltip's current display parameters has to be reset                              TT_CacheForFrames, tooltip, currentDisplayParams
--                                                                                                                             
--                                                                                                                             
-- OnPlayerRegenEnabled                player regen has been enabled (after ending combat)                                     TT_CacheForFrames
-- OnPlayerRegenDisabled               player regen has been disabled (whenever entering combat)                               TT_CacheForFrames
-- OnUpdateBonusActionbar              bonus bar has been updated                                                              TT_CacheForFrames
-- OnModifierStateChanged              modifier state has been changed (shift/ctrl/alt keys are pressed or released)           TT_CacheForFrames

----------------------------------------------------------------------------------------------------
--                                       Interface Options                                        --
----------------------------------------------------------------------------------------------------

-- toggle options
function tt:ToggleOptions()
	local addOnName = MOD_NAME .. "Options";
	local loaded, reason = C_AddOns.LoadAddOn(addOnName);
	
	if (loaded) then
		local TipTacOptions = _G[addOnName];
		TipTacOptions:SetShown(not TipTacOptions:IsShown());
	else
		tt:AddMessageToChatFrame("{caption:" .. MOD_NAME .. "}: {error:Couldn't open " .. MOD_NAME .. " Options: [{highlight:" .. _G["ADDON_" .. reason] .. "}]. Please make sure the addon is enabled in the character selection screen.}"); -- see UIParentLoadAddOn()
	end
end

-- register addon category
LibFroznFunctions:RegisterAddOnCategory((function()
	local frame = CreateFrame("Frame");
	
	frame:SetScript("OnShow", function(self)
		self.header = self:CreateFontString(nil, "ARTWORK");
		self.header:SetFontObject(GameFontNormalLarge);
		self.header:SetPoint("TOPLEFT", 16, -16);
		self.header:SetText(TT_COLOR.text.caption:WrapTextInColorCode(MOD_NAME));
		
		self.vers1 = self:CreateFontString(nil, "ARTWORK");
		self.vers1:SetFontObject(GameFontHighlight);
		self.vers1:SetJustifyH("LEFT");
		self.vers1:SetPoint("TOPLEFT", self.header, "BOTTOMLEFT", 0, -8);
		self.vers1:SetText(TT_COLOR.text.highlight:WrapTextInColorCode(MOD_NAME .. ": \nWoW: "));
		
		self.vers2 = self:CreateFontString(nil, "ARTWORK");
		self.vers2:SetFontObject(GameFontHighlight);
		self.vers2:SetJustifyH("LEFT");
		self.vers2:SetPoint("TOPLEFT", self.vers1, "TOPRIGHT");
		self.vers2:SetText(C_AddOns.GetAddOnMetadata(MOD_NAME, "Version") .. "\n" .. GetBuildInfo());
		
		self.notes = self:CreateFontString(nil, "ARTWORK");
		self.notes:SetFontObject(GameFontHighlight);
		self.notes:SetPoint("TOPLEFT", self.vers1, "BOTTOMLEFT", 0, -8);
		self.notes:SetText(C_AddOns.GetAddOnMetadata(MOD_NAME, "Notes"));
		
		self.btnOptions = CreateFrame("Button", nil, self, "UIPanelButtonTemplate");
		self.btnOptions:SetPoint("TOPLEFT", self.notes, "BOTTOMLEFT", -2, -8);
		self.btnOptions:SetText(GAMEOPTIONS_MENU);
		self.btnOptions:SetWidth(math.max(120, self.btnOptions:GetTextWidth() + 20));
		self.btnOptions:SetScript("OnEnter", function()
			GameTooltip:SetOwner(self.btnOptions, "ANCHOR_RIGHT");
			GameTooltip:SetText("Slash commands");
			GameTooltip:AddLine(TT_COLOR.text.default:WrapTextInColorCode("/tip\n/tiptac"), nil, nil, nil, true);
			GameTooltip:Show();
		end);
		self.btnOptions:SetScript("OnLeave", function()
			GameTooltip:Hide();
		end);
		self.btnOptions:SetScript("OnClick", function()
			tt:ToggleOptions();
		end);
		
		-- cleanup
		self:SetScript("OnShow", nil);
	end);
	
	frame:Hide();
	
	return frame;
end)(), MOD_NAME);

-- addon compartment
function tt:SetAddonCompartmentText(tip)
	tip:SetText(MOD_NAME);
	tip:AddLine(TT_COLOR.text.default:WrapTextInColorCode("Click to toggle options"));
end

function TipTac_OnAddonCompartmentClick(addonName, mouseButton)
	-- toggle options
	tt:ToggleOptions();
end

function TipTac_OnAddonCompartmentEnter(addonName, button)
    GameTooltip:SetOwner(button, "ANCHOR_LEFT");
	tt:SetAddonCompartmentText(GameTooltip);
	GameTooltip:Show();
end

function TipTac_OnAddonCompartmentLeave(addonName, button)
	GameTooltip:Hide();
end

-- register new slash commands
LibFroznFunctions:RegisterNewSlashCommands(MOD_NAME, { "/tip", "/tiptac" }, function(msg)
	-- extract parameters
	local parameters = LibFroznFunctions:CreatePushArray();
	
	for parameter in tostring(msg):gmatch("([^%s]+)") do
		parameters:Push(parameter:lower());
	end
	
	-- toggle options
	if (parameters:GetCount() == 0) then
		tt:ToggleOptions();
		return;
	end
	
	-- show TipTac anchor
	if (parameters[1] == "anchor") then
		tt:SetShown(not tt:IsShown());
		return;
	end
	
	-- reset settings
	if (parameters[1] == "reset") then
		wipe(cfg);
		tt:ApplyConfig();
		tt:AddMessageToChatFrame("{caption:" .. MOD_NAME .. "}: All {highlight:" .. MOD_NAME .. "} settings has been reset to their default values.");
		return;
	end
	
	-- invalid command
	local versionWoW, build = GetBuildInfo();
	local versionTipTac = C_AddOns.GetAddOnMetadata(MOD_NAME, "Version");
	
	UpdateAddOnMemoryUsage();
	
	tt:AddMessageToChatFrame("----- {highlight:%s %s} ----- {highlight:%.2f kb} ----- {highlight:WoW " .. versionWoW .. "} ----- ", MOD_NAME, versionTipTac, GetAddOnMemoryUsage(MOD_NAME));
	tt:AddMessageToChatFrame("The following {highlight:parameters} are valid for this addon:");
	tt:AddMessageToChatFrame("  {highlight:anchor} = Shows the anchor where the tooltip appears");
	tt:AddMessageToChatFrame("  {highlight:reset} = Resets all settings back to their default values");
end);

----------------------------------------------------------------------------------------------------
--                                      Pixel Perfect Scale                                       --
----------------------------------------------------------------------------------------------------

-- get nearest pixel size (e.g. to avoid 1-pixel borders which are sometimes 0/2-pixels wide)
--
-- description:
-- - instead of pixels, lengths measure in scaled units equal to 1/768 of the screen height multiplied by a ratio.
-- - the ratio for frames can be determined with frame:GetEffectiveScale().
-- - the effective scale is the scale of the frame multiplied by all individual parent frame scales. if scale propagation on a frame in this chain has been disabled by calling SetIgnoreParentScale(true), the chain ends there.
--
-- - calculation to determine the pixel perfect size needed for given pixels:                                              PixelUtil.GetNearestPixelSize(pixels * TT_UIUnitFactor, 1) / frame:GetEffectiveScale()
-- - calculation to determine the pixel perfect size needed for given pixels shrinking/expanding with frame's scale:       PixelUtil.GetNearestPixelSize(pixels * TT_UIUnitFactor, frame:GetEffectiveScale())
-- - calculation to determine the pixel perfect size needed for given scaled units:                                        PixelUtil.GetNearestPixelSize(scaledUnits, 1) / frame:GetEffectiveScale()
-- - calculation to determine the pixel perfect size needed for given scaled units shrinking/expanding with frame's scale: PixelUtil.GetNearestPixelSize(scaledUnits, frame:GetEffectiveScale())
local TT_PhysicalScreenWidth, TT_PhysicalScreenHeight, TT_UIUnitFactor, TT_UIScale;

function tt:GetNearestPixelSize(tip, size, pixelPerfect, ignoreScale)
	local tipEffectiveScale = tip:GetEffectiveScale();
	local realSize = ((pixelPerfect and (size * TT_UIUnitFactor)) or size);
	local targetScale = (ignoreScale and 1 or tipEffectiveScale);
	local frameScaleAdjustmentToAchieveTargetScale = (ignoreScale and tip:GetEffectiveScale() or 1);
	
	return PixelUtil.GetNearestPixelSize(realSize, targetScale) / frameScaleAdjustmentToAchieveTargetScale;
end

-- update pixel perfect scale
function tt:UpdatePixelPerfectScale()
	local currentConfig = (TT_IsConfigLoaded and cfg or TT_DefaultConfig);
	
	TT_PhysicalScreenWidth, TT_PhysicalScreenHeight = GetPhysicalScreenSize();
	TT_UIUnitFactor = 768.0 / TT_PhysicalScreenHeight;
	TT_UIScale = UIParent:GetEffectiveScale();
end

tt:UpdatePixelPerfectScale();

-- EVENT: UI scale changed
function tt:UI_SCALE_CHANGED(event)
	-- apply config
	self:ApplyConfig();
end

-- HOOK: UIParent scale changed
hooksecurefunc(UIParent, "SetScale", function()
	-- apply config
	tt:ApplyConfig();
end);

-- EVENT: display size changed
function tt:DISPLAY_SIZE_CHANGED(event)
	-- apply config
	self:ApplyConfig();
end

-- register events
tt:RegisterEvent("UI_SCALE_CHANGED");
tt:RegisterEvent("DISPLAY_SIZE_CHANGED");

----------------------------------------------------------------------------------------------------
--                                          Setup Config                                          --
----------------------------------------------------------------------------------------------------

-- setup config
function tt:SetupConfig()
	-- set config
	configDb, cfg = LibFroznFunctions:CreateDbWithLibAceDB("TipTac_Config", TT_DefaultConfig);
end

----------------------------------------------------------------------------------------------------
--                                          Apply Config                                          --
----------------------------------------------------------------------------------------------------

function tt:ApplyConfig()
	-- update pixel perfect scale
	self:UpdatePixelPerfectScale();
	
	-- not ready to apply tip hooking
	if (not TT_IsApplyTipAppearanceAndHooking) then
		return;
	end;
	
	-- resolve tips to modify to determine the real frame
	self:ResolveTipsToModify();
	
	-- unregister event "ADDON_LOADED" if all tips to modify are resolved
	if (LibFroznFunctions:IsTableEmpty(TT_ExtendedConfig.tipsToModify)) then
		self:UnregisterEvent("ADDON_LOADED");
		self.ADDON_LOADED = nil;
	end
	
	-- inform group that the config has been applied
	LibFroznFunctions:FireGroupEvent(MOD_NAME, "OnApplyConfig", TT_CacheForFrames, configDb, cfg, TT_ExtendedConfig);
end

-- resolve tips to modify to determine the real frame
function tt:ResolveTipsToModify()
	-- not ready to apply tip appearance and hooking
	if (not TT_IsApplyTipAppearanceAndHooking) then
		return;
	end;
	
	-- tips to modify
	for addOnName, addOnConfig in pairs(TT_ExtendedConfig.tipsToModify) do
		if (LibFroznFunctions:IsAddOnFinishedLoading(addOnName)) then
			if (addOnConfig.frames) then
				for frameName, tipParams in pairs(addOnConfig.frames) do
					LibFroznFunctions:CallFunctionDelayed(tipParams.waitSecondsForLookupFrameName, function()
						-- lookup the global object for this frame name
						local tip = LibFroznFunctions:GetValueFromObjectByPath(_G, frameName);
						
						-- add tip to cache
						tt:AddTipToCache(tip, frameName, tipParams);
					end);
				end
				
				-- remove frames from addon config
				wipe(addOnConfig.frames);
			end
			
			-- remove addon config from tips to modify
			local addOnConfig_hookFnForAddOn = addOnConfig.hookFnForAddOn;
			local addOnConfig_waitSecondsForHooking = addOnConfig.waitSecondsForHooking;
			
			wipe(addOnConfig);
			TT_ExtendedConfig.tipsToModify[addOnName] = nil;
			
			-- apply hooks for addon
			--
			-- hint:
			-- function hookFnForAddOn() needs to be called after removing addon config from tips to modify (see above),
			-- because immediately calling tt:AddModifiedTipExtended() within hookFnForAddOn() leads to an infinite loop
			-- because of calling tt:ApplyConfig() within tt:AddModifiedTipExtended() which leads to another call of tt:ResolveTipsToModify() and so on.
			if (addOnConfig_hookFnForAddOn) then
				LibFroznFunctions:CallFunctionDelayed(addOnConfig_waitSecondsForHooking, function()
					addOnConfig_hookFnForAddOn(TT_CacheForFrames);
				end);
			end
		end
	end
	
	-- tips to modify from other mods with TipTac:AddModifiedTip()
	for tip, tipParams in pairs(TT_TipsToModifyFromOtherMods) do
		-- add tip to cache
		self:AddTipToCache(tip, tip:GetDebugName(), tipParams);
	end
	
	-- remove frames from tips to modify from other mods with TipTac:AddModifiedTip()
	wipe(TT_TipsToModifyFromOtherMods);
end

-- add tip to cache
function tt:AddTipToCache(tip, frameName, tipParams)
	-- not ready to apply tip appearance and hooking
	if (not TT_IsApplyTipAppearanceAndHooking) then
		return;
	end;
	
	-- check if frame hasn't been resolved or frame already exists in cache for frames
	if (type(tip) ~= "table") or (type(tip.GetObjectType) ~= "function") or (TT_CacheForFrames[tip]) then
		return;
	end
	
	-- add tip to cache
	TT_CacheForFrames[tip] = {
		frameName = frameName,
		config = ((type(tipParams) == "table") and tipParams or {}),
		currentDisplayParams = {
			isSet = false
		}
	};
	
	-- apply hooks for frame to set/reset current display parameters
	self:ResetCurrentDisplayParams(tip);
	
	if (not tipParams.noHooks) then
		LibFroznFunctions:CallFunctionDelayed(tipParams.waitSecondsForHooking, function()
			-- check if insecure interaction with the tip is currently forbidden
			if (tip:IsForbidden()) then
				return;
			end
			
			tip:HookScript("OnShow", function(tip)
				tt:SetCurrentDisplayParams(tip, TT_TIP_CONTENT.unknownOnShow);
			end);
			
			if (tip:GetObjectType() == "GameTooltip") then
				LibFroznFunctions:HookSecureFuncIfExists(tip, "Show", function(tip)
					tt:SetCurrentDisplayParams(tip, TT_TIP_CONTENT.unknownOnShow);
				end);
				LibFroznFunctions:HookSecureFuncIfExists(tip, "SetUnit", function(tip)
					tt:SetCurrentDisplayParams(tip, TT_TIP_CONTENT.unit);
				end);
				LibFroznFunctions:HookSecureFuncIfExists(tip, "SetUnitAura", function(tip)
					tt:SetCurrentDisplayParams(tip, TT_TIP_CONTENT.aura);
				end);
				LibFroznFunctions:HookSecureFuncIfExists(tip, "SetUnitBuff", function(tip)
					tt:SetCurrentDisplayParams(tip, TT_TIP_CONTENT.aura);
				end);
				LibFroznFunctions:HookSecureFuncIfExists(tip, "SetUnitDebuff", function(tip)
					tt:SetCurrentDisplayParams(tip, TT_TIP_CONTENT.aura);
				end);
				LibFroznFunctions:HookSecureFuncIfExists(tip, "SetUnitBuffByAuraInstanceID", function(tip)
					tt:SetCurrentDisplayParams(tip, TT_TIP_CONTENT.aura);
				end);
				LibFroznFunctions:HookSecureFuncIfExists(tip, "SetUnitDebuffByAuraInstanceID", function(tip)
					tt:SetCurrentDisplayParams(tip, TT_TIP_CONTENT.aura);
				end);
				LibFroznFunctions:HookScriptOnTooltipSetUnit(tip, function(tip)
					tt:SetCurrentDisplayParams(tip, TT_TIP_CONTENT.unit);
				end);
				LibFroznFunctions:HookScriptOnTooltipSetItem(tip, function(tip)
					tt:SetCurrentDisplayParams(tip, TT_TIP_CONTENT.item);
				end);
				LibFroznFunctions:HookScriptOnTooltipSetSpell(tip, function(tip)
					tt:SetCurrentDisplayParams(tip, TT_TIP_CONTENT.spell);
				end);
				LibFroznFunctions:HookSecureFuncIfExists(tip, "SetAction", function(tip)
					tt:SetCurrentDisplayParams(tip, TT_TIP_CONTENT.action);
				end);
				LibFroznFunctions:HookSecureFuncIfExists(tip, "SetHyperlink", function(tip)
					tt:SetCurrentDisplayParams(tip, TT_TIP_CONTENT.others);
				end);
				
				tip:HookScript("OnTooltipCleared", function(tip)
					if (not tip:IsForbidden()) and (tip:IsShown()) and (tip:GetObjectType() == "GameTooltip") and (tip.shouldRefreshData) then
						return;
					end
					
					tt:ResetCurrentDisplayParams(tip);
					
					if (not tip:IsForbidden()) and (tip:IsShown()) then
						tt:SetCurrentDisplayParams(tip, TT_TIP_CONTENT.unknownOnCleared);
					end
				end);
			end
			
			tip:HookScript("OnHide", function(tip)
				tt:ResetCurrentDisplayParams(tip);
			end);
		end);
	end
	
	-- apply individual function for hooking for frame
	if (tipParams.hookFnForFrame) then
		LibFroznFunctions:CallFunctionDelayed(tipParams.waitSecondsForHooking, function()
			tipParams.hookFnForFrame(TT_CacheForFrames, tip);
		end);
	end
	
	-- inform group that the tip has been added to cache for frames
	LibFroznFunctions:FireGroupEvent(MOD_NAME, "OnTipAddedToCache", TT_CacheForFrames, tip);
end

-- set tip's current display parameters
function tt:SetCurrentDisplayParams(tip, tipContent)
	-- get current display parameters
	local frameParams = TT_CacheForFrames[tip];
	
	if (not frameParams) then
		return;
	end
	
	local currentDisplayParams = frameParams.currentDisplayParams;
	
	-- ignore next setting tip's current display parameters
	if (currentDisplayParams.ignoreNextSetCurrentDisplayParams) then
		currentDisplayParams.ignoreNextSetCurrentDisplayParams = nil;
		
		return;
	end
	
	-- consider missing reset of tip's current display parameters
	-- - e.g. if hovering over unit auras which will be hidden. there will be subsequent calls of GameTooltip:SetUnitAura() without a new GameTooltip:OnShow().
	-- - e.g. if hovering over empty action bar buttons the GameTooltip:SetAction() will be called, but there's no tooltip. therefore no OnTooltipCleared() will
	--	      be fired if leaving the button and the currentDisplayParams are still set. afterwards if moving to a world unit, we need firing the group event.
	local currentTime = GetTime();
	
	if ((currentDisplayParams.isSet) or (currentDisplayParams.isSetTemporarily)) and (currentDisplayParams.isSetTimestamp ~= currentTime) then
		self:ResetCurrentDisplayParams(tip, true); -- necessary to fire no group events here, e.g because "currentDisplayParams.defaultAnchored" will be lost.
	end
	
	-- tip will be hidden
	if (currentDisplayParams.hideTip) then
		self:HideTip(tip);
		return;
	end
	
	-- current display parameters aren't set yet
	local tipContentUnknown = LibFroznFunctions:ExistsInTable(tipContent, { TT_TIP_CONTENT.unknownOnShow, TT_TIP_CONTENT.unknownOnCleared });
	
	if (not ((currentDisplayParams.isSet) or (currentDisplayParams.isSetTemporarily) and (tipContentUnknown))) then
		-- set tip content
		currentDisplayParams.tipContent = tipContent;
		
		-- inform group that the tip's current display parameters has to be set
		LibFroznFunctions:FireGroupEvent(MOD_NAME, "OnTipSetCurrentDisplayParams", TT_CacheForFrames, tip, currentDisplayParams, tipContent);
		LibFroznFunctions:FireGroupEvent(MOD_NAME, "OnTipPostSetCurrentDisplayParams", TT_CacheForFrames, tip, currentDisplayParams, tipContent);
		
		if (tipContentUnknown) then
			currentDisplayParams.isSetTemporarily = true;
		else
			currentDisplayParams.isSet = true;
		end
		
		currentDisplayParams.isSetTimestamp = currentTime;
	end
	
	-- inform group that the tip has to be checked if it needs to be hidden
	LibFroznFunctions:FireGroupEvent(MOD_NAME, "OnTipSetHidden", TT_CacheForFrames, tip, currentDisplayParams, tipContent);
	
	-- tip will be hidden
	if (currentDisplayParams.hideTip) then
		self:HideTip(tip);
		return;
	end
	
	-- shopping tips will be hidden
	if (currentDisplayParams.hideShoppingTips) then
		self:HideShoppingTips(tip);
	end
	
	-- inform group that the tip's styling needs to be set
	LibFroznFunctions:FireGroupEvent(MOD_NAME, "OnTipSetStyling", TT_CacheForFrames, tip, currentDisplayParams, tipContent);
	
	-- recalculate size of tip to ensure that it has the correct dimensions
	if (tipContent ~= TT_TIP_CONTENT.unknownOnCleared) then -- prevent recalculating size of tip on tip content "unknownOnCleared" to prevent accidentally reducing tip's width/height to a tiny square e.g. on individual GameTooltips with tip:ClearLines(). test case: addon "Titan Panel" with broker addon "Profession Cooldown".
		LibFroznFunctions:RecalculateSizeOfGameTooltip(tip);
	end

	-- inform group that the tip's styling has been set
	LibFroznFunctions:FireGroupEvent(MOD_NAME, "OnTipPostSetStyling", TT_CacheForFrames, tip, currentDisplayParams, tipContent);
end

-- reset tip's current display parameters
function tt:ResetCurrentDisplayParams(tip, noFireGroupEvent)
	-- get current display parameters
	local frameParams = TT_CacheForFrames[tip];
	
	if (not frameParams) then
		return;
	end
	
	local currentDisplayParams = frameParams.currentDisplayParams;
	
	-- current display parameters are already resetted
	if (not currentDisplayParams.isSet) and (not currentDisplayParams.isSetTemporarily) then
		return;
	end
	
	-- inform group that the tip's current display parameters has to be reset
	if (not noFireGroupEvent) then
		LibFroznFunctions:FireGroupEvent(MOD_NAME, "OnTipResetCurrentDisplayParams", TT_CacheForFrames, tip, currentDisplayParams);
		LibFroznFunctions:FireGroupEvent(MOD_NAME, "OnTipPostResetCurrentDisplayParams", TT_CacheForFrames, tip, currentDisplayParams);
	end
	
	currentDisplayParams.isSet = false;
	currentDisplayParams.isSetTemporarily = false;
	
	currentDisplayParams.isSetTimestamp = nil;
	
	currentDisplayParams.hideTip = false;
	currentDisplayParams.hideShoppingTips = false;
	currentDisplayParams.ignoreNextSetCurrentDisplayParams = nil;
end

-- hide tip
function tt:HideTip(tip)
	if (not tip:IsForbidden()) and (tip:IsShown()) then
		tip:Hide();
	end
end

-- hide shopping tips
function tt:HideShoppingTips(tip)
	if (not tip:IsForbidden()) and (tip:IsShown()) then
		GameTooltip_HideShoppingTooltips(tip);
	end
end

-- hide tips if need to be hidden
function tt:HideTipsIfNeedToBeHidden()
	-- hide tip if needs to be hidden
	for tip, frameParams in pairs(TT_CacheForFrames) do
		self:HideTipIfNeedsToBeHidden(tip);
	end
end

-- hide tip if needs to be hidden
function tt:HideTipIfNeedsToBeHidden(tip)
	-- get current display parameters
	local frameParams = TT_CacheForFrames[tip];
	
	if (not frameParams) then
		return;
	end
	
	local currentDisplayParams = frameParams.currentDisplayParams;
	
	-- current display parameters aren't set
	if (not currentDisplayParams.isSet) and (not currentDisplayParams.isSetTemporarily) then
		return;
	end
	
	-- tip already hidden
	if (currentDisplayParams.hideTip) then
		return;
	end
	
	-- inform group that the tip has to be checked if it needs to be hidden
	LibFroznFunctions:FireGroupEvent(MOD_NAME, "OnTipSetHidden", TT_CacheForFrames, tip, currentDisplayParams, currentDisplayParams.tipContent);
	
	-- tip will be hidden
	if (currentDisplayParams.hideTip) then
		self:HideTip(tip);
	
	-- shopping tips will be hidden
	elseif (currentDisplayParams.hideShoppingTips) then
		self:HideShoppingTips(tip);
	end
end

-- add modified tip from other mods. they can "register" tooltips or frames to be modified by TipTac.
function tt:AddModifiedTip(tipNameOrFrame, noHooks)
	self:AddModifiedTipExtended(tipNameOrFrame, {
		applyAppearance = true,
		applyScaling = true,
		applyAnchor = false,
		noHooks = noHooks
	});
end

-- add modified tip extended from other mods. they can "register" tooltips or frames to be modified by TipTac.
--
-- tipParams: see params for 3rd key from "TT_ExtendedConfig.tipsToModify"
function tt:AddModifiedTipExtended(tipNameOrFrame, tipParams)
	local tip;
	
	if (type(tipNameOrFrame) == "string") then
		-- lookup the global object for this frame name
		tip = LibFroznFunctions:GetValueFromObjectByPath(_G, tipNameOrFrame);
	else
		tip = tipNameOrFrame;
	end
	
	-- check if frame hasn't been resolved or frame already exists in cache for frames
	if (type(tip) ~= "table") or (type(tip.GetObjectType) ~= "function") or (TT_CacheForFrames[tip]) then
		return;
	end
	
	-- add tip to tips to modify from other mods with TipTac:AddModifiedTip()
	TT_TipsToModifyFromOtherMods[tip] = tipParams;
	
	-- apply config
	self:ApplyConfig();
end

-- EVENT: player regen enabled (after ending combat)
function tt:PLAYER_REGEN_ENABLED(event)
	-- inform group that the player regen has been enabled (after ending combat)
	LibFroznFunctions:FireGroupEvent(MOD_NAME, "OnPlayerRegenEnabled", TT_CacheForFrames);
end

-- EVENT: player regen disabled (whenever entering combat)
function tt:PLAYER_REGEN_DISABLED(event)
	-- inform group that the player regen has been disabled (whenever entering combat)
	LibFroznFunctions:FireGroupEvent(MOD_NAME, "OnPlayerRegenDisabled", TT_CacheForFrames);
end

-- EVENT: bonus bar updated
function tt:UPDATE_BONUS_ACTIONBAR(event)
	-- inform group that the bonus bar has been updated
	LibFroznFunctions:FireGroupEvent(MOD_NAME, "OnUpdateBonusActionbar", TT_CacheForFrames);
end

-- EVENT: modifier state changed (shift/ctrl/alt keys are pressed or released)
function tt:MODIFIER_STATE_CHANGED(event)
	-- inform group that the modifier state has been changed (shift/ctrl/alt keys are pressed or released)
	LibFroznFunctions:FireGroupEvent(MOD_NAME, "OnModifierStateChanged", TT_CacheForFrames);
end

-- register events
tt:RegisterEvent("PLAYER_REGEN_ENABLED");
tt:RegisterEvent("PLAYER_REGEN_DISABLED");
tt:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
tt:RegisterEvent("MODIFIER_STATE_CHANGED");

-- register for group events
LibFroznFunctions:RegisterForGroupEvents(MOD_NAME, {
	OnPlayerRegenEnabled = function(self, TT_CacheForFrames)
		-- hide tips if need to be hidden
		tt:HideTipsIfNeedToBeHidden();
	end,
	OnPlayerRegenDisabled = function(self, TT_CacheForFrames)
		-- hide tips if need to be hidden
		tt:HideTipsIfNeedToBeHidden();
	end,
	OnUpdateBonusActionbar = function(self, TT_CacheForFrames)
		-- hide tips if need to be hidden
		tt:HideTipsIfNeedToBeHidden();
	end,
	OnModifierStateChanged = function(self, TT_CacheForFrames)
		-- hide tips if need to be hidden
		tt:HideTipsIfNeedToBeHidden();
	end
}, MOD_NAME .. " - Recheck Hidden Tips");

----------------------------------------------------------------------------------------------------
--                                           Anchoring                                            --
----------------------------------------------------------------------------------------------------

-- refresh anchoring of shopping tooltips (e.g. "Equipped"/compare tooltips) for a tip.
-- blizzard anchors these to TooltipComparisonManager.anchorFrame, which defaults to the tip's owner (e.g. a bag/bank slot button, or a unit frame) rather than to the tip itself.
-- since TipTac may have re-anchored the tip away from that blizzard default position (e.g. via a custom "Frame Tip"/"World Tip" anchor), point them at the tip instead, every single time
-- this is refreshed, so they stay next to the tip wherever it ends up instead of drifting back to the tip's owner whenever blizzard re-triggers its own comparison anchoring.
function tt:RefreshAnchorShoppingTooltips(tip)
	local forcedAnchorFrameToTip = false;

	if (TooltipComparisonManager) and (TooltipComparisonManager.tooltip == tip) then -- since df 10.0.2
		TooltipComparisonManager.anchorFrame = tip;
		forcedAnchorFrameToTip = true;
	end

	LibFroznFunctions:RefreshAnchorShoppingTooltips(tip);

	-- the underlying refresh always leaves a 10px gap below anchorFrame's top, meant as breathing room next to a small button (blizzard's usual anchorFrame).
	-- since we forced anchorFrame to be the tip itself above, cancel that gap so the shopping tooltips' top borders sit flush with the tip's instead of 10px below it.
	if (forcedAnchorFrameToTip) then
		if (ShoppingTooltip1:IsShown()) then
			ShoppingTooltip1:AdjustPointsOffset(0, 10);
		end

		if (ShoppingTooltip2:IsShown()) then
			ShoppingTooltip2:AdjustPointsOffset(0, 10);
		end
	end
end

-- set anchor to tip
function tt:SetAnchorToTip(tip)
	-- check if insecure interaction with the tip is currently forbidden
	if (tip:IsForbidden()) then
		return;
	end
	
	-- get tip parameters
	local frameParams = TT_CacheForFrames[tip];
	
	if (not frameParams) then
		return;
	end
	
	local tipParams = frameParams.config;
	
	-- set anchor to tip not possible
	if (not cfg.enableAnchor) or (not tipParams.applyAnchor) then
		return;
	end
	
	-- tip not default anchored
	local currentDisplayParams = frameParams.currentDisplayParams;
	
	if (not currentDisplayParams.defaultAnchored) then
		return;
	end
	
	-- set anchor type and anchor point
	local anchorFrameName, anchorType, anchorPoint = currentDisplayParams.anchorFrameName, currentDisplayParams.anchorType or TT_ExtendedConfig.defaultAnchorType, currentDisplayParams.anchorPoint or TT_ExtendedConfig.defaultAnchorPoint;
	
	-- set anchor to tip
	local offsetX, offsetY
	
	if (tip:GetObjectType() == "GameTooltip") then
		local tipAnchorType = tip:GetAnchorType();
		
		-- ignore world tips
		if (tipAnchorType == "ANCHOR_CURSOR") or (tipAnchorType == "ANCHOR_CURSOR_RIGHT") then
			return;
		end
		
		-- set anchor type to tip
		if (anchorType == "normal") or (anchorType == "mouse") or (anchorType == "parent") then
			if (tipAnchorType ~= "ANCHOR_NONE") then
				tip:SetAnchorType("ANCHOR_NONE");
			end
		end
	end
	
	local function anchorFn(anchorPoint, mirrorAnchorPoint, anchorFrame, targetFrame, referenceFrame)
		local offsetX, offsetY = LibFroznFunctions:GetOffsetsForAnchorPoint(anchorPoint, anchorFrame, targetFrame, referenceFrame);
		
		if (not offsetX) or (not offsetY) then
			return false;
		end
		
		targetFrame:ClearAllPoints();
		
		if (mirrorAnchorPoint) then
			targetFrame:SetPoint(LibFroznFunctions:MirrorAnchorPointCentered(anchorPoint), referenceFrame, anchorPoint, offsetX, offsetY);
		else
			targetFrame:SetPoint(anchorPoint, referenceFrame, offsetX, offsetY);
		end
		
		return true;
	end
	
	if (anchorType == "normal") then
		-- "normal" anchor
		anchorFn(anchorPoint, false, tt, tip, UIParent);
	elseif (anchorType == "mouse") then
		-- although we anchor the tip continuously in OnUpdate, we must anchor it initially here to avoid flicker on the first frame its being shown.
		self:AnchorTipToMouse(tip);
		
		return;
	elseif (anchorType == "parent") then
		local parentFrame = currentDisplayParams.defaultAnchoredParentFrame;
		
		if (parentFrame) and (parentFrame ~= UIParent) then
			-- anchor to the opposite edge of the parent frame
			local anchored = anchorFn(anchorPoint, true, parentFrame, tip, UIParent);
			
			-- fallback to "normal" anchor in case insecure interaction with the frames is currently forbidden or parent frame is currently protected
			if (not anchored) then
				anchorFn(anchorPoint, false, tt, tip, UIParent);
			end
		else
			-- fallback to "normal" anchor in case parent frame isn't available or is UIParent
			anchorFn(anchorPoint, false, tt, tip, UIParent);
		end
	end
	
	-- refresh anchoring of shopping tooltips after re-anchoring of tip to prevent overlapping tooltips
	tt:RefreshAnchorShoppingTooltips(tip);
end

-- anchor tip to mouse position
function tt:AnchorTipToMouse(tip)
	-- check if insecure interaction with the tip is currently forbidden
	if (tip:IsForbidden()) then
		return;
	end
	
	-- get current display parameters
	local frameParams = TT_CacheForFrames[tip];
	
	if (not frameParams) then
		return;
	end
	
	local currentDisplayParams = frameParams.currentDisplayParams;
	
	-- set anchor to tip not possible
	local tipParams = frameParams.config;
	
	if (not cfg.enableAnchor) or (not tipParams.applyAnchor) then
		return;
	end
	
	-- tip not default anchored
	if (not currentDisplayParams.defaultAnchored) then
		return;
	end
	
	-- set anchor type and anchor point
	local anchorFrameName, anchorType, anchorPoint = currentDisplayParams.anchorFrameName, currentDisplayParams.anchorType or TT_ExtendedConfig.defaultAnchorType, currentDisplayParams.anchorPoint or TT_ExtendedConfig.defaultAnchorPoint;
	
	-- set anchor to tip
	if (tip:GetObjectType() == "GameTooltip") then
		local tipAnchorType = tip:GetAnchorType();
		
		-- ignore world tips
		if (tipAnchorType == "ANCHOR_CURSOR") or (tipAnchorType == "ANCHOR_CURSOR_RIGHT") then
			return;
		end
		
		-- set anchor type to tip
		if (anchorType == "mouse") then
			if (tipAnchorType ~= "ANCHOR_NONE") then
				tip:SetAnchorType("ANCHOR_NONE");
			end
		end
	end
	
	-- anchor tip to mouse position
	if (anchorType == "mouse") then
		local x, y = LibFroznFunctions:GetCursorPosition();

		-- mouse offset is configured per anchor frame (WorldUnit, WorldTip, FrameUnit, FrameTip)
		local mouseOffsetVar = "mouseOffset" .. (anchorFrameName or "FrameTip");
		local mouseOffsetX, mouseOffsetY = cfg[mouseOffsetVar .. "X"] or 0, cfg[mouseOffsetVar .. "Y"] or 0;

		tip:ClearAllPoints();
		tip:SetPoint(anchorPoint, UIParent, "BOTTOMLEFT", self:GetNearestPixelSize(tip, x + mouseOffsetX, false, true), self:GetNearestPixelSize(tip, y + mouseOffsetY, false, true));
	end
	
	-- refresh anchoring of shopping tooltips after re-anchoring of tip to prevent overlapping tooltips
	tt:RefreshAnchorShoppingTooltips(tip);
end

-- get anchor position
function tt:GetAnchorPosition(tip)
	local frameParams = TT_CacheForFrames[tip];
	
	local isUnit;
	
	if (frameParams) then
		if (frameParams.currentDisplayParams.tipContent == TT_TIP_CONTENT.unit) then
			isUnit = true;
		elseif (frameParams.currentDisplayParams.tipContent == TT_TIP_CONTENT.aura) then
			isUnit = false;
		end
	end
	
	local mouseFocus = LibFroznFunctions:GetMouseFocus();
	
	if (isUnit == nil) then
		isUnit = (UnitExists("mouseover")) and (not UnitIsUnit("mouseover", "player")) or (mouseFocus and mouseFocus.GetAttribute and mouseFocus:GetAttribute("unit")); -- GetAttribute("unit") here is bad, as that will find things like buff frames too.
	end
	
	local anchorFrameName = (LibFroznFunctions:WorldFrameIsMouseMotionFocus() and "World" or "Frame") .. (isUnit and "Unit" or "Tip");
	local var = "anchor" .. anchorFrameName;
	
	-- consider anchor override during challenge mode, instance, during skyriding or in combat
	local anchorOverride = "";
	
	local inCombat = UnitAffectingCombat("player");
	local anchorOverridePartInCombat = (inCombat and "InCombat" or "");
	
	if (cfg["enableAnchorOverride" .. anchorFrameName .. "DuringChallengeMode" .. anchorOverridePartInCombat]) and (LibFroznFunctions.hasWoWFlavor.challengeMode) and (C_ChallengeMode.IsChallengeModeActive()) then
		local difficultyID = select(3, GetInstanceInfo());
		
		if (difficultyID) then
			local isChallengeMode = select(4, GetDifficultyInfo(difficultyID));
			
			if (isChallengeMode) then
				local timerID = GetWorldElapsedTimers();
				local _, elapsedTime, timerType = GetWorldElapsedTime(timerID);
				
				if (timerType == LFF_WORLD_ELAPSED_TIMER_TYPES.ChallengeMode) and (elapsedTime >= 0) then
					anchorOverride = "DuringChallengeMode" .. anchorOverridePartInCombat;
				end
			end
		end
	end
	
	if (anchorOverride == "") and (cfg["enableAnchorOverride" .. anchorFrameName .. "DuringInstance" .. anchorOverridePartInCombat]) and (IsInInstance()) then
		anchorOverride = "DuringInstance" .. anchorOverridePartInCombat;
	end
	
	if (anchorOverride == "") and (cfg["enableAnchorOverride" .. anchorFrameName .. "DuringSkyriding"]) and (LibFroznFunctions.hasWoWFlavor.skyriding) then
		local bonusBarIndex = GetBonusBarIndex(); -- skyriding bonus bar is 11
		
		if (bonusBarIndex == 11) then
			anchorOverride = "DuringSkyriding";
		end
	end
	
	if (anchorOverride == "") and (cfg["enableAnchorOverride" .. anchorFrameName .. "InCombat"]) and (inCombat) then
		anchorOverride = "InCombat";
	end
	
	-- get anchor position
	local anchorType, anchorPoint = cfg[var .. "Type" .. anchorOverride], cfg[var .. "Point" .. anchorOverride];
	
	-- check for other anchor overrides
	if (not tip:IsForbidden()) then
		-- override anchor for (Guild & Community, addon "WIM") ChatFrame
		if (cfg.enableAnchorOverrideCF) and (anchorFrameName == "FrameTip") and (LibFroznFunctions:ExistsInTable(tip, { GameTooltip, BattlePetTooltip, PetJournalPrimaryAbilityTooltip })) then
			local tipOwner = ((tip == GameTooltip) and (tip:GetOwner())) or ((frameParams) and (frameParams.currentDisplayParams.defaultAnchoredParentFrame));
			
			if (tipOwner) and (LibFroznFunctions:IsFrameBackInFrameChain(tipOwner, {
						"^ChatFrame(%d+)",
						(LibFroznFunctions:IsAddOnFinishedLoading("Blizzard_Communities") and CommunitiesFrame.Chat.MessageFrame),
						"^WIM3_msgFrame(%d+)ScrollingMessageFrame"
					}, 1)) then
				
				return anchorFrameName, cfg.anchorOverrideCFType, cfg.anchorOverrideCFPoint;
			end
		end
	end
	
	return anchorFrameName, anchorType, anchorPoint;
end

-- HOOK: tip's OnUpdate for anchoring to mouse
function tt:AnchorTipToMouseOnUpdate(tip)
	-- check if insecure interaction with the tip is currently forbidden
	if (tip:IsForbidden()) then
		return;
	end
	
	tip:HookScript("OnUpdate", function(tip)
		-- anchor tip to mouse position
		tt:AnchorTipToMouse(tip);
	end);
end

-- HOOK: GameTooltip_SetDefaultAnchor() after set default anchor to tip
function tt:SetDefaultAnchorHook(tip, parent)
	-- get current display parameters
	local frameParams = TT_CacheForFrames[tip];
	
	if (not frameParams) then
		return;
	end
	
	local currentDisplayParams = frameParams.currentDisplayParams;
	
	-- set current display params for anchoring
	currentDisplayParams.defaultAnchored = true;
	currentDisplayParams.defaultAnchoredParentFrame = parent;
	
	-- get anchor position
	currentDisplayParams.anchorFrameName, currentDisplayParams.anchorType, currentDisplayParams.anchorPoint = self:GetAnchorPosition(tip);
	
	-- set anchor to tip
	self:SetAnchorToTip(tip);
end

-- set anchor to tips if need to be set
function tt:SetAnchorToTipsIfNeedToBeSet()
	-- set anchor to tip if needs to be set
	for tip, frameParams in pairs(TT_CacheForFrames) do
		self:SetAnchorToTipIfNeedsToBeSet(tip);
	end
end

-- set anchor to tip if needs to be set
function tt:SetAnchorToTipIfNeedsToBeSet(tip)
	-- get current display parameters
	local frameParams = TT_CacheForFrames[tip];
	
	if (not frameParams) then
		return;
	end
	
	local currentDisplayParams = frameParams.currentDisplayParams;
	
	-- current display parameters aren't set
	if (not currentDisplayParams.isSet) and (not currentDisplayParams.isSetTemporarily) then
		return;
	end
	
	-- set anchor to tip not possible
	local tipParams = frameParams.config;
	
	if (not cfg.enableAnchor) or (not tipParams.applyAnchor) then
		return;
	end
	
	-- tip not default anchored
	if (not currentDisplayParams.defaultAnchored) then
		return;
	end
	
	-- get anchor position
	currentDisplayParams.anchorFrameName, currentDisplayParams.anchorType, currentDisplayParams.anchorPoint = self:GetAnchorPosition(tip);
	
	-- set anchor to tip
	self:SetAnchorToTip(tip);
end

-- reset current display params for anchoring
function tt:ResetCurrentDisplayParamsForAnchoring(tip, resetOnlyDefaultAnchor)
	-- get current display parameters
	local frameParams = TT_CacheForFrames[tip];
	
	if (not frameParams) then
		return;
	end
	
	local currentDisplayParams = frameParams.currentDisplayParams;
	
	-- reset current display params for anchoring
	if (tip:IsForbidden()) or (not tip:IsShown()) then -- reset "tip is default anchored" only if tip isn't visible any more
		currentDisplayParams.defaultAnchored = false;
		currentDisplayParams.defaultAnchoredParentFrame = nil;
	end
	
	if (resetOnlyDefaultAnchor) then
		return;
	end
	
	currentDisplayParams.anchorFrameName, currentDisplayParams.anchorType, currentDisplayParams.anchorPoint = nil, nil, nil;
end

-- register for group events
LibFroznFunctions:RegisterForGroupEvents(MOD_NAME, {
	OnTipAddedToCache = function(self, TT_CacheForFrames, tip)
		-- get tip parameters
		local frameParams = TT_CacheForFrames[tip];
		
		if (not frameParams) then
			return;
		end
		
		local tipParams = frameParams.config;
		
		-- set anchor to tip not possible
		if (not tipParams.applyAnchor) then
			return;
		end
		
		-- no hooking allowed
		if (tipParams.noHooks) then
			return;
		end
		
		-- HOOK: tip's SetOwner to reset current display params for anchoring
		LibFroznFunctions:CallFunctionDelayed(tipParams.waitSecondsForHooking, function()
			-- check if insecure interaction with the tip is currently forbidden
			if (tip:IsForbidden()) then
				return;
			end
			
			if (tip:GetObjectType() == "GameTooltip") then
				hooksecurefunc(tip, "SetOwner", function(tip, owner, anchor, xOffset, yOffset)
					tt:ResetCurrentDisplayParamsForAnchoring(tip, true);
				end);
			end
		end);
		
		-- HOOK: tip's OnUpdate for anchoring to mouse
		LibFroznFunctions:CallFunctionDelayed(tipParams.waitSecondsForHooking, function()
			tt:AnchorTipToMouseOnUpdate(tip);
		end);
	end,
	OnTipSetCurrentDisplayParams = function(self, TT_CacheForFrames, tip, currentDisplayParams, tipContent)
		-- set current display params for anchoring
		currentDisplayParams.defaultAnchored = not not currentDisplayParams.defaultAnchored;
		
		currentDisplayParams.anchorFrameName, currentDisplayParams.anchorType, currentDisplayParams.anchorPoint = tt:GetAnchorPosition(tip);
	end,
	OnTipSetStyling = function(self, TT_CacheForFrames, tip, currentDisplayParams, tipContent)
		-- set anchor to tip
		tt:SetAnchorToTip(tip);
	end,
	OnTipPostSetStyling = function(self, TT_CacheForFrames, tip, currentDisplayParams, tipContent)
		-- refreshing anchoring of shopping tooltips after re-anchoring of tip to prevent overlapping tooltips,
		-- because after GameTooltip_ShowCompareItem() (see hook for TooltipComparisonManager:AnchorShoppingTooltips() or GameTooltip_AnchorComparisonTooltips() below) has been called within TooltipDataRules.FinalizeItemTooltip(), the tooltip isn't finished yet, e.g. if hovering over monthly activities reward button.
		-- so the tooltip may change in size after finishing the remaining TooltipDataHandler calls/callbacks and TipTac's own OnTipSetStyling to finalize the tooltip.
		tt:RefreshAnchorShoppingTooltips(tip);
	end,
	OnApplyTipAppearanceAndHooking = function(self, TT_CacheForFrames, configDb, cfg, TT_ExtendedConfig)
		-- HOOK: GameTooltip_SetDefaultAnchor() for re-anchoring
		hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tip, parent)
			tt:SetDefaultAnchorHook(tip, parent);
		end);

		-- HOOK: GameTooltip:SetBagItem() for re-anchoring bag/bank item tooltips.
		-- blizzard doesn't call GameTooltip_SetDefaultAnchor() for these (the container item buttons call GameTooltip:SetOwner() with a fixed anchor, e.g. "ANCHOR_LEFT", directly instead),
		-- so without this hook, the tip's anchor type/point (e.g. "Frame Tip") would never be applied to bag/bank item tooltips.
		hooksecurefunc(GameTooltip, "SetBagItem", function(tip)
			tt:SetDefaultAnchorHook(tip, tip:GetOwner());

			-- refresh anchoring of shopping tooltips (e.g. "Equipped" comparison tooltip) after re-anchoring of tip to prevent them from staying at the tip's old (blizzard default) position
			tt:RefreshAnchorShoppingTooltips(tip);
		end);

		-- HOOK: TooltipComparisonManager:AnchorShoppingTooltips() or GameTooltip_AnchorComparisonTooltips() (called within GameTooltip_ShowCompareItem()) to refresh anchoring of shopping tooltips after re-anchoring of tip to prevent overlapping tooltips
		if (GameTooltip_AnchorComparisonTooltips) then -- before df 10.0.2
			hooksecurefunc("GameTooltip_AnchorComparisonTooltips", function(self, anchorFrame, shoppingTooltip1, shoppingTooltip2, primaryItemShown, secondaryItemShown)
				-- we have to call this again because :SetOwner() clears the tooltip
				shoppingTooltip1:SetCompareItem(shoppingTooltip2, self);
				
				-- refresh anchoring of shopping tooltips after re-anchoring of tip to prevent overlapping tooltips
				tt:RefreshAnchorShoppingTooltips(self);
			end);
		else -- since df 10.0.2
			hooksecurefunc(TooltipComparisonManager, "AnchorShoppingTooltips", function(self, primaryShown, secondaryShown)
				local tip = self.tooltip;

				-- refresh anchoring of shopping tooltips after re-anchoring of tip to prevent overlapping tooltips
				tt:RefreshAnchorShoppingTooltips(tip);
			end);
		end
	end,
	OnPlayerRegenEnabled = function(self, TT_CacheForFrames)
		-- set anchor to tips if need to be set
		tt:SetAnchorToTipsIfNeedToBeSet();
	end,
	OnPlayerRegenDisabled = function(self, TT_CacheForFrames)
		-- set anchor to tips if need to be set
		tt:SetAnchorToTipsIfNeedToBeSet();
	end,
	OnUpdateBonusActionbar = function(self, TT_CacheForFrames)
		-- set anchor to tips if need to be set
		tt:SetAnchorToTipsIfNeedToBeSet();
	end,
	OnTipResetCurrentDisplayParams = function(self, TT_CacheForFrames, tip, currentDisplayParams)
		-- reset current display params for anchoring
		tt:ResetCurrentDisplayParamsForAnchoring(tip);
	end
}, MOD_NAME .. " - Anchoring");

----------------------------------------------------------------------------------------------------
--                                          Unit Record                                           --
----------------------------------------------------------------------------------------------------

--[[
	GameTooltip construction call order for unit tips
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	- GameTooltip_SetDefaultAnchor()    -- called e.g. for units and mailboxes using the default anchor. won't initially be called for buffs or vendor signs.
	- GameTooltip:OnTooltipSetUnit()    -- GetUnit() aka TooltipUtil.GetDisplayedUnit() becomes valid here
	- GameTooltip:Show()                -- will resize the tip
	- GameTooltip:OnShow()              -- event triggered in response to the Show() function. won't be called if tooltip of world unit isn't faded out yet and moving mouse over it again or someone else.
	- GameTooltip:OnTooltipCleared()    -- tooltip has been cleared and is ready to show new information. doesn't mean it's hidden.
--]]

-- set unit record from tip
function tt:SetUnitRecordFromTip(tip)
	-- get current display parameters
	local frameParams = TT_CacheForFrames[tip];
	
	if (not frameParams) then
		return;
	end
	
	local currentDisplayParams = frameParams.currentDisplayParams;
	
	-- set unit record from tip
	local _, unitID = LibFroznFunctions:GetUnitFromTooltip(tip);
	
	-- concated unit tokens such as "targettarget" cannot be returned as the unit id by GameTooltip:GetUnit() aka TooltipUtil.GetDisplayedUnit(GameTooltip),
	-- and it will return as "mouseover", but the "mouseover" unit id is still invalid at this point for those unitframes!
	-- to overcome this problem, we look if the mouse is over a unitframe, and if that unitframe has a unit attribute set?
	if (LibFroznFunctions:IsSecretValue(unitID)) or (not unitID) then
		local mouseFocus = LibFroznFunctions:GetMouseFocus();
		
		unitID = mouseFocus and mouseFocus.GetAttribute and mouseFocus:GetAttribute("unit");
	end
	
	-- a mage's mirror images sometimes doesn't return a unit id, this would fix it.
	if ((LibFroznFunctions:IsSecretValue(unitID)) or (not unitID)) and (UnitExists("mouseover")) and (not UnitIsUnit("mouseover", "player")) then
		unitID = "mouseover";
	end
	
	-- check if unit id is secret
	if (LibFroznFunctions:IsSecretValue(unitID)) then
		currentDisplayParams.unitRecord = LFF_UNIT_RECORD.SecretValue;
		return;
	end
	
	-- sometimes when you move your mouse quickly over units in the worldframe, we can get here without a unit id.
	if (not unitID) then
		currentDisplayParams.unitRecord = nil;
		return;
	end
	
	-- check if text in first line is secret, e.g. needed when hovering over party pet unit frames.
	local tipLine = LibFroznFunctions:GetLineFromGameTooltip(tip, 1);
	
	if (tipLine) and (LibFroznFunctions:IsSecretValue(tipLine:GetText())) then
		currentDisplayParams.unitRecord = LFF_UNIT_RECORD.SecretValue;
		return;
	end
	
	-- a "mouseover" unitID is better to have as we can then safely say the tip should no longer show when it becomes invalid. Harder to say with a "party2" unit.
	-- this also helps fix the problem that "mouseover" units aren't valid for group members out of range, a bug that has been in WoW since about 3.0.2.
	local mouseOverUnit = UnitIsUnit(unitID, "mouseover");
	
	if (not LibFroznFunctions:IsSecretValue(mouseOverUnit)) and (mouseOverUnit) then
		unitID = "mouseover";
	end
	
	-- set unit record
	currentDisplayParams.unitRecord = LibFroznFunctions:GetUnitRecordFromCache(unitID);
end

-- register for group events
LibFroznFunctions:RegisterForGroupEvents(MOD_NAME, {
	OnTipSetCurrentDisplayParams = function(self, TT_CacheForFrames, tip, currentDisplayParams, tipContent)
		-- set unit record for unit tips (used e.g. by anchoring, custom unit fadeout and hiding tips of own pets/companions)
		if (tipContent == TT_TIP_CONTENT.unit) then
			tt:SetUnitRecordFromTip(tip);
		else
			currentDisplayParams.unitRecord = nil;
		end
	end,
	OnTipResetCurrentDisplayParams = function(self, TT_CacheForFrames, tip, currentDisplayParams)
		-- reset unit record
		currentDisplayParams.unitRecord = nil;
	end
}, MOD_NAME .. " - Unit Record");

----------------------------------------------------------------------------------------------------
--                                      Custom Unit Fadeout                                       --
----------------------------------------------------------------------------------------------------

-- register for group events
LibFroznFunctions:RegisterForGroupEvents(MOD_NAME, {
	OnTipAddedToCache = function(self, TT_CacheForFrames, tip)
		-- check if insecure interaction with the tip is currently forbidden
		if (tip:IsForbidden()) then
			return;
		end
		
		-- only for GameTooltip tips
		if (tip:GetObjectType() ~= "GameTooltip") then
			return;
		end
		
		-- get tip parameters
		local frameParams = TT_CacheForFrames[tip];
		
		if (not frameParams) then
			return;
		end
		
		local tipParams = frameParams.config;
		
		-- no hooking allowed
		if (tipParams.noHooks) then
			return;
		end
		
		-- HOOK: tip's FadeOut() and OnUpdate for custom unit fadeout
		LibFroznFunctions:CallFunctionDelayed(tipParams.waitSecondsForHooking, function()
			hooksecurefunc(tip, "FadeOut", function(tip)
				-- no override of default unit fadeout
				if (not cfg.overrideFade) then
					return;
				end
				
				-- get current display parameters
				local frameParams = TT_CacheForFrames[tip];
				
				if (not frameParams) then
					return;
				end
				
				local currentDisplayParams = frameParams.currentDisplayParams;
				
				-- no unit record
				local unitRecord = currentDisplayParams.unitRecord;
				
				if (not unitRecord) then
					return;
				end
				
				-- instant unit fadeout
				if (cfg.preFadeTime == 0) and (cfg.fadeTime == 0) then
					tip:Hide();
					return;
				end
				
				-- enable custom unit fadeout
				currentDisplayParams.ignoreNextSetCurrentDisplayParams = true;
				tip:Show(); -- cancels default unit fadeout
				currentDisplayParams.timestampStartCustomUnitFadeout = GetTime();
			end);
			
			tip:HookScript("OnUpdate", function(tip)
				-- get current display parameters
				local frameParams = TT_CacheForFrames[tip];
				
				if (not frameParams) then
					return;
				end
				
				local currentDisplayParams = frameParams.currentDisplayParams;
				
				-- no custom unit fadeout
				local timestampStartCustomUnitFadeout = currentDisplayParams.timestampStartCustomUnitFadeout;
				
				if (not timestampStartCustomUnitFadeout) then
					-- no override of default unit fadeout
					if (not cfg.overrideFade) then
						return;
					end
					
					-- consider if FadeOut() for worldframe unit tips will not be called
					local unitRecord = currentDisplayParams.unitRecord;
					
					if (LibFroznFunctions.hasWoWFlavor.GameTooltipFadeOutNotBeCalledForWorldFrameUnitTips) and
							(unitRecord) and (not UnitExists(unitRecord.id)) then
						
						tip:FadeOut();
					end
					
					return;
				end
				
				-- pre fade time
				local fadingTime = GetTime() - timestampStartCustomUnitFadeout;
				
				if (fadingTime <= cfg.preFadeTime) then
					return;
				end
				
				-- time for custom unit fadeout expired
				if (fadingTime >= cfg.preFadeTime + cfg.fadeTime) then
					tip:Hide();
					return;
				end
				
				-- set tip's alpha during fading time
				tip:SetAlpha(1 - (fadingTime - cfg.preFadeTime) / cfg.fadeTime);
			end);
		end);
	end,
	OnTipSetCurrentDisplayParams = function(self, TT_CacheForFrames, tip, currentDisplayParams, tipContent)
		-- set current display params for custom unit fadeout
		currentDisplayParams.timestampStartCustomUnitFadeout = nil;
	end,
	OnTipResetCurrentDisplayParams = function(self, TT_CacheForFrames, tip, currentDisplayParams)
		-- reset current display params for custom unit fadeout
		currentDisplayParams.timestampStartCustomUnitFadeout = nil;
	end
}, MOD_NAME .. " - Custom Unit Fadeout");

----------------------------------------------------------------------------------------------------
--                                   Hide World Tips Instantly                                    --
----------------------------------------------------------------------------------------------------

-- hide world tips instantly
function tt:HideWorldTipsInstantly()
	if (cfg.hideWorldTips) and (GameTooltip:IsShown()) and (GameTooltip:IsOwned(UIParent)) and (not TT_CacheForFrames[GameTooltip].currentDisplayParams.unitRecord) then
		-- restoring the text of the first line is a workaround so that gatherer addons can get the name of nodes
		local oldGameTooltipTextLeft1Text = GameTooltipTextLeft1:GetText();
		
		GameTooltip:Hide();
		
		GameTooltipTextLeft1:SetText(oldGameTooltipTextLeft1Text);
	end
end

-- EVENT: cursor changed
function tt:CURSOR_CHANGED(event)
	-- hide world tips instantly
	self:HideWorldTipsInstantly();
end

-- register for group events
local eventsForHideWorldTipsHooked = false;

LibFroznFunctions:RegisterForGroupEvents(MOD_NAME, {
	OnApplyConfig = function(self, TT_CacheForFrames, configDb, cfg, TT_ExtendedConfig)
		-- register/unregister cursor changed event
		if (cfg.hideWorldTips) then
			if (not eventsForHideWorldTipsHooked) then
				tt:RegisterEvent("CURSOR_CHANGED");
				eventsForHideWorldTipsHooked = true;
			end
		else
			if (eventsForHideWorldTipsHooked) then
				tt:UnregisterEvent("CURSOR_CHANGED");
				eventsForHideWorldTipsHooked = false;
			end
		end
	end,
	OnTipAddedToCache = function(self, TT_CacheForFrames, tip)
		-- check if insecure interaction with the tip is currently forbidden
		if (tip:IsForbidden()) then
			return;
		end
		
		-- only for GameTooltip tips
		if (tip:GetObjectType() ~= "GameTooltip") then
			return;
		end
		
		-- get tip parameters
		local frameParams = TT_CacheForFrames[tip];
		
		if (not frameParams) then
			return;
		end
		
		local tipParams = frameParams.config;
		
		-- no hooking allowed
		if (tipParams.noHooks) then
			return;
		end
		
		-- HOOK: tip's FadeOut() to hide world tips instantly
		LibFroznFunctions:CallFunctionDelayed(tipParams.waitSecondsForHooking, function()
			hooksecurefunc(tip, "FadeOut", function(tip)
				-- get current display parameters
				local frameParams = TT_CacheForFrames[tip];
				
				if (not frameParams) then
					return;
				end
				
				local currentDisplayParams = frameParams.currentDisplayParams;
				
				-- unit record exists
				local unitRecord = currentDisplayParams.unitRecord;
				
				if (unitRecord) then
					return;
				end
				
				-- hide world tips instantly
				tt:HideWorldTipsInstantly();
			end);
		end);
	end
}, MOD_NAME .. " - Hide World Tips Instantly");

----------------------------------------------------------------------------------------------------
--                                  Own Pet/Minion Detection                                      --
----------------------------------------------------------------------------------------------------

-- UnitIsOwnedByUnit() isn't available on this client (neither as a plain global nor under C_PlayerInfo, confirmed nil on the
-- running client), and tracking summoned guids ourselves via COMBAT_LOG_EVENT_UNFILTERED got TipTac blocked from a protected
-- action immediately on load, so none of this keeps any state at all: it only looks at whatever's live on the tip you're
-- currently hovering.
--
-- anything without its own unit token (a hunter's 2nd Beast Mastery pet, a summoned non-combat companion, etc.) is recognized
-- from blizzard's own tooltip text, which names the owner on one of the tip's first few lines (e.g. "Diramara's Pet" for a
-- combat pet/minion, "Diramara's Companion" for a non-combat companion pet).
local function DoesTooltipLineNamePlayerAs(tip, suffix)
	if (not tip) or (tip:IsForbidden()) then
		return false;
	end

	local playerName = UnitName("player");

	if (not playerName) then
		return false;
	end

	local search = playerName .. suffix;

	for lineIndex = 2, 4 do
		local line = LibFroznFunctions:GetLineFromGameTooltip(tip, lineIndex);
		local text = line and line:GetText();

		if (text) and (not LibFroznFunctions:IsSecretValue(text)) and (text:find(search, 1, true)) then
			return true;
		end
	end

	return false;
end

-- check if a unit is one of the player's own combat pets/minions (e.g. hunter pets, warlock demons, death knight ghouls).
-- the player's single primary combat pet has its own unit token ("pet") and is checked directly; anything else falls back to the tooltip text.
function tt:IsUnitMyPetOrMinion(unitID, tip)
	if (UnitIsUnit(unitID, "pet")) then
		return true;
	end

	return DoesTooltipLineNamePlayerAs(tip, "'s Pet");
end

-- check if a unit is one of the player's own non-combat companion pets (vanity pets)
function tt:IsUnitMyCompanion(unitID, tip)
	return DoesTooltipLineNamePlayerAs(tip, "'s Companion");
end

----------------------------------------------------------------------------------------------------
--                                           Hide Tips                                            --
----------------------------------------------------------------------------------------------------

-- register for group events
LibFroznFunctions:RegisterForGroupEvents(MOD_NAME, {
	OnApplyTipAppearanceAndHooking = function(self, TT_CacheForFrames, configDb, cfg, TT_ExtendedConfig)
		-- HOOK: GameTooltip_ShowCompareItem() to hide shopping tooltips
		hooksecurefunc("GameTooltip_ShowCompareItem", function(self, anchorFrame)
			local tip = (self or GameTooltip);
			
			-- get current display parameters
			local frameParams = TT_CacheForFrames[tip];
			
			if (not frameParams) then
				return;
			end
			
			local currentDisplayParams = frameParams.currentDisplayParams;
			
			-- hide shopping tips
			if (currentDisplayParams.hideShoppingTips) then
				tt:HideShoppingTips(tip);
			end
		end);
	end,
	OnTipSetHidden = function(self, TT_CacheForFrames, tip, currentDisplayParams, tipContent)
		-- determine if tip comes from experience bar
		local isTipFromExpBar = false;
		
		if (tip == GameTooltip) then
			if (LibFroznFunctions.hasWoWFlavor.experienceBarDockedToInterfaceBar) then
				if (not tip:IsForbidden()) then
					local tipOwner = tip:GetOwner();
					
					if (LibFroznFunctions:IsFrameBackInFrameChain(tipOwner, { LibFroznFunctions.hasWoWFlavor.experienceBarFrame }, LibFroznFunctions.hasWoWFlavor.experienceBarMaxLevelBack)) then
						isTipFromExpBar = true;
					end
				end
			else
				local mouseFocus = LibFroznFunctions:GetMouseFocus();
				
				if (mouseFocus) and (not mouseFocus:IsForbidden()) and (LibFroznFunctions:IsFrameBackInFrameChain(mouseFocus, { LibFroznFunctions.hasWoWFlavor.experienceBarFrame }, 2)) then
					isTipFromExpBar = true;
				end
			end
		end
		
		-- unhandled tip content
		if (not LibFroznFunctions:ExistsInTable(tipContent, { TT_TIP_CONTENT.unit, TT_TIP_CONTENT.aura, TT_TIP_CONTENT.spell, TT_TIP_CONTENT.item, TT_TIP_CONTENT.action })) and (not isTipFromExpBar) then
			return;
		end
		
		-- modifier key set and pressed to still show hidden tips
		if (cfg.showHiddenModifierKey == "shift") and (IsShiftKeyDown()) then
			return;
		end
		if (cfg.showHiddenModifierKey == "ctrl") and (IsControlKeyDown()) then
			return;
		end
		if (cfg.showHiddenModifierKey == "alt") and (IsAltKeyDown()) then
			return;
		end

		-- hide tips for own pets/minions (e.g. hunter pets, warlock demons, death knight ghouls, and other combat minions owned/summoned by the player)
		if (cfg.hideTipsForOwnPets) and (tipContent == TT_TIP_CONTENT.unit) then
			local unitRecord = currentDisplayParams.unitRecord;

			if (unitRecord) and (unitRecord ~= LFF_UNIT_RECORD.SecretValue) and (UnitExists(unitRecord.id)) and (tt:IsUnitMyPetOrMinion(unitRecord.id, tip)) then
				currentDisplayParams.hideTip = true;
				return;
			end
		end

		-- hide tips for own non-combat companion pets (vanity pets)
		if (cfg.hideTipsForOwnCompanions) and (tipContent == TT_TIP_CONTENT.unit) then
			local unitRecord = currentDisplayParams.unitRecord;

			if (unitRecord) and (unitRecord ~= LFF_UNIT_RECORD.SecretValue) and (UnitExists(unitRecord.id)) and (tt:IsUnitMyCompanion(unitRecord.id, tip)) then
				currentDisplayParams.hideTip = true;
				return;
			end
		end

		-- consider hiding tips during challenge mode, instance, during skyriding or in combat
		local hidingTip = "";
		
		if (LibFroznFunctions.hasWoWFlavor.challengeMode) and (C_ChallengeMode.IsChallengeModeActive()) then
			local difficultyID = select(3, GetInstanceInfo());
			
			if (difficultyID) then
				local isChallengeMode = select(4, GetDifficultyInfo(difficultyID));
				
				if (isChallengeMode) then
					local timerID = GetWorldElapsedTimers();
					local _, elapsedTime, timerType = GetWorldElapsedTime(timerID);
					
					if (timerType == LFF_WORLD_ELAPSED_TIMER_TYPES.ChallengeMode) and (elapsedTime >= 0) then
						hidingTip = "DuringChallengeMode" .. (UnitAffectingCombat("player") and "InCombat" or "");
					end
				end
			end
		end
		
		if (hidingTip == "") and (IsInInstance()) then
			hidingTip = "DuringInstance" .. (UnitAffectingCombat("player") and "InCombat" or "");
		end
		
		if (hidingTip == "") and (LibFroznFunctions.hasWoWFlavor.skyriding) then
			local bonusBarIndex = GetBonusBarIndex(); -- skyriding bonus bar is 11
			
			if (bonusBarIndex == 11) then
				hidingTip = "DuringSkyriding";
			end
		end
		
		if (hidingTip == "") and (UnitAffectingCombat("player")) then
			hidingTip = "InCombat";
		end
		
		-- check if tooltip needs to be hidden
		if (currentDisplayParams.anchorFrameName) then
			if (cfg["hideTips" .. hidingTip .. currentDisplayParams.anchorFrameName .. "s"]) then
				currentDisplayParams.hideTip = true;
				return;
			end
		end
		
		local tipContentName = ((tipContent == TT_TIP_CONTENT.unit) and "Unit") or (((tipContent == TT_TIP_CONTENT.aura) or (tipContent == TT_TIP_CONTENT.spell)) and "Spell") or ((tipContent == TT_TIP_CONTENT.item) and "Item") or ((tipContent == TT_TIP_CONTENT.action) and "Action") or (isTipFromExpBar and "ExpBar");
		
		if (cfg["hideTips" .. hidingTip .. tipContentName .. "Tips"]) then
			currentDisplayParams.hideTip = true;
			return;
		end
		
		-- hide other tips
		if (tip == GameTooltip) then
			-- hide shopping tips of dungeon/raid/set items in adventure guide
			if (cfg.hideTipsEJDungeonRaidSetItemsSTT) and (not currentDisplayParams.hideShoppingTips) then
				local isAddOnBlizzard_EncounterJournalLoaded = LibFroznFunctions:IsAddOnFinishedLoading("Blizzard_EncounterJournal");
				
				if (isAddOnBlizzard_EncounterJournalLoaded) then
					local tipOwner = tip:GetOwner();
					
					if (tipOwner) and (LibFroznFunctions:IsFrameBackInFrameChain(tipOwner, {
								EncounterJournalEncounterFrameInfo.LootContainer.ScrollBox.ScrollTarget,
								(EncounterJournal.LootJournalItems and EncounterJournal.LootJournalItems.ItemSetsFrame.ScrollBox.ScrollTarget)
							}, 3)) then
						
						currentDisplayParams.hideShoppingTips = true;
					end
				end
			end
		end
	end
}, MOD_NAME .. " - Hide Tips");

