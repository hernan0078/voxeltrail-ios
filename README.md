# VoxelTrail for iOS

A native iOS build of the [Gen 1 recomp engine](https://github.com/bryanthaboi/gen1recomp) — the
Generation 1 Pokémon games, reimplemented in Lua and running on LÖVE, on an
iPhone or iPad. Touch controls, save management, and an optional 3D voxel
renderer.

**You need your own ROM.** None is included here and none will be. The app
reads a Game Boy ROM you already own and extracts its data on first launch.

---

## Install

The IPA is **unsigned**, which is what sideloading tools expect — they sign it
with your own Apple ID on your own device.

1. Install [SideStore](https://sidestore.io) or [AltStore](https://altstore.io)
   and finish its setup.
2. Download `VoxelTrail-0.1.0.ipa` from the
   [latest release](../../releases/latest).
3. Open it in SideStore/AltStore and let it install.
4. On first launch, iOS may ask you to trust the developer:
   **Settings → General → VPN & Device Management**.

Free Apple IDs let a sideloaded app run for 7 days before it needs refreshing
in the sideloading app. That's an Apple limit, not this app's.

Requires iOS 16 or later.

## Load your ROM

1. Open VoxelTrail and tap **Import ROM**.
2. Pick your `.gb` / `.gbc` file.
3. **Force-quit and reopen the app.** See *Known issues* — this step is
   currently required.
4. Extraction runs once and takes a few seconds; after that it boots straight
   to the game.

Red, Blue, and Yellow are supported. Files can also be dropped into the app's
folder in the Files app instead of using the picker.

## Controls

The on-screen pad is the d-pad, A/B, and START/SELECT. A connected MFi or
Bluetooth controller is picked up automatically and hides the pad.

**START → OPTION** reaches the settings, including:

| Row | What it does |
|-----|--------------|
| `ZOOM` | `FIT`, then `NEAR 1…` to magnify or `WIDE 1…` to pull back |
| `3D WORLD` | `OFF`, `FULL 3D`, `SLIGHT`, `TILTED`, `STEEP`, `TABLE TOP` — only present once the 3D mod is installed |

`FULL 3D` is a preset: it sets the other rows for you, so choose your angle
first and adjust `ZOOM` afterwards.

## Optional: the 3D voxel mod

The 3D renderer is a separate, third-party mod by DramaticShape. It is **not
bundled here** — it carries no license, so this repository can't redistribute
it. Get it from the author:

> ### 📦 [github.com/DramaticShape/DramaticShapeVoxelMod](https://github.com/DramaticShape/DramaticShapeVoxelMod)
> **[→ Download the latest release](https://github.com/DramaticShape/DramaticShapeVoxelMod/releases/latest)**

⚠️ **Read this before you install it on an iPhone or iPad.** The mod's current
release renders nothing on a high-DPI screen — which every iPhone and iPad
has. It doesn't pin the DPI scale on its own render targets, so 3D mode turns
on and silently draws an empty frame. It isn't broken on your end and there is
no setting that fixes it.

The fix is submitted to the author as
[PR #40](https://github.com/DramaticShape/DramaticShapeVoxelMod/pull/40) and
hasn't been merged yet. Until it is, you need a computer once, to apply it.

### With a computer (works today)

On a Mac or Linux machine:

```bash
git clone https://github.com/hernan0078/voxeltrail-ios.git
cd voxeltrail-ios
./add-mod.sh
```

It writes `DRAMATIC_SHAPE-ios.zip`. Get that onto your device however you like
— AirDrop, iCloud Drive, emailing it to yourself — then install it with either
route below.

The script downloads the mod from the author's own release and applies only
the lines PR #40 adds, which are our contribution rather than the author's
work. Nothing of the mod is redistributed here. It also checks first: if a
later release already contains the fix, it says so and stops.

### From the phone alone (once PR #40 merges)

No computer needed — the app can take a `.zip` straight from Files:

1. Download the mod's release zip in Safari; it lands in **Files → Downloads**.
2. In VoxelTrail, open the **MODS** tab and choose the mod import button.
3. Pick the zip. Or skip the picker entirely: in Files, move the zip into the
   **VoxelTrail** folder under *On My iPhone*, and the app picks it up on next
   launch.
4. Force-quit and reopen. (Required either way — see *Known issues*.)

Both routes work right now, mechanically. What you get **today** is the
unpatched mod, so 3D mode will be blank. Once PR #40 is merged this becomes
the whole story and `add-mod.sh` can be ignored.

## Known issues

**A picked file isn't noticed until the app restarts.** After choosing a ROM,
mod, or save through the file picker, nothing appears to happen. The file *is*
copied correctly — the running app just doesn't consume it. Force-quit and
reopen and it's imported. Under diagnosis; the file is never lost.

**The iOS file picker is a fork addition.** Upstream's iOS build has no
`love.system.pickFile` at all, so Import ROM fails outright there. The bridge
that makes it work is submitted as
[gen1recomp PR #539](https://github.com/bryanthaboi/gen1recomp/pull/539).

## Build it yourself

```bash
git clone https://github.com/hernan0078/gen1recomp.git
cd gen1recomp
git checkout feature/voxeltrail-ios
./scripts/build_ios.sh --device --release --unsigned --no-mods
```

Needs macOS with Xcode. The IPA lands in `dist/ios/`. Drop `--no-mods` to
include a mod you've placed in `mods/`, and `--unsigned` to sign with your own
team instead.

## Credits and licensing

- **Engine** — [gen1recomp](https://github.com/bryanthaboi/gen1recomp) by BOIS
  CLUB GAMES, LLC, MIT licensed. Full text in [`LICENSE-engine.md`](LICENSE-engine.md).
- **LÖVE** — the framework the engine runs on, zlib licensed.
- **3D voxel mod** — by [DramaticShape](https://github.com/DramaticShape/DramaticShapeVoxelMod),
  no license stated; not redistributed here.
- **iOS port work in this build** — MIT, same terms as the engine.

Pokémon is a trademark of Nintendo / Creatures Inc. / GAME FREAK Inc. This
project is unaffiliated with them, contains no game assets, and requires a ROM
you already own.
