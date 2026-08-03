# Getting Pokémon Yellow into Spanish

**[Español abajo](#en-español)**

There are two ways to play Yellow in Spanish, and they are not equally
difficult. This is a handoff for anyone who wants to do the work — including
future me.

---

## The short version

**Do the translation mod.** It works on the English ROM people already own,
the tooling exists, and it can be started this afternoon by one person and
finished by several.

**Do not start with the disassembly** unless you specifically want to
reverse-engineer a ROM. It is the only path that makes a Spanish *cartridge*
importable, and it is weeks of specialist work.

---

## Path A — a translation mod (recommended)

The engine already has a translation system, and the project's maintainer has
said mods are the intended route. A translation mod replaces the game's text
at runtime, so it works with the **English Yellow ROM you already have**. No
Spanish cartridge, no disassembly.

### What you get for free

```bash
python3 tools/modkit.py translation spanish_yellow --language "Espanol"
```

That scaffolds a complete mod: a manifest, a `lang/` directory with one
catalog per kind of text, and a `TRANSLATING.md` explaining the workflow.

| Catalog | What it holds | Keyed by |
|---|---|---|
| `dialogue.lua` | Every line of script text | the original label, e.g. `_PalletTownText1` |
| `strings.lua` | Engine text: battle messages, menus, link play | the English source |
| `species_names.lua` · `move_names.lua` · `item_names.lua` · `trainer_names.lua` | Names | the vanilla id |
| `status_labels.lua` | `PSN`, `BRN`, … as the HUD shows them | the status id |
| `naming.lua` | The letter grid for entering names | — |
| `font.lua` · `charmap.lua` | Your glyph sheet and what draws what | — |

**Fill in a value and it takes effect. Leave it `""` and that string stays
English.** The game is playable at every point along the way, which means the
work can be done in slices and released early.

### The accent problem is solvable

This matters, and it is the thing I got wrong in the app's own menus.

The Game Boy font has **no glyph for `ñ` or any accented vowel** — the entire
charmap's one exception is the small `é` of POKéMON. Our menu Spanish is
written in plain A–Z for that reason, which reads as slightly wrong Spanish.

A translation mod does **not** have to accept that. It can ship its own glyph
sheet:

- `assets/font/` — a PNG of 8×8 cells, black on white, 16 per row
- `lang/font.lua` — declares the sheet and its base code
- `lang/charmap.lua` — maps byte sequences to glyph codes, longest-first, so
  multi-byte characters and ligatures both work

`assets/generated/font.png` in the player's cache is the vanilla sheet at the
same scale — open it alongside yours to match weight and baseline.

So a proper Spanish translation can have `ñ`, `á`, `í`, `ó`, `ú`, `¿` and `¡`.
Drawing about eight glyphs is an afternoon's pixel work and it lifts the whole
thing from "readable" to "right".

### The actual workflow

1. **Import a Yellow ROM in the app first.** Without one, the scaffold falls
   back to a three-species test fixture — you will get 577 engine strings and
   almost no dialogue.
2. **Re-run with `--refresh`** to harvest the real catalogs from your imported
   data.
3. **Translate.** The English lives in a `spanish_yellow-worksheet/`
   directory *outside* the mod, one tab-separated file per catalog:
   ```
   "_AbandonLearningText"	"Abandon learning\n{RAM:wStringBuffer}?"
   ```
4. **Keep the worksheet outside the mod.** This is deliberate and it matters
   legally: extracted script text is ROM content, and `modkit pack` zips
   everything under the mod directory. A worksheet kept inside would ship the
   original English script in your release. Yours holds only your
   translations.
5. **Pack and test** with `modkit`, then import the zip in the app.

### Scale, honestly

The engine catalog is **577 strings** — menus, battle messages, link play.
That is a weekend.

The dialogue catalog is the large one. For Red/Blue the extractor decodes
**2,585 dialogue labels**; Yellow is comparable. That is the part that wants
several people, or one person and patience.

Placeholders like `%s`, `\n` and `{RAM:wStringBuffer}` must survive
translation exactly — the engine checks format arity and falls back to English
with a warning rather than crashing, but a mismatch means that line never
shows in Spanish.

### Worth checking first

There is reportedly **already a Spanish translation mod** for this engine —
bryanthaboi mentioned one on
[issue #729](https://github.com/bryanthaboi/gen1recomp/issues/729). Find it
before starting. If it covers Red/Blue only, its `strings.lua` still transfers
wholesale to Yellow, since engine text is shared. That alone could halve the
work.

---

## Path B — Spanish ROM support (the hard one)

This is what [PR #622](https://github.com/bryanthaboi/gen1recomp/pull/622)
did for Red and Blue: import a genuine *Edición Roja* cartridge dump and the
game plays in Spanish from the ROM itself.

It cannot be done for Yellow today, and the reason is specific.

### Why it is blocked

The extractor resolves ~3,269 symbols through a manifest of
`name → [bank, address]` pairs. For the Spanish releases those addresses come
from [einstein95/pokered-es](https://github.com/einstein95/pokered-es), a
**shift-matching disassembly** — one that rebuilds the retail ROM
byte-for-byte, so its `.sym` output gives the Spanish address of every symbol.

**No equivalent exists for Spanish Yellow.** Without it there are no
addresses, and they cannot be guessed: a wrong address produces a garbled
game, not a Spanish one.

### It is demonstrably possible

Yellow disassemblies exist for other European releases:

- [`Narishma-gb/pokeyellow-fr`](https://github.com/Narishma-gb/pokeyellow-fr) — French
- [`Brianum/pokeyellow-de`](https://github.com/Brianum/pokeyellow-de) — German
- [`Narishma-gb/pokeyellow-jp`](https://github.com/Narishma-gb/pokeyellow-jp) — Japanese

So pret's Yellow has been adapted to European builds twice. Spanish simply has
not been done.

### What it would take

1. Fork [`pret/pokeyellow`](https://github.com/pret/pokeyellow) and get it
   building with `rgbds`.
2. Diff the build against a Spanish Amarillo dump.
   [gbromdiff](https://github.com/hernan0078/gbromdiff) exists for this — it
   reports bank by bank whether a difference is *replaced* (translated text
   needing new source) or *patched* (the same code with pointers moved), which
   are completely different jobs.
3. Replace the script, fix the shifted tables, rebuild, diff again. Repeat
   until identical.
4. Run `tools/make_es_manifest.py` against the resulting `.sym` — at that
   point the existing machinery does the rest.

Steps 1 and 4 are an afternoon. Steps 2 and 3 are the project.

### If someone does it

The payoff is real: a Spanish Yellow cartridge would import and play with no
mod at all, and the same technique would open French, German and Italian.
[einstein95](https://github.com/einstein95) is the most likely person to
already have notes — asking costs nothing.

---

## Recommendation

Do Path A. Ask about the existing Spanish mod first, lift its `strings.lua`,
draw the eight missing glyphs, and split the dialogue between whoever
volunteers. A partial translation ships and is useful on day one.

Leave Path B for someone who finds the reverse-engineering fun. It is not on
the critical path to a Spanish Yellow.

---

# En español

## Resumen

Hay dos caminos para jugar a Amarillo en español, y no cuestan lo mismo.

**Haz el mod de traducción.** Funciona con la ROM en inglés que ya tienes, las
herramientas existen, y se puede empezar hoy.

**No empieces por la desensambladura** salvo que te apetezca hacer ingeniería
inversa. Es el único camino que permite importar un cartucho español, y son
semanas de trabajo especializado.

## Camino A — un mod de traducción

El motor ya trae un sistema de traducción, y el autor del proyecto ha dicho
que los mods son la vía prevista. Un mod sustituye el texto en tiempo de
ejecución, así que **vale con la ROM en inglés**: ni cartucho español ni
desensambladura.

```bash
python3 tools/modkit.py translation spanish_yellow --language "Espanol"
```

Eso genera el mod entero: manifiesto, un catálogo por tipo de texto en
`lang/`, y un `TRANSLATING.md` con el procedimiento. Rellenas un valor y
funciona; lo que dejes vacío se queda en inglés, así que el juego es jugable
en cualquier punto del camino.

**Las tildes sí se pueden.** La fuente del juego no tiene glifo para la ñ ni
para las vocales acentuadas —por eso el español de nuestros menús va sin
tildes— pero un mod **puede traer su propia hoja de glifos**
(`assets/font/`, `lang/font.lua`, `lang/charmap.lua`). Dibujar unos ocho
glifos es una tarde y sube el resultado de "legible" a "correcto".

**Procedimiento:** importa una ROM de Amarillo primero (sin ella el andamiaje
usa un fixture de tres especies), vuelve a lanzar con `--refresh` para
extraer los catálogos reales, y traduce contra el `-worksheet/` que queda
**fuera** del mod —eso es deliberado: el guión extraído es contenido de la
ROM, y así tu mod solo contiene tus traducciones.

**Tamaño real:** 577 cadenas del motor (un fin de semana) y unas 2.585
etiquetas de diálogo (eso quiere varias personas). Los `%s`, `\n` y
`{RAM:...}` tienen que sobrevivir intactos.

**Antes de empezar:** al parecer **ya existe un mod en español** para este
motor; bryanthaboi lo mencionó en la
[issue #729](https://github.com/bryanthaboi/gen1recomp/issues/729). Búscalo.
Aunque solo cubra Rojo/Azul, su `strings.lua` sirve igual para Amarillo,
porque el texto del motor es común.

## Camino B — soporte de ROM española

Es lo que hizo [PR #622](https://github.com/bryanthaboi/gen1recomp/pull/622)
con Rojo y Azul. Para Amarillo está bloqueado: el extractor resuelve ~3.269
símbolos con direcciones que salen de una desensambladura que reconstruye la
ROM byte a byte, y **no existe una para Amarillo en español**. Las direcciones
no se pueden adivinar: una mal puesta da un juego corrupto, no uno traducido.

Sí es posible —existen desensambladuras de Amarillo en francés
([pokeyellow-fr](https://github.com/Narishma-gb/pokeyellow-fr)) y alemán
([pokeyellow-de](https://github.com/Brianum/pokeyellow-de))— pero es el
proyecto entero, no un paso.

Si alguien se anima:
[gbromdiff](https://github.com/hernan0078/gbromdiff) sirve para el bucle de
compilar, comparar y corregir, y
[einstein95](https://github.com/einstein95) es quien más probablemente tenga
notas.

## Recomendación

Camino A. Pregunta primero por el mod español que ya existe, aprovecha su
`strings.lua`, dibuja los glifos que faltan y reparte los diálogos. Una
traducción parcial ya sirve desde el primer día.
