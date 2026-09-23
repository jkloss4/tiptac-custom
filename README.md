# tiptac-custom

Personal modifications to [TipTac Reborn](https://www.curseforge.com/wow/addons/tiptac-reborn) (retail, Interface 120100, TipTac version 26.09.03).

This repo holds only the files I changed, not the whole addon. Copy them over the matching files in
`World of Warcraft\_retail_\Interface\AddOns\` (keeping the `TipTac` / `TipTacOptions` folder structure).
An addon update will overwrite these files, so re-apply them afterwards.

## Changes

**Per-anchor-type mouse offset.** The single global "Mouse Anchor X/Y Offset" is replaced by a separate X/Y offset for each
of World Unit, World Tip, Frame Unit and Frame Tip. Each pair of sliders sits under that anchor type's Type/Point dropdowns.

| File | Change |
| --- | --- |
| `TipTac/ttCore.lua` | Defaults `mouseOffset{WorldUnit,WorldTip,FrameUnit,FrameTip}{X,Y}` replace `mouseOffsetX/Y`; `AnchorTipToMouse` looks up the offset by the current anchor frame name. |
| `TipTacOptions/ttOptions.lua` | Eight sliders in the Anchors tab, built by `GetMouseOffsetOption`; the old "Mouse Settings" section is removed. |
| `TipTacOptions/Libs/AzOptionsFactory.lua` | Slider option `fontSizeDelta` shrinks the slider label font. The original font is stored per widget and reapplied on every `Init`, because slider widgets are reused. |

The old global `mouseOffsetX/Y` saved values are no longer read, so previously set offsets reset to 0.

**Frame Tip anchor now applies to bag/bank item tooltips, with correct comparison-tooltip alignment.** Blizzard's container item
buttons (bags, bank, reagent bank) never call `GameTooltip_SetDefaultAnchor()` — they set a fixed `GameTooltip:SetOwner(self,
"ANCHOR_LEFT")` position directly — so the Frame Tip anchor type/point previously had no effect while hovering an item in your
bags. It now does. This also fixes a related, more general bug: whenever a comparison ("Equipped"/shopping) tooltip is shown
alongside a tooltip using a custom (non-mouse) anchor, the comparison tooltip used to stay anchored near the tip's original
owner/position instead of following the tip to its new location, and even once pointed at the right frame, a builtin 10px gap
(sized for sitting next to a small button) showed up as a visible seam between the two tooltips. Both are now corrected.

| File | Change |
| --- | --- |
| `TipTac/ttCore.lua` | New `tt:RefreshAnchorShoppingTooltips(tip)` wrapper (replaces direct calls to `LibFroznFunctions:RefreshAnchorShoppingTooltips`) forces `TooltipComparisonManager.anchorFrame` to the tip itself instead of Blizzard's default (the tip's owner), and cancels the resulting 10px offset via `AdjustPointsOffset` so tooltip tops sit flush. New `hooksecurefunc(GameTooltip, "SetBagItem", ...)` re-anchors bag/bank item tooltips the same way the default-anchor hook does for other tooltips. |

## Usage note

With "Enable TipTac unit tip appearance" turned off, the default tooltip look is kept and only the anchoring applies.
