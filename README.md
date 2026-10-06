# Smooth pixel camera

Smooth camera motion for low-res pixel art without the jitter. The game renders at low
resolution in a SubViewport and the camera only moves in whole game pixels, so the art stays
on the grid. The fraction left over is applied when the image is upscaled, by moving the
SubViewportContainer a few screen pixels. Motion looks smooth even at 20 px/s.

## Files

| File | Class | Role |
|---|---|---|
| `smooth_pixel_view.gd` | `SmoothPixelView` (SubViewportContainer) | Scales the game to fit the window and applies the sub-pixel shift |
| `smooth_pixel_camera_2d.gd` | `SmoothPixelCamera2D` (Camera2D) | Follows a target, snaps to whole pixels, reports the leftover |
| `example/example.tscn` | — | Arrow keys move a diamond over a checkerboard |

## Setup

Scene tree (see `example/example.tscn`, or `stages/main/main.tscn` for the real game):

    Control (full rect, mouse_filter = Ignore)
    └── View        SubViewportContainer + smooth_pixel_view.gd
        └── Game    SubViewport
            └── World
                ├── Player
                └── Camera   Camera2D + smooth_pixel_camera_2d.gd (target = Player)

- The SubViewport must be the **only child** of the View.
- On the SubViewport: turn on **Snap 2D Transforms/Vertices to Pixel** and set
  **Default Texture Filter** to Nearest.
- Project settings: leave **Display → Window → Stretch → Mode** at `disabled`. The View does
  the scaling. Engine stretching on top would scale twice and break the sub-pixel shift.

## `SmoothPixelView`

| Export | Default | Meaning |
|---|---|---|
| `min_game_size` | `640 × 360` | Smallest area, in game pixels, that is always visible. Sets the scale |

How it fits the window (`_fit`, re-run on every resize):
1. Scale = the largest whole number at which `min_game_size` still fits (at least 1).
2. The game size covers the window at that scale, plus **one game pixel of margin on each side**,
   rounded up to even so the camera centre lands on a whole pixel.
3. The container is centred; the margin hides the edges when it shifts.

`subpixel_offset` (set by the camera) moves the container by `offset × scale` screen pixels.

## `SmoothPixelCamera2D`

| Export | Default | Meaning |
|---|---|---|
| `target` | — | Node2D to follow |
| `follow_speed` | `5.0` | How fast it catches up. Higher is snappier (frame-rate independent) |
| `mouse_look` | `0.0` | 0–1: how far it leans from the target toward the mouse |

Every frame it keeps an unrounded position, places itself at the rounded one, and gives the
difference to the parent `SmoothPixelView` if there is one. Without a View it is just a
pixel-snapped smooth follow camera.

## Notes / caveats

- The camera turns off Camera2D's built-in position smoothing and physics interpolation, and
  runs in `_process`. Don't re-enable them; it positions itself by hand.
- Only the camera's motion is smoothed. Objects moving on their own still step in whole pixels.
- The shift is at most half a game pixel, which the 1 px margin covers, so no edge ever shows.
- UI drawn outside the SubViewport is not affected and stays at full screen resolution.
