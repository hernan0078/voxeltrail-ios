# Getting Pokémon Yellow into Spanish

**[Español abajo](#en-español)**

A Spanish **Edición Amarilla** cartridge now imports and plays. This document
was originally a handoff saying that was weeks of specialist work away; it was
wrong, and what follows is why, and what is actually left.

---

## The short version

**A Spanish cartridge imports.** Drop an *Edición Amarilla* dump into the
launcher and it extracts and runs in Spanish — the dialogue, the Pokédex, the
move and item names, `ñ` and `á` and `¿` and all — because the addresses it
needs are recovered from the cartridge itself rather than from a disassembly
that does not exist — all 4,711 of them.

**A translation mod is still worth doing**, for a different reason: it works
on the English ROM people already own, and it is the only route for languages
that never had a retail cartridge.

The two paths no longer compete. Cartridge support is done; the mod route is
for people who do not have a Spanish cart.

---

## Path A — a translation mod

Unchanged and still good. The engine has a translation system and the
maintainer has said mods are the intended route. A translation mod replaces
text at runtime, so it works with the **English Yellow ROM**.

```bash
python3 tools/modkit.py translation spanish_yellow --language "Espanol"
```

That scaffolds a manifest, a `lang/` directory with one catalog per kind of
text, and a `TRANSLATING.md`.

| Catalog | What it holds | Keyed by |
|---|---|---|
| `dialogue.lua` | Every line of script text | the original label, e.g. `_PalletTownText1` |
| `strings.lua` | Engine text: battle messages, menus, link play | the English source |
| `species_names.lua` · `move_names.lua` · `item_names.lua` · `trainer_names.lua` | Names | the vanilla id |
| `status_labels.lua` | `PSN`, `BRN`, … as the HUD shows them | the status id |
| `naming.lua` | The letter grid for entering names | — |
| `font.lua` · `charmap.lua` | Your glyph sheet and what draws what | — |

Fill in a value and it takes effect. Leave it `""` and that string stays
English, so the work ships in slices.

### The accent problem is solved twice over

The Game Boy font has no glyph for `ñ` or any accented vowel — the charmap's
one exception is the small `é` of POKéMON. Our app menus are written in plain
A–Z for that reason, which reads as slightly wrong Spanish.

A mod can ship its own glyph sheet (`assets/font/`, `lang/font.lua`,
`lang/charmap.lua`) and draw the missing eight. That is an afternoon of pixel
work.

**And the retail cartridge already did it.** Nintendo's Spanish build reused
the Japanese kana slots `$C0`–`$DF` for `à á è é ì í ò ó ù ú ä ö ü ñ` and
their capitals, and two apostrophe-ligature slots for `¿` and `¡`. If you
want a reference glyph sheet that is guaranteed to fit the font's weight and
baseline, it is sitting in the cartridge — `tools/es/charmap.py --render`
prints every one of them as ASCII art.

### Scale, honestly

The engine catalog is **577 strings** — menus, battle messages, link play.
That is a weekend.

The dialogue catalog is the large one: **2,585 labels** for Red/Blue, and
Yellow is comparable. That wants several people, or one person and patience.

Placeholders like `%s`, `\n` and `{RAM:wStringBuffer}` must survive
translation exactly. The engine checks format arity and falls back to English
with a warning rather than crashing, but a mismatch means that line never
shows in Spanish.

### Worth checking first

There is reportedly **already a Spanish translation mod** for this engine —
bryanthaboi mentioned one on
[issue #729](https://github.com/bryanthaboi/gen1recomp/issues/729). Find it
before starting. If it covers Red/Blue only, its `strings.lua` still
transfers wholesale to Yellow, since engine text is shared.

---

## Path B — Spanish ROM support

**This works now.** `tools/es/` builds an import manifest for a translated
cartridge by reading it against the English one.

```bash
python3 tools/es/make_es_manifest.py \
    --base "Pokemon - Yellow Version.gbc" \
    --target "Pokemon - Edicion Amarilla.gb" \
    --manifest tools/rom_manifest_yellow.json \
    --out tools/rom_manifest_yellow_es.json
```

`GameVersion` gained a `yellow_es` entry, so the launcher shows an
**Amarilla (ES)** column and the cart imports like any other.

### Why the old answer was wrong

The extractor resolves ~4,459 symbols through `name -> [bank, address]`
pairs. For the English games those come from a pret disassembly's `.sym`
output. For Spanish Red/Blue,
[PR #622](https://github.com/bryanthaboi/gen1recomp/pull/622) used
[einstein95/pokered-es](https://github.com/einstein95/pokered-es), a
shift-matching disassembly that rebuilds the retail ROM byte for byte.

No such disassembly exists for Spanish Yellow, and the conclusion drawn from
that was: no addresses, and they cannot be guessed.

The second half is true and the first half does not follow. **The addresses
do not have to be guessed, because the cartridge states them.**

A translated cartridge is not a rewrite. Every routine, every graphics blob
and every fixed-size table is byte-identical; what changes is the text, and
everything after a longer or shorter string slides. The Spanish and English
Yellow ROMs are **72% byte-identical**, and 32 of their 62 used banks sit at
exactly the same offsets.

That is enough to line the two up bank by bank. And once they are lined up,
the pointers inside the Spanish ROM can simply be read:

- Gen-1 dialogue is reached through `text_far` — the byte `$17`, then an
  address, then a bank. The `$17` is untouched code, so it relocates by
  alignment, and **the pointer sitting right behind it is the cartridge
  telling you where it moved its own text.** That recovers 2,482 dialogue
  labels whose content is completely different.
- Pokédex descriptions are read out of their own entry blocks, 149 of them.
- Runs of dialogue are walked block by block between two labels already
  placed, accepted only when the walk closes exactly on the label that ends
  the run -- which is what corrects a mislocated pointer.
- Map headers come from their pointer table and its parallel bank table, 101
  of them, found exactly because we know every entry the English ROM holds.
- 914 symbols never moved at all.

Nothing is guessed. Every address is either read out of the Spanish ROM's own
pointers or carried across a byte-identical run, and every one is
range-checked, order-checked and cross-checked against the other strategies
before it ships. What cannot be established is listed, not invented.

### What to be careful about

Every symbol resolves, and every check agrees with the English baseline: text
addresses sit just after a string terminator at 99.59% against English's
99.66%, the block chain reconciles all but 10 consecutive pairs against
English's own 10, and no two symbols share a destination.

But more than half the addresses come from reading a relocated `text_far`,
and **only 44 of those 2,694 sites sit inside a byte-identical run** — the
rest are interpolated. A wrapper is five bytes, so an interpolated site can
land next door and read a valid pointer to the neighbouring label's text.
Nine labels around `_CantDepositLastMonText` did exactly that, each shifted
by one block, and no range, order or plausibility check noticed, because
every individual answer was well-formed. They were found by reading the
Spanish against the English, and are fixed.

So the manifest is very good and not proven. If you play through and a line
looks like it belongs to the wrong character, that is the failure mode, and
it is worth reporting.

A shift-matching `pokeyellow-es` would settle it for good. It is no longer on
the critical path, but it is the only thing that would turn "every check
passes" into "proven".


### One real format difference

European cartridges store Pokédex height and weight in **metric** — one byte
of decimetres and two of hectograms — where the US ones use four bytes of
feet, inches and tenths of a pound. Both extractors now detect which layout
they are reading, keep the metric figures, and convert for the imperial
fields.

Two things about that are worth knowing before attempting French, German or
Italian. The layout has to be decided for the whole table rather than per
entry — the marker is the `text_far` after the measurements, and TENTACOOL's
Spanish entry reads `$09 $C7 $01 $17 $17`, so on its own it looks imperial
and comes out as 199 inches tall. And the conversion is not exact: heights
match the US cartridge for all 151 species, but weights match for only 21 and
otherwise sit within 0.6 lb, because Nintendo wrote the two sets of figures
independently. Pikachu is 0.4 m / 6.0 kg in Spanish, which converts to 13.2
lb where the US cart says 13.0.

### Other languages

Nothing in `tools/es/` is Spanish-specific. French, German and Italian Yellow
should work the same way, and Red/Blue in any language by pointing
`--manifest` at `tools/rom_manifest.json`. Which font slots a build reused is
derived from whichever ROM you hand it.

If you have a European cartridge dump, running the tool and posting its
report is a useful contribution on its own — it says exactly how far the
method gets on that language without anyone having to guess.

---

## Recommendation

If you have a Spanish cartridge: import it.

If you do not, do Path A. Ask about the existing Spanish mod first, lift its
`strings.lua`, and use `tools/es/charmap.py --render` against a Spanish cart
as your reference for the eight missing glyphs.

If you enjoy reverse-engineering, `pokeyellow-es` is still worth building —
but as the thing that proves the result, not as the thing that unblocks it.

---

# En español

## Resumen

**Un cartucho de Edición Amarilla ya se importa y funciona.** Este documento
decía antes que eso eran semanas de trabajo especializado; estaba
equivocado. Las direcciones que necesita el extractor se recuperan del propio
cartucho en vez de una desensambladura que no existe: los 4.711.

El **mod de traducción** sigue mereciendo la pena por otra razón: funciona con
la ROM en inglés que ya tienes, y es la única vía para idiomas que nunca
tuvieron cartucho.

## Camino A — un mod de traducción

El motor ya trae un sistema de traducción y el autor del proyecto ha dicho
que los mods son la vía prevista. Un mod sustituye el texto en tiempo de
ejecución, así que vale con la ROM en inglés.

```bash
python3 tools/modkit.py translation spanish_yellow --language "Espanol"
```

Eso genera el mod entero: manifiesto, un catálogo por tipo de texto en
`lang/`, y un `TRANSLATING.md`. Rellenas un valor y funciona; lo que dejes
vacío se queda en inglés, así que el juego es jugable en cualquier punto.

**Las tildes sí se pueden.** La fuente del juego no tiene glifo para la ñ ni
para las vocales acentuadas —por eso el español de nuestros menús va sin
tildes— pero un mod puede traer su propia hoja de glifos (`assets/font/`,
`lang/font.lua`, `lang/charmap.lua`).

Y el cartucho español ya lo resolvió: Nintendo reutilizó los huecos de los
kana japoneses (`$C0`–`$DF`) para `à á è é ì í ò ó ù ú ä ö ü ñ` y sus
mayúsculas, y dos huecos de ligaduras para `¿` y `¡`.
`tools/es/charmap.py --render` los imprime todos como arte ASCII, que es la
mejor referencia posible de peso y línea base.

**Tamaño real:** 577 cadenas del motor (un fin de semana) y unas 2.585
etiquetas de diálogo (eso quiere varias personas). Los `%s`, `\n` y
`{RAM:...}` tienen que sobrevivir intactos.

**Antes de empezar:** al parecer ya existe un mod en español para este motor;
bryanthaboi lo mencionó en la
[issue #729](https://github.com/bryanthaboi/gen1recomp/issues/729). Búscalo.
Aunque solo cubra Rojo/Azul, su `strings.lua` sirve igual para Amarillo.

## Camino B — soporte de ROM española

**Ya funciona.** `tools/es/` construye el manifiesto de importación de un
cartucho traducido leyéndolo contra el inglés.

```bash
python3 tools/es/make_es_manifest.py \
    --base "Pokemon - Yellow Version.gbc" \
    --target "Pokemon - Edicion Amarilla.gb" \
    --manifest tools/rom_manifest_yellow.json \
    --out tools/rom_manifest_yellow_es.json
```

`GameVersion` tiene ahora una entrada `yellow_es`, así que el lanzador
muestra una columna **Amarilla (ES)** y el cartucho se importa como
cualquier otro.

### Por qué la respuesta anterior era falsa

El extractor resuelve ~4.459 símbolos con pares `nombre -> [banco,
dirección]`. Para los juegos en inglés salen del `.sym` de una
desensambladura de pret; para Rojo/Azul en español, la
[PR #622](https://github.com/bryanthaboi/gen1recomp/pull/622) usó
[einstein95/pokered-es](https://github.com/einstein95/pokered-es).

Para Amarillo en español no existe ninguna, y de ahí se concluyó: sin
direcciones, y no se pueden adivinar.

Lo segundo es cierto y lo primero no se sigue. **No hay que adivinarlas,
porque el cartucho las dice.**

Un cartucho traducido no es una reescritura: las rutinas, los gráficos y las
tablas de tamaño fijo son idénticas byte a byte; lo que cambia es el texto, y
todo lo que va detrás de una cadena más larga o más corta se desplaza. Las
ROMs española e inglesa de Amarillo son **idénticas en un 72%**, y 32 de sus
62 bancos usados están exactamente en los mismos desplazamientos.

Con eso se pueden alinear banco a banco. Y una vez alineadas, los punteros de
la ROM española se leen sin más:

- El diálogo de la primera generación se alcanza con `text_far`: el byte
  `$17`, luego una dirección, luego un banco. El `$17` es código intacto, así
  que se reubica por alineación, y **el puntero que va justo detrás es el
  cartucho diciéndote dónde ha puesto su propio texto.** Eso recupera 2.482
  etiquetas de diálogo cuyo contenido es completamente distinto.
- Las descripciones de la Pokédex se leen de sus propios bloques: 149.
- Los tramos de diálogo se recorren bloque a bloque entre dos etiquetas ya
  colocadas, y solo se aceptan si el recorrido cierra exactamente en la
  etiqueta que lo termina; eso es lo que corrige un puntero mal ubicado.
- Las cabeceras de mapa salen de su tabla de punteros y de la tabla de bancos
  paralela: 101, localizadas con exactitud porque conocemos todas las
  entradas que tiene la ROM inglesa.
- 914 símbolos no se movieron.

Nada se adivina. Cada dirección se lee de los punteros de la propia ROM
española o se arrastra por un tramo idéntico byte a byte, y todas se
comprueban por rango, por orden y contra las demás estrategias antes de
publicarse. Lo que no se puede establecer se lista, no se inventa.

### Con qué hay que tener cuidado

Todos los símbolos se resuelven, y todas las comprobaciones coinciden con la
referencia inglesa: las direcciones de texto caen justo detrás de un
terminador el 99,59% de las veces frente al 99,66% del inglés, la cadena de
bloques encaja en todos los pares consecutivos menos 10 frente a los 10 del
propio inglés, y ningún par de símbolos comparte destino.

Pero más de la mitad de las direcciones salen de leer un `text_far`
reubicado, y **solo 44 de esos 2.694 emplazamientos caen dentro de un tramo
idéntico byte a byte**; el resto hay que interpolarlos. Un envoltorio ocupa
cinco bytes, así que uno interpolado puede caer en el de al lado y leer un
puntero válido al texto de la etiqueta vecina. Nueve etiquetas alrededor de
`_CantDepositLastMonText` hicieron justo eso, desplazadas un bloque cada
una, y ninguna comprobación de rango, orden o plausibilidad se dio cuenta,
porque cada respuesta por separado estaba bien formada. Se encontraron
leyendo el español contra el inglés, y están corregidas.

Así que el manifiesto es muy bueno, no demostrado. Si juegas y una frase
parece de otro personaje, ése es el fallo, y merece la pena avisar.

Una `pokeyellow-es` con coincidencia byte a byte lo zanjaría. Ya no es el
camino crítico, pero es lo único que convertiría "pasa todas las
comprobaciones" en "demostrado".


### Una diferencia real de formato

Los cartuchos europeos guardan la altura y el peso de la Pokédex en
**métrico** —un byte de decímetros y dos de hectogramos— donde los
estadounidenses usan cuatro bytes de pies, pulgadas y décimas de libra. Los
dos extractores detectan ahora qué formato están leyendo, conservan las
cifras métricas y convierten para los campos imperiales.

El formato hay que decidirlo para la tabla entera y no entrada por entrada:
la señal es el `text_far` que va detrás de las medidas, y la entrada española
de TENTACOOL es `$09 $C7 $01 $17 $17`, así que por sí sola parece imperial y
sale midiendo 199 pulgadas. Y la conversión no es exacta: las alturas
coinciden con el cartucho estadounidense en las 151 especies, pero los pesos
solo en 21, y el resto se queda a menos de 0,6 lb, porque Nintendo escribió
las dos series de cifras por separado. PIKACHU es 0,4 m / 6,0 kg en español,
que convertido da 13,2 lb donde el cartucho estadounidense dice 13,0.

### Otros idiomas

Nada de `tools/es/` es específico del español. Amarillo en francés, alemán e
italiano debería funcionar igual, y Rojo/Azul en cualquier idioma apuntando
`--manifest` a `tools/rom_manifest.json`.

Si tienes un volcado de un cartucho europeo, ejecutar la herramienta y
publicar su informe ya es una aportación útil: dice exactamente hasta dónde
llega el método en ese idioma sin que nadie tenga que suponerlo.

## Recomendación

Si tienes un cartucho español, impórtalo.

Si no, haz el Camino A: pregunta primero por el mod español que ya existe,
aprovecha su `strings.lua`, y usa `tools/es/charmap.py --render` contra un
cartucho español como referencia para los glifos que faltan.

Y si te apetece la ingeniería inversa, `pokeyellow-es` sigue mereciendo la
pena, pero como lo que demuestra el resultado, no como lo que lo desbloquea.
