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

## Usage note

With "Enable TipTac unit tip appearance" turned off, the default tooltip look is kept and only the anchoring applies.
