# TipTac (Custom)

A stripped-down personal fork of [TipTac Reborn](https://github.com/frozn/TipTac) that keeps only three things:

- **Anchoring**: where tooltips appear
- **Fading**: how unit tooltips fade out
- **Hiding**: when tooltips are hidden

Everything else in TipTac (unit tip styling, health/power bars, auras, icons, colors, fonts, backdrop, scaling,
chat-link hover tips, layouts/profiles, minimap icon, ...) has been removed. Tooltips keep the default Blizzard look.

Retail only (Interface 120100). The addon folders keep the original names, `TipTac` and `TipTacOptions`, so this
**replaces** the upstream TipTac (don't install both) and your existing `TipTac_Config` settings carry over.

## Features

**Anchors** (`/tip` → Anchors)
- Normal, Mouse or Parent anchor for each of: World Unit, World Tip, Frame Unit, Frame Tip.
- Separate mouse-anchor X/Y offset per anchor type.
- Anchor overrides while in combat, in an instance, in Mythic+, or skyriding.
- Bag/bank item tooltips follow the Frame Tip anchor, and the "Equipped" comparison tooltips stay aligned with them.
- Movable anchor frame for the Normal anchor (`/tip anchor`).

**Fading** (`/tip` → Fading)
- Override the default unit tooltip fade with your own pre-fade and fade-out times, or hide instantly.
- Optionally hide world-frame tips instantly.

**Hiding** (`/tip` → Hiding)
- Hide tooltips by anchor type (world/frame, unit/tip) or content (unit, spell, item, action bar, exp bar),
  each optionally only in combat, in an instance, in Mythic+, or while skyriding.
- Hide tooltips for your own combat pets/minions, and separately for your own companion pets.
- Hold a modifier key (Shift/Ctrl/Alt) to still show hidden tips. It has to be held when you start hovering:
  pressing it while already hovering a hidden tip does nothing until you re-hover.

Slash commands: `/tip` (options), `/tip anchor` (show/hide the anchor frame), `/tip reset` (reset all settings).

## Install

Download `TipTac-Custom-<version>.zip` from the [latest release](../../releases/latest) and extract the `TipTac`
and `TipTacOptions` folders into `World of Warcraft\_retail_\Interface\AddOns\`.

To update from the command line (works for a private repo, needs `gh auth login` once):

```powershell
.\scripts\update-from-release.ps1
```

An addon manager that installs from GitHub releases (e.g. WowUp: *Install from URL* with this repo's URL) can also
install and update it, **but only if the repository is public**. Note that the CurseForge project id has been
removed from the TOCs on purpose, so managers won't replace this with upstream TipTac.

## Developing / releasing

- Test local changes: `.\scripts\install-local.ps1` copies the two addon folders into `AddOns`, then `/reload`.
- After a WoW patch: bump `## Interface:` in both `.toc` files.
- Release: `git tag v26.09.24 && git push --tags`. The [Release workflow](.github/workflows/release.yml) stamps the
  version into the TOCs, builds the zip (with a `release.json` so addon managers see it's a retail build), and
  publishes the GitHub release.

## Credits and license

TipTac was created by **Aezay** and continued as **TipTac Reborn** by **Frozn45**. This fork removes features and adds
the per-anchor mouse offsets, bag/bank item anchoring, comparison-tooltip alignment fix, own pet/companion hiding
and the options trimmed to the three pages above.

Licensed under the **GNU General Public License v3.0**, the same license as the upstream repository
([`LICENSE`](LICENSE), also included in each addon folder). Bundled libraries (Ace3, LibStub, CallbackHandler,
LibFroznFunctions) keep their own licenses.
