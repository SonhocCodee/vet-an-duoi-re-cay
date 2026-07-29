# Pixel Player Manifest

## Character

- **Name:** Ashbound Wanderer (working asset name)
- **Art direction:** Original dark-fantasy pixel RPG character in a top-down 3/4 view.
- **Design anchors:** asymmetrical burgundy half-cloak, blue-gray tunic, leather belt, dark swept hair, amber eyes, and a short steel sword.
- **Frame size:** 48 × 64 px.
- **Background:** transparent RGBA.
- **Pixel grid:** integer-aligned shapes with a consistent dark outline and no painted backdrop.
- **Authorship:** created specifically for this project; it does not copy sprites, characters, palettes, or animation frames from Stardew Valley or another game.

## Runtime Files

Use `assets/art/pixel/player/player_sprite_frames.tres` as the `sprite_frames` resource of an `AnimatedSprite2D`. It defines 16 animations:

| Action | Animation names | Frames | FPS | Loop |
| --- | --- | ---: | ---: | --- |
| Idle | `idle_down`, `idle_left`, `idle_right`, `idle_up` | 4 each | 4 | Yes |
| Walk | `walk_down`, `walk_left`, `walk_right`, `walk_up` | 6 each | 8 | Yes |
| Attack | `attack_down`, `attack_left`, `attack_right`, `attack_up` | 6 each | 10 | No |
| Hurt | `hurt_down`, `hurt_left`, `hurt_right`, `hurt_up` | 4 each | 8 | No |

The resource references the individual PNG frames under `frames/<action>/<direction>/`. PNG is the recommended runtime format. Matching SVG files are included as editable, resolution-independent masters.

## Sprite Sheets

Each action also has one atlas-style sheet:

- `player_idle_sheet.png`: 192 × 256 px, 4 columns × 4 rows.
- `player_walk_sheet.png`: 288 × 256 px, 6 columns × 4 rows.
- `player_attack_sheet.png`: 288 × 256 px, 6 columns × 4 rows.
- `player_hurt_sheet.png`: 192 × 256 px, 4 columns × 4 rows.

All sheets use 48 × 64 px cells. Row order is always: **down, left, right, up**. Matching SVG sheets are included beside the PNG sheets.

## Godot 4.3 Setup

1. Add an `AnimatedSprite2D` to the player scene.
2. Assign `player_sprite_frames.tres` to `Sprite Frames`.
3. Keep texture filtering on **Nearest**. The project currently uses nearest-neighbor filtering globally.
4. Choose the animation from movement direction and state, for example `walk_left` or `attack_up`.
5. Return non-looping attack/hurt animations to the matching idle animation when `animation_finished` fires.
6. Keep the sprite centered around the feet; a practical collision capsule/rectangle covers approximately x = 17–31 and y = 44–58 within each frame.

## Palette

The canonical color list and row metadata are stored in `assets/art/pixel/player/palette.json`. Keep recolors within this palette family so future equipment variants remain visually consistent.
