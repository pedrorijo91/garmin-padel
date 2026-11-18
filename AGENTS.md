# AGENTS.md

Instructions for coding agents working in this repo. Most rules below come from review comments the maintainer left on agent-written PRs (#152–#156, Nov 2026) and from what those sessions ran into. Each one was a real round-trip, so follow them on the first pass.

Garmin Connect IQ watch app written in Monkey C. `minApiLevel` 2.4.0, about 78 devices in `manifest.xml`.

## Code map

- **Model** (`source/model/`)
  - `PadelMatch`: a thin facade over `MatchEngine`. Views and delegates call this. It reads the clock and passes `now` in.
  - `MatchConfig`: number of sets, set type, super tie, point rule, the `FORMAT_*` constants and the per-mode flags.
  - `GameModes`: the presets.
  - `MatchEngine`: owns `MatchStatus` and the undo stack (`MAX_UNDO = 5`, each entry a full `MatchStatus.copy()`), plus laps, serving and the current set format.
  - `SetEngine` / `GameEngine`: stateless; they mutate the `MatchStatus` they are given. `SuperTieSetEngine(target)` covers both the super tie (10) and the standalone tie-break (7).
  - `MatchStatus`: all match state.
  - `Sides`: `SIDE_P1` = us = Up = top half; `SIDE_P2` = them = Down = bottom half.
- **App** (`source/garminpadelApp.mc`): the `ActivityRecording` session, laps (`lapSession`), FIT fields (`saveSession`), the banner and vibration.
- **Views and delegates:** `ScoreView` and `ScoreDelegate`. Options menus are built in `ScoreDelegate.pushOptionsMenu()` (with warm-up and training variants) and handled in `ScoreOptionsMenuDelegate`. The setup flow is in `source/delegates/menu/`. `MenuFirstServeDelegate` is the last step and calls `initMatch()`, which is where recording starts.
- **Tests:** `(:test)` functions in `source/tests/`, with helpers in `testingUtils.mc`.

## Build and test

CI ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) builds with strict type checking (`-l 3`) and runs the unit tests on **fenix847mm, fr245, instinct2 and venusq2**. Do the same before every push. A build that passes without `-l 3`, or on one device only, is not enough: #152 went red in CI on a nullable access.

Locally, with the SDK selected in the Garmin SDK Manager:

```bash
SDK="$(cat "$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg")"; SDK="${SDK%/}"
OUT=<scratch dir>   # not ./bin: it isn't gitignored
for d in fenix847mm fr245 instinct2 venusq2; do
  "$SDK/bin/monkeyc" -f monkey.jungle -d $d -o $OUT/t_$d.prg -y <repo root>/developer_key -t -l 3 &&
  "$SDK/bin/monkeydo" $OUT/t_$d.prg $d -t
done
```

- `developer_key` is gitignored and lives only in the main checkout, so worktrees must point at it.
- `monkeydo` needs the simulator running. Start it with `"$SDK/bin/connectiq"`.
- Alternatively, run CI's Docker image per device: `docker run --rm -v "$PWD":/app -w /app -e HOME=/root ghcr.io/matco/connectiq-tester:latest <device> ""`.
- CI uses the `:latest` image on purpose. The release export (`releases/scripts/export.sh`) uses the SDK currently selected in the SDK Manager. Keep that on the latest version.
- Fix compiler warnings in the PR that causes them, even though CI doesn't fail on them.

### Simulator

UI changes must be checked in the simulator on at least one round device (fenix / forerunner), `venusq2` (rectangular) and `instinct2` (black and white, with a sub-screen). Say in the PR what was checked by hand and what wasn't, such as real button presses on a watch. When the maintainer asks to test it themselves, launch the app on **fenix847mm** and hand it over.

Known simulator quirks:
- **App Nap throttles timers** when the simulator is in the background. Bring it to the front before a run: `osascript -e 'tell application id "com.garmin.connectiq.simulator" to activate'`.
- **It exits after a `-t` run that started a recording session.** Relaunch it with `connectiq` before the next run. If a run hangs with an empty log, restart it.
- **Test mode writes no FIT file.** To check laps and fields, run the app itself, save, and parse the FIT file.
- **Laps shorter than about 1 s are merged**, so space out scripted steps.
- **Screenshots fail while the Mac screen is locked** ("could not create image from window"). Report it; don't work around permissions.
- To drive the app, a temporary harness that patches the source for one build is fine. Restore the files afterwards and never commit it.

Check that new text fits on small round screens such as fr255 (260 px). Long menu sub-labels clip at the edge: "Tie / super / mini / set" had to become "TB / ST / mini / set".

## Mistakes reviewers keep catching

### 1. Comments that restate the code, or mention plans and PRs

- Don't comment what the code or the method name already says. #156 had about 15 such comments removed after review, and 2 more were **wrong**: they described behaviour that had changed later in the same PR.
- Keep a comment only when it explains something the code can't show: a platform limit, a byte budget, why undo is cleared at a given point, why a value is passed in rather than read.
- **Never mention plans, design docs, PR numbers or issue numbers in `source/`** (`// plan 2`, `(plan 5)`, `#146`). Those belong in commit messages and PR descriptions.
- Before pushing, reread every comment you added and delete the ones that fail this test.

### 2. Writing a helper that already exists

The maintainer has asked "don't we have this already?" more than once:
- #152: a new "other side" helper. `GameEngine` and `SetEngine` each had a copy already. Now there is one, `Sides.other()`.
- #156: a score-string function duplicated `GarminpadelApp.getScoreString()`. Now there is one, `PadelMatch.getScoreString()`.

Before adding a function, grep `source/` for the concept (side, score string, format, lap, timer, banner, vibration). Extend or move the existing one; don't fork it so tests can call it.

### 3. Too many tests

- Write **one test per rule or behaviour**. Don't test the same path with different values, and don't re-test what other test files already cover (`copy()`, match over, the other first server, and so on).
- #152 went from more tests to 9 after "so many test cases? duplicated scenarios or with little value?". #155 needed a "trim overlapping checks" commit.
- Reuse the helpers in `source/tests/testingUtils.mc` (`playSet`, `playSetTo6All`, `playPointsP1`, ...) instead of adding new ones.
- In unit tests, `Application.getApp().getMatch()` is null: test through a `PadelMatch` you build. A 1-set match with super tie on makes its only set a super tie, so turn super tie off when you need a normal single set.

### 4. README goes into too much detail

The README is for **users** and should stay high level. Reviewers removed sections or sentences in #152 (2×), #155 and #156 (4×): "not needed in the README", "keep this section more high level", "no need to go into training details".
- Add a short paragraph and a screenshot or two at most. Leave out FIT internals, "how results are written", edge cases and the full option lists.
- Implementation details, limitations and decisions go in the PR description.

### 5. Over-engineered UI

"Are we overcomplicating? Isn't there a native way?" (#152, serving indicator). Use the simplest `Dc` primitive (`drawArc`, `fillRectangle`, an existing label). Size it from `dc` rather than adding per-device layouts, and delete clamps or branches nothing needs. Draw in white so it works on black-and-white screens. Prefer fewer steps for the user: Training was changed to start straight from the Game Mode menu, with no summary screen.

### 6. Strict type-check (`-l 3`) failures and Monkey C gotchas

- Members of a nullable value aren't narrowed by `if (x != null)`. `sub.x` on the result of `WatchUi.getSubscreen()` failed on fenix847mm in #152 (and still fails on descentmk1). Read the member into a local, null-check the local, then use it.
- Don't add null checks on fields typed as non-null. They produce `Statement is not reachable` warnings on every device (removed in #153).
- Guard newer APIs with `has` (`if (WatchUi has :getSubscreen)`). Some exist on most devices but not all: `Graphics.createBufferedBitmap` is missing on instinct2.
- Instance methods can't be called statically. Call them on an engine instance.

### 7. Sentinels and timers

Don't use `-1` or sign checks to mean "unset" for new values. Type them `Number or Null` (#154). `System.getTimer()` wraps, so compute elapsed time by plain subtraction. Existing `-1` conventions such as `getServingSide()` and `firstServer` stay as they are.

### 8. FIT and recording limits (the activity can be lost)

- The FIT `game_score` field holds **49 characters** (`:count => 50` includes the terminator). Writing more makes `setData` crash with a System Error that `try/catch` can't catch, and the activity is never saved. Always cut strings with `fitString` from `model/fitUtils.mc`, which cuts at a ` / ` separator so only complete sets are kept (#155).
- Developer fields use IDs 0–5 today (`game_score`, `steps`, `app_version`, `unforced_errors`, `warmup_seconds`, and the per-lap `lap_score` in training). Developer data is limited to 256 bytes per message per app, and the session message uses about 108. Check the budget before adding a field.
- **A lap can't be removed or relabelled once added.** That is why leaving a warm-up or free play clears the undo stack. If undo crosses a lap, don't invent a workaround: document it as a known limitation and ask the maintainer (#156).

### 9. Screenshot churn

#152, #155 and #156 each needed extra "keep only the screenshots the README uses" commits. Get this right the first time:
- Commit to `screenshots/<feature>/` only the images the README references: usually **two fenix847mm shots** are enough to show a feature.
- Screenshots that are only for the PR description: add them in one commit, link them by that commit's SHA (`.../blob/<sha>/screenshots/...?raw=true`), and remove them in the next commit.

## Model rules (break these and undo silently breaks)

- Any state that changes during play lives in `MatchStatus` and is copied in `copy()`. The `MatchStatus` constructor is capped at **9 arguments** (older devices), so add new fields with setters.
- `SetEngine` and `GameEngine` stay stateless. `MatchEngine` never reads the clock: methods that start a segment take `now`.
- Older devices (fr245, vivoactive4, marqgolfer, descentmk1) have little memory. Extend existing classes and parameterise engines rather than adding classes or resources. #155, for example, reused `ScoreOptionsMenuDelegate` for the submenu.
- Add new Options items where the menu is already built (`ScoreDelegate.pushOptionsMenu()` or its variant). Don't build a second menu.
- Gate a feature with a `MatchConfig` flag set by `GameModes` and the custom flow. The UI checks the flag through `PadelMatch`, not a mode name.
- User-facing text goes in `resources/strings/strings.xml`.

## Git and PR workflow

- **Rebase on the latest `origin/master` before opening a PR and before every push.** Re-run the strict build and the tests after the rebase, and push with `--force-with-lease`. State the base commit in the PR body ("Based on `master` at `abc1234`").
- When another branch touches the same files in parallel, keep your changes in small, separate blocks (new methods, an early `return`, one `else if`) so the second PR to merge rebases cleanly.
- One topic per PR. Don't carry unrelated commits from another branch (#152 shipped an unmerged docs commit).
- Update the README and other docs in the same PR as the feature, so master is current when it merges.
- Never run a bare `git stash`: the stash is shared across worktrees and sessions.
- No Dependabot.
- **PR description:** a short high-level summary with one or two screenshots first. Then `<details><summary>` blocks for implementation, decisions, tests (count, `-l 3`, devices), devices checked in the simulator, and open questions / follow-ups.
- **Review comments:** reply in each thread with what changed, the commit SHA and how it was verified. If you didn't change anything, say why. Check bot findings (CodeRabbit) against the code before acting; its "review limit reached" notices need no action.
