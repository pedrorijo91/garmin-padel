# AGENTS.md

Instructions for coding agents working in this repo. Most rules below come from review comments the maintainer left on agent-written PRs (#152–#156, Nov 2026). Each one was a real round-trip, so follow them on the first pass.

Garmin Connect IQ watch app written in Monkey C. `minApiLevel` 2.4.0, about 78 devices in `manifest.xml`.

**Read first:** [`docs/roadmap/README.md`](docs/roadmap/README.md) has the code map (model, engines, delegates, views, FIT fields), the shared "session = segments" design and the constraints that apply to every change. Don't repeat that here; keep it current instead.

## Build and test

CI ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) builds with strict type checking (`-l 3`) and runs the `(:test)` unit tests on **fenix847mm, fr245, instinct2 and venusq2**. Run the same thing locally before every push:

```bash
docker run --rm -v "$PWD":/app -w /app -e HOME=/root ghcr.io/matco/connectiq-tester:latest fenix847mm ""
```

Repeat for `fr245`, `instinct2` and `venusq2`. A build that passes without `-l 3`, or only on one device, is not enough: #152 went red in CI on a nullable access that compiled fine elsewhere.

For UI changes, also run the app in the simulator on at least one round device (fenix / forerunner), `venusq2` (rectangular) and `instinct2` (black and white, with a sub-screen). Say in the PR what was checked by hand and what wasn't, such as real button presses on a watch.

## Mistakes reviewers keep catching

### 1. Comments that restate the code, or mention plans and PRs

- Don't comment what the code or the method name already says. #156 had about 15 such comments removed after review, and 2 more were **wrong**: they described behaviour that had changed later in the same PR.
- Keep a comment only when it explains something the code can't show: a platform limit, a byte budget, why undo is cleared at a given point, why a value is passed in rather than read.
- **Never mention roadmap plans, PR numbers or issue numbers in `source/`** (`// plan 2`, `(plan 5)`, `#146`). Those belong in commit messages, PR descriptions and `docs/roadmap/`.
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

### 4. README goes into too much detail

The README is for **users** and should stay high level. Reviewers removed sections or sentences in #152 (2×), #155 and #156 (4×): "not needed in the README", "keep this section more high level", "no need to go into training details".
- Add a short paragraph and a screenshot or two at most. Leave out FIT internals, "how results are written", edge cases and the full option lists.
- Implementation details, limitations and decisions go in the plan's **Implementation notes** in `docs/roadmap/` and in the PR description.

### 5. Over-engineered UI

"Are we overcomplicating? Isn't there a native way?" (#152, serving indicator). Use the simplest `Dc` primitive (`drawArc`, `fillRectangle`, an existing label), size it from `dc` rather than adding per-device layouts, and delete clamps or branches nothing needs. Draw in white so it works on black-and-white screens.

### 6. Strict type-check (`-l 3`) failures

- Members of a nullable value aren't narrowed by `if (x != null)`. `sub.x` on the result of `WatchUi.getSubscreen()` failed on fenix847mm in #152 (and still fails on descentmk1). Read the member into a local, null-check the local, then use it.
- Don't add null checks on fields typed as non-null. They produce `Statement is not reachable` warnings on every device (removed in #153).
- Guard newer APIs with `has` (`if (WatchUi has :getSubscreen)`).

### 7. Sentinels and timers

Don't use `-1` or sign checks to mean "unset" for new values. Type them `Number or Null` (#154). `System.getTimer()` wraps, so compute elapsed time by plain subtraction. Existing `-1` conventions such as `getServingSide()` and `firstServer` stay as they are.

### 8. FIT and recording limits (the activity can be lost)

- The FIT `game_score` field holds **49 characters**. Writing more makes `setData` crash with a System Error that `try/catch` can't catch, and the activity is never saved. Always cut with `fitString` from `model/fitUtils.mc`, which cuts at a ` / ` separator so only complete sets are kept (#155).
- Developer data is limited to 256 bytes per message per app. Check the budget before adding a field. The current IDs and sizes are in the roadmap README.
- **A lap can't be removed or relabelled once added.** If undo crosses a lap, don't invent a workaround: document it as a known limitation and ask the maintainer (#156, question 8).

### 9. Screenshot churn

#152, #155 and #156 each needed extra "keep only the screenshots the README uses" commits. Get this right the first time:
- Commit to `screenshots/<feature>/` only the images the README references (usually fenix847mm).
- Screenshots that are only for the PR description: add them in one commit, link them by that commit's SHA (`.../blob/<sha>/screenshots/...?raw=true`), and remove them in the next commit.
- Don't commit the temporary simulator harness used to take them.

## Model rules (break these and undo silently breaks)

- Any state that changes during play lives in `MatchStatus` and is copied in `copy()`. The `MatchStatus` constructor is capped at **9 arguments** (older devices), so add new fields with setters.
- `SetEngine` and `GameEngine` are stateless. `MatchEngine` never reads the clock: `PadelMatch` passes `now` in.
- Older devices (fr245, vivoactive4, marqgolfer, descentmk1) have little memory. Extend existing classes and parameterise engines rather than adding classes or resources. #155, for example, reused `ScoreOptionsMenuDelegate` for the submenu.
- Add new Options items in `ScoreDelegate.pushOptionsMenu()` (or the warm-up / training variant). Don't build a second menu.
- User-facing text goes in `resources/strings/strings.xml`.
- Sides: `Sides.SIDE_P1` = us = Up = top half; `SIDE_P2` = them = Down = bottom half.

## Product decisions: ask, don't decide silently

When a choice is the maintainer's to make (a default value, what happens on undo, whether to store a field), build the most reasonable option and list it under **"Questions for you"** in the PR description. Give the option you built, the alternative, and the exact place to flip it (e.g. `MenuWarmUpDelegate.WARM_UP_DEFAULT`). Once answered, record the decision in the PR and in the roadmap plan. PRs #154 and #156 are good examples.

## PR workflow

- **Rebase on the latest `origin/master` before opening a PR and before every push**, and state the base commit in the PR body ("Based on `master` at `abc1234`").
- One topic per PR. Don't carry unrelated commits from another branch (#152 shipped an unmerged roadmap commit).
- PR description, in the style of #154–#156: a short summary with screenshots, then `<details>` sections for implementation, tests (count, `-l 3`, devices), devices checked in the simulator, and open questions / follow-ups.
- When shipping a roadmap plan, update its **Status** and **Implementation notes**, and the status column in `docs/roadmap/README.md`.
- Reply to each review comment in its thread: what changed, the commit SHA, and how it was verified. If you didn't change anything, say why. Check bot findings (CodeRabbit) against the code before acting on them.
