# VoxelTrail para iOS

Español · **[English](README.md)**

Una versión nativa para iOS del [motor Gen 1 recomp](https://github.com/bryanthaboi/gen1recomp)
— los juegos de Pokémon de primera generación, reimplementados en Lua sobre
LÖVE — con el [mod voxel Dramatic Shape](https://github.com/DramaticShape/DramaticShapeVoxelMod)
ya incluido, así que el mapa se puede jugar como un diorama en 3D o en
primera persona.

**Necesitas tu propia ROM.** Aquí no se incluye ninguna y nunca se incluirá.
La app lee una ROM de Game Boy que ya tengas y extrae sus datos la primera vez
que arranca.

---

## Instalación

El IPA está **sin firmar**, que es justo lo que esperan las herramientas de
sideload: lo firman con tu propio Apple ID, en tu propio dispositivo.

1. **Instala un sideloader.** [SideStore](https://sidestore.io) o
   [AltStore](https://altstore.io). Sigue su configuración; ambos necesitan
   emparejarse una vez con un ordenador.
2. **Descarga** `VoxelTrail-0.2.0.ipa` desde la
   [última versión](../../releases/latest). En el teléfono, Safari lo deja en
   **Archivos → Descargas**.
3. **Ábrelo con SideStore/AltStore** y deja que lo instale. La primera
   instalación tarda un par de minutos mientras lo firma.
4. **Confía en el desarrollador** si iOS lo pide: **Ajustes → General →
   VPN y gestión de dispositivos**, toca tu Apple ID y **Confiar**.
5. Abre **VoxelTrail** desde la pantalla de inicio.

Requiere **iOS 16 o posterior**. Con un Apple ID gratuito, una app instalada
así funciona **7 días** antes de tener que renovarla desde el sideloader: es
un límite de Apple, no de la app. Una cuenta de desarrollador de pago lo
amplía a un año.

## Cargar tu ROM

Dos formas, y ninguna necesita ordenador.

**Con el selector** — toca **Import ROM**, elige tu archivo `.gb` / `.gbc` en
Archivos y espera a que extraiga. Solo pasa una vez, tarda unos segundos, y a
partir de ahí el juego arranca directo.

**Desde la app Archivos** — abre **Archivos → En mi iPhone → VoxelTrail**,
deja la ROM ahí y abre la app. Al arrancar revisa esa carpeta.

Funcionan Rojo, Azul y Amarillo. Tu ROM nunca sale del dispositivo y los datos
extraídos quedan en el almacenamiento privado de la app.

## Qué incluye

Todo lo de abajo va dentro del IPA. No hay que instalar nada aparte.

### El mundo en 3D

**START → OPTION → `MUNDO 3D`** recorre la cámara:

| Nivel | Qué ves |
|---|---|
| `NO` | La vista plana original de Game Boy |
| `3D TOTAL` | Un preajuste: configura todo el aspecto de golpe |
| `LEVE` · `INCLINADO` · `EMPINADO` | Ángulos de diorama cada vez más inclinados |
| `CENITAL` | Casi desde arriba, como un juego de mesa |
| `1A PERSONA` | Dentro del mundo, a la altura de los ojos |

`3D TOTAL` es un **preajuste**, no un ángulo: cambia las demás filas por ti,
así que elige primero el ángulo y ajusta el resto después.

### Primera persona

En el nivel `1A PERSONA`:

- **la cruceta** te mueve
- **la palanca** encima de A/B gira la vista; si la mantienes, sigue girando
- **o arrastra en cualquier parte** libre de la pantalla, con el dedo que
  tengas suelto
- **un mando** también funciona: stick izquierdo mueve, derecho mira

Tres filas aparecen solo en este nivel: `PALANCA` (ocúltala si juegas con
mando), `VELOCIDAD` e `INVERTIR Y` para quien prefiere tirar hacia abajo para
mirar hacia arriba.

### Ajuste en vivo: cambia el aspecto mientras lo miras

Un **cubo tenue en la esquina superior derecha** abre un panel sobre el juego
en marcha, con todos los ajustes 3D. Toca la **mitad izquierda** de una fila
para bajar y la **mitad derecha** para subir: el mundo se redibuja al instante
detrás del panel, así que comparas ajustes mirándolos en vez de ir y volver
del menú.

Se quita con `PANEL DE CONTROL` si prefieres recuperar la esquina.

### Pellizcar para acercar

Dos dedos sobre la pantalla libre acercan y alejan la vista. Mueven el mismo
ajuste `ZOOM` que el menú: pellizca, abre el menú, y la fila ya está donde la
dejaste. Un pellizco que empieza sobre la cruceta o los botones se ignora, así
que sujetar el mando normal nunca cambia el zoom sin querer.

### Español

**`IDIOMA` → `ESPA~OL`** pasa a español todos los ajustes de la app: tanto las
filas de este mod como las del propio motor (`ZOOM`, `VEL TEXTO`,
`RELLENO VACIO`, `ESTILO COMBATE`…).

El texto del juego —nombres, diálogos, objetos, lugares— se queda como esté en
tu ROM, porque ese texto es del cartucho. Una ROM en inglés sigue siendo una
aventura en inglés, con los menús en español.

> Nota sobre la tilde: la fuente del juego no tiene glifo para la ñ ni para
> las vocales acentuadas, así que se escribe `~` donde haría falta una eñe.
> Es una limitación de la fuente, no una errata.

### Controles táctiles

Los controles en pantalla están pensados para el teléfono en vertical: la
pantalla queda por encima de los botones en vez de detrás de tus pulgares, y
el mando deja libre la barra de inicio. Si conectas un mando, se ocultan
solos.

**Touch Controls** en el menú inicial te deja arrastrar cada botón donde
quieras, o quitar los controles por completo.

## Problemas conocidos

- **El modo 3D pide bastante máquina.** En dispositivos antiguos, baja
  `SUAVIZADO` a `NO` y `MINIATURA` a `NO` antes que nada.
- **La primera persona está marcada como experimental por su autor** y puede
  comportarse de forma rara en interiores estrechos.

## Compilarlo tú mismo

```bash
git clone https://github.com/hernan0078/gen1recomp.git
cd gen1recomp
git checkout feature/voxeltrail-ios
./scripts/build_ios.sh --device --release --unsigned
```

Necesita macOS con Xcode. El IPA aparece en `dist/ios/`. Añade `--no-mods`
para una versión sin el mod 3D, o quita `--unsigned` para firmarlo con tu
propio equipo.

## Créditos y licencias

- **Motor** — [gen1recomp](https://github.com/bryanthaboi/gen1recomp) de BOIS
  CLUB GAMES, LLC. MIT — [`LICENSE-engine.md`](LICENSE-engine.md).
- **Mod voxel 3D** — [Dramatic Shape](https://github.com/DramaticShape/DramaticShapeVoxelMod)
  de DramaticShape. MIT; su licencia viaja dentro de la app.
- **LÖVE** — el framework de debajo, licencia zlib.
- **El trabajo de portado a iOS de esta versión** — MIT, los mismos términos
  que el motor.

Pokémon es una marca de Nintendo / Creatures Inc. / GAME FREAK Inc. Este
proyecto no está afiliado a ellos, no contiene recursos del juego y necesita
una ROM que ya tengas.
