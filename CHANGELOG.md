# Changelog

## 1.4

### New

- **The app reopens your last recipe.** If iOS closes the app in the background, you come back to the recipe you were looking at instead of the recipe list. Recipes you deleted in the meantime are not reopened. (#29, #49)

### Fixes

- **Importing recipes on iPad works again.** Opening a recipe file from the Files app could open the app in a new window without importing anything. The same happened when a file launched the app. If a file can't be read, you now get an error message instead of nothing. (#35, #44)
- **Reordering steps next to substeps works.** Dragging a step next to a substep could move the wrong step, or nothing at all. (#37, #43)
- **Durations and start times account for nested substeps.** A step's total duration followed the substep with the longest duration of its own, not the longest chain of substeps. So a short substep with long substeps of its own was left out, and some substeps were scheduled after their parent step. (#48)
- **Fast typing is saved correctly.** Typing quickly in a text field could leave an older value saved, for example "Mis" instead of "Mischen". (#48)
- **New users get the example recipes.** The bundled example recipes were never imported on first launch. They now load in your language, or in English if there are none in your language. (#41)
- Removed trailing periods from the import error messages.

### Under the hood

- Upgraded GRDB from 6 to 7 and followed its migration guide (Sendable record types, concurrency-safe static properties). The database now waits up to 5 seconds when it is busy instead of failing. (#40)
- Moved the Swift package tests to Swift Testing and added more tests. They now cover formatting, the models, database logic, scheduling, export, and string tables that have the same keys in English and German. (#46)
- The UI tests are faster and more reliable. They find controls by accessibility identifier, launch with animations off and a fixed locale, and wait for elements instead of sleeping. A full run now takes about 100 s instead of 160 s. (#46, #48)
- Added `Package.resolved` for the local packages, with REUSE licensing information.

### Project

- Rewrote the README and added tooling to regenerate its screenshots (`take_screenshots.sh`, `frame_screenshots.py`) on current Xcode and iOS versions. (#41, #42)
