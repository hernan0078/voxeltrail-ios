# VoxelTrail for iOS

**[Español](README.es.md)** · English

A native iOS build of the [Gen 1 recomp engine](https://github.com/bryanthaboi/gen1recomp)
— the Generation 1 Pokémon games, reimplemented in Lua on LÖVE — with the
[Dramatic Shape voxel mod](https://github.com/DramaticShape/DramaticShapeVoxelMod)
built in, so the overworld can be played as a 3D diorama or in first person.

**You need your own ROM.** None is included here and none will be. The app
reads a Game Boy ROM you already own and extracts its data on first launch.

---

## Install

The IPA is **unsigned**, which is what sideloading tools expect — they sign it
with your own Apple ID, on your own device.

1. **Install a sideloader.** [SideStore](https://sidestore.io) or
   [AltStore](https://altstore.io). Follow their setup; both need a one-time
   pairing step with a computer.
2. **Download** `VoxelTrail-0.2.0.ipa` from the
   [latest release](../../releases/latest). On the phone, Safari puts it in
   **Files → Downloads**.
3. **Open it in SideStore/AltStore** and let it install. First install takes a
   minute or two while it signs.
4. **Trust the developer** if iOS asks: **Settings → General → VPN & Device
   Management**, tap your Apple ID, **Trust**.
5. Launch **VoxelTrail** from the home screen.

Requires **iOS 16 or later**. On a free Apple ID a sideloaded app runs for
**7 days** before it needs refreshing in the sideloader — an Apple limit, not
this app's. A paid developer account extends it to a year.

## Load your ROM

Two ways, no computer needed for either.

**With the picker** — tap **Import ROM**, choose your `.gb` / `.gbc` file from
Files, and wait for extraction. It runs once, takes a few seconds, and after
that the game boots straight in.

**Through the Files app** — open **Files → On My iPhone → VoxelTrail**, drop
the ROM in, and launch the app. It sweeps that folder on startup.

Red, Blue and Yellow are all supported. Your ROM never leaves the device, and
the extracted data lives in the app's private storage.

## What's in this build

Everything below is in the IPA — nothing to install separately.

### The 3D world

**START → OPTION → `3D WORLD`** steps through the camera:

| Rung | What you get |
|---|---|
| `OFF` | The original flat Game Boy view |
| `FULL 3D` | A preset — sets the whole look at once |
| `SLIGHT` · `TILTED` · `STEEP` | Progressively steeper diorama angles |
| `TABLE TOP` | Nearly straight down, like a board game |
| `1ST PERSON` | Inside the world, at eye level |

`FULL 3D` is a **preset**, not an angle — it sets the other rows for you, so
pick your angle first and fine-tune afterwards.

### First person

On the `1ST PERSON` rung:

- **d-pad** walks you around
- **the look stick** above A/B turns the view — hold it, it keeps turning
- **or drag anywhere** on open screen to look, with any spare finger
- **a game controller** works too: left stick moves, right stick looks

Three rows appear on this rung only: `LOOK STICK` (hide it if you play with a
controller), `LOOK SPEED`, and `INVERT Y` for anyone who flies
pull-back-to-look-up.

### Live tuning — change the look while you watch it

A faint **cube handle in the top-right corner** opens a panel over the running
game. Every 3D setting is in it. Tap the **left half** of a row to step down,
the **right half** to step up — and the world redraws immediately behind the
panel, so you can compare settings by looking at them instead of walking back
and forth to a menu.

Turn it off with `TUNE PANEL` if you'd rather have the corner back.

### Pinch to zoom

Two fingers on open screen zoom the view in and out. It drives the same `ZOOM`
setting the menu does — pinch, then open the menu, and the row is already
where you left it. A pinch that starts on the d-pad or the buttons is ignored,
so holding the game normally never zooms it by accident.

### Spanish

**`LANGUAGE` → `ESPA~OL`** switches every setting in the app to Spanish —
both this mod's rows and the engine's own (`ZOOM`, `VEL TEXTO`,
`RELLENO VACIO`, `ESTILO COMBATE`…).

The game's own text — names, dialogue, items, places — stays as it is in your
ROM, because that text belongs to the cartridge. An English ROM stays an
English adventure with Spanish menus.

### Touch controls

The on-screen pad is laid out for an upright phone: the screen sits above the
buttons rather than behind your thumbs, and the pad clears the home indicator.
A connected controller hides it automatically.

**Touch Controls** in the launcher lets you drag every button where you want
it, or switch the overlay off entirely.

## Known issues

- **The 3D mode is demanding.** On older devices, drop `SMOOTHING` to `OFF`
  and `MINIATURE` to `OFF` before anything else.
- **First person is marked experimental by its author** and can behave oddly
  in tight interiors.

## Build it yourself

```bash
git clone https://github.com/hernan0078/gen1recomp.git
cd gen1recomp
git checkout feature/voxeltrail-ios
./scripts/build_ios.sh --device --release --unsigned
```

Needs macOS with Xcode. The IPA lands in `dist/ios/`. Add `--no-mods` for a
build without the 3D mod, or drop `--unsigned` to sign with your own team.

## Credits and licensing

- **Engine** — [gen1recomp](https://github.com/bryanthaboi/gen1recomp) by BOIS
  CLUB GAMES, LLC. MIT — [`LICENSE-engine.md`](LICENSE-engine.md).
- **3D voxel mod** — [Dramatic Shape](https://github.com/DramaticShape/DramaticShapeVoxelMod)
  by DramaticShape. MIT; its licence travels inside the app bundle.
- **LÖVE** — the framework underneath, zlib licensed.
- **iOS port work in this build** — MIT, same terms as the engine.

Pokémon is a trademark of Nintendo / Creatures Inc. / GAME FREAK Inc. This
project is unaffiliated with them, contains no game assets, and requires a ROM
you already own.
