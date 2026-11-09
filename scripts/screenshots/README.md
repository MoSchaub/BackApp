<!--
SPDX-FileCopyrightText: 2026 Moritz Schaub <moritz@pfaender.net>

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# App Store screenshots

(For the README images see `take_screenshots.sh` in the main [README](../../README.md#updating-the-screenshots).)

Generates App Store screenshots in English and German at the exact pixel sizes
App Store Connect expects. By default they are plain full-screen captures like the
current listing (iPad in landscape split view); set `style.mode` to `framed` for
captioned screenshots inside a device frame.

| Device key         | Display                               | Output size     | Simulator (first installed wins)        |
|--------------------|---------------------------------------|-----------------|-----------------------------------------|
| `iphone_6_3`       | iPhone 6.3" with Dynamic Island       | 1206 × 2622     | iPhone 17 Pro, iPhone 17, iPhone 16 Pro |
| `iphone_duo_outer` | iPhone Duo, outer display             | 1398 × 2034     | iPhone Duo, folded via duoctl (falls back to `iphone_6_3`) |
| `iphone_duo_inner` | iPhone Duo, inner display             | 2853 × 2007 (landscape) | iPhone Duo, unfolded via duoctl (falls back to `ipad_13`) |
| `ipad_13`          | iPad 13"                              | 2752 × 2064 (landscape) | iPad Pro 13-inch (M5/M4), iPad Air 13"  |

## Usage (macOS with Xcode)

```bash
scripts/screenshots/make_screenshots.sh
```

Only some devices:

```bash
scripts/screenshots/make_screenshots.sh iphone_6_3 ipad_13
```

Results end up in `build/appstore-screenshots/final/<lang>/<device>/<n>_<screen>.png`,
ready to drag into App Store Connect. They can also be generated on GitHub via
the **App Store Screenshots** workflow (Actions → Run workflow); the images are
uploaded as the `app-store-screenshots` artifact.

## iPhone Duo

Both Duo sizes are captured on the iPhone Duo simulator (Xcode 27.2+) with
[duoctl](https://github.com/skarol/duoctl), because `simctl` can neither fold the Duo
nor screenshot the display that is showing:

```bash
brew install skarol/tap/duoctl
```

- `iphone_duo_outer` runs `duoctl close` (cover display, 1398 × 2034),
  `iphone_duo_inner` runs `duoctl open` (inner display, landscape 2853 × 2007).
- The UI test can't tell which display is live, so for the Duo it asks `capture.sh` for
  each screenshot (a `<name>.request` file), which takes it with `duoctl screenshot`.
- Without duoctl the Duo is skipped and `compose.py` uses the fallback devices.
- duoctl relies on private simulator interfaces (verified with Xcode 27.1/27.2). If a
  future Xcode breaks it, swap in another tool via `pose_command` /
  `screenshot_command` in `config.json` (placeholders `{udid}`, `{pose}`, `{path}`).

After every capture the script warns if the screenshots don't have the aspect ratio of
the App Store size, e.g. when the Duo didn't switch displays.

## How it works

1. `capture.sh` builds the app once, then for every device and language boots the
   simulator, sets a clean status bar (9:41, full battery) and runs
   `Back App iOSUITests/ReadmeScreenshots`. This is the same test that takes the README screenshots
   (`take_screenshots.sh`); the app is launched with `-screenshotMode`, which replaces the
   database with the bundled example recipes (`ExampleRecipeFiles/<lang>`) and marks the
   yeast braid as favourite.
   Raw screens go to `build/appstore-screenshots/raw/<device>/<lang>/`.
2. `compose.py` scales each raw screen to the exact target size (`plain`), or puts it
   into a device frame on a gradient background with a caption (`framed`), and writes
   an RGB PNG without alpha channel. If a fallback device with a different aspect
   ratio was used, the bottom of the screen is cropped or padded so the status and
   navigation bars stay intact.

## Customising

Everything lives in `config.json`:

- `screens`: captions/subtitles per language; the `id` must match the names used in
  `Back App iOSUITests/ReadmeScreenshots.swift`.
- `style.mode`: `plain` (default) or `framed`; try either with `compose.py --mode framed`.
- `style`: background gradient, text colours, bezel colour and fonts (framed mode).
- `devices.<key>.orientation`: `portrait` (default) or `landscape`.
- `devices`: target sizes, simulator names and the `fallback` device used when no
  matching simulator is installed (e.g. until an iPhone Duo simulator ships with Xcode).

Adding a language: add it to `languages`, add the example recipe texts to
`ReadmeScreenshots.texts` and translations of the captions.

To iterate on the layout without re-running the simulators:

```bash
python3 scripts/screenshots/compose.py
```
