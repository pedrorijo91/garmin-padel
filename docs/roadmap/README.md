# Roadmap: planned features

This folder holds design plans for features that are not built yet. Each plan is meant to be picked up later, by a human developer or a coding agent, without needing the conversation that produced it. Each one includes the user need, the relevant code, the design decisions with reasons, open questions, a test plan and acceptance criteria.

Written 2026-11-16 against `master` at v2.6.0 (`f77f3e7`). Code references use class and function names, not line numbers. If code has moved, search for the name.

| # | Plan | Size | Depends on | GitHub | Status |
|---|------|------|------------|--------|--------|
| 1 | [Switch set format mid-match](01-switch-set-format.md) (final tie-break / super tie / mini set) | S–M | — | [#146](https://github.com/pedrorijo91/garmin-padel/issues/146) | Not started |
| 2 | [Training mode](02-training-mode.md) (free play + scored drills) | M | 1 | — | Not started |
| 3 | [Timed tournament](03-timed-tournament.md) (time-limited sets, breaks) | M–L | 1, 2 (free/break segment) | [#27](https://github.com/pedrorijo91/garmin-padel/issues/27) (closed; "timed tournament" item never built) | Not started |
| 4 | [Serving indicator](04-serving-indicator.md) (team, then player) | team S–M, player M | none (easier after 1) | [#66](https://github.com/pedrorijo91/garmin-padel/issues/66), [#101](https://github.com/pedrorijo91/garmin-padel/issues/101) | Not started |

Update the **Status** column and the plan's own "Status" section when work starts or lands.

## Recommended order

```
1 Switch set format ──► 2 Training mode ──► 3 Timed tournament
        │
        └──(nice to have first)──► 4 Serving indicator (team) ──► 4 (player)
```

1. **Plan 1 first.** It introduces the key refactor: the format of the current set lives in `MatchStatus` and is no longer derived from the fixed config. Plans 2 and 3 are built on it.
2. **Plan 4 (team level)** is independent and can be done at any time. Doing it after plan 1 means standalone tie-breaks are handled from the start.
3. **Plan 2** adds the unscored "free" segment and "end drill".
4. **Plan 3** reuses the free segment as the break between rounds and adds the timer.
5. **Plan 4 (player level)** last.

## The shared idea: a session is a sequence of segments

Today a match is "N sets of one type, plus an optional super-tie decider". All of plans 1–3 need a more general model:

> A session is a sequence of **segments**. Each segment has a **format**: normal set, pro set, mini set, tie-break (7), super tie-break (10), timed set, or free play / break (no score).

- Plan 1 lets the user choose the format of the **next** segment.
- Plan 2 adds the `FREE` format and makes "choose next format" the main way to use the app.
- Plan 3 adds the `TIMED` format and uses `FREE` for breaks.

Keep this in mind when implementing plan 1. Name things so that adding formats later does not need another refactor. For example, use a `SetFormat` constant set in `MatchConfig` (or a new `SetFormats` class), not a boolean like `forceSuperTie`.

## How the code works today (needed context)

Monkey C (Garmin Connect IQ) watch app. `minApiLevel` 2.4.0, about 78 devices in `manifest.xml`.

**Model (`source/model/`)**
- `PadelMatch`: thin facade used by views and delegates. Builds a `MatchEngine` from a `MatchConfig`.
- `MatchConfig`: number of sets (`UNLIMITED_SETS = 20`), set type (normal / pro / mini), super tie on or off, point rule (golden / advantage / silver / star).
- `GameModes`: the presets (Tournament, Tournament super, Pro set, Friendly) mapped to a `MatchConfig`, plus the summary lines shown on the confirm screen.
- `MatchEngine`: owns `MatchStatus` and the undo stack (`MAX_UNDO = 5`, each entry is a full `MatchStatus.copy()`).
  - `getCurrentSetEngine()` picks `decidingSetEngine` (super tie) only when sets are tied with one set left. Otherwise it uses `defaultSetEngine`. **The set format is derived, not stored**, which is what plan 1 changes.
  - `scorePoint()` delegates to the set engine. When a set is won it calls `resetAfterSetFinish()`, which writes the result string, resets games and scores, and applies initial games (mini set 2-2), and then calls `Application.getApp().lapSession()`.
  - Court-change vibration in tie-breaks: every 6 tie points, through `onTieBreakCourtChange()`.
- `SetEngine` (stateless; mutates the `MatchStatus` it is given):
  - `GamesSetEngine(gameEngine, gamesToWin, tieBreakAt, initialP1, initialP2)` is the base of `NormalSetEngine` (6, 6), `ProSetEngine` (9, 8) and `MiniSetEngine` (6, 5, starts 2-2).
  - `SuperTieSetEngine`: first to 10, win by 2, no games.
- `GameEngine` (stateless): Golden, Advantage, Silver, Star point.
- `MatchStatus`: sets, games, point index, tie scores, history strings, unforced errors, deuce revert count. **The constructor is limited to 9 arguments** (older devices such as marqgolfer), so new fields are added with setters and copied in `copy()`. Anything that must survive **undo** has to live here.
- `Sides`: `SIDE_P1 = 0` (us, Up button, top half of the screen), `SIDE_P2 = 1` (them, Down button, bottom half).

**App, views and delegates**
- `GarminpadelApp` (`source/garminpadelApp.mc`): holds the config, match and `ActivityRecording.Session`. `initMatch()` starts the session. `saveSession()` writes FIT developer fields: `game_score` (string, **count 50**), `steps`, `app_version`, `unforced_errors`. Also handles laps, the court-change banner and vibration.
- `ScoreView` + `resources*/layouts/scores.xml`: text labels `setsLabel`, `gamesLabel`, `scoreLabel`, steps/HR, clock. A 1 s `Timer` created in `onLayout` refreshes the view. Instinct devices have their own layout folders.
- `ScoreDelegate`: Up/Down (or tapping the top/bottom half) scores. Enter or long-press opens the Options menu. Back opens the Finish menu. **The Options menu is built twice, in `onHold` and `onKey`**; move it into one helper before adding items.
- `ScoreOptionsMenuDelegate`: undo (with confirmation), unforced error, finish.
- Setup menus: `delegates/menu/*` (game mode → confirm, or custom: sets → set type → super tie → score).

**Tests and CI**
- Unit tests live in `source/tests/` (`(:test)` functions, helpers in `testingUtils.mc`, e.g. `playSet`, `playSetTo6All`).
- CI (`.github/workflows/ci.yml`) builds and runs the tests on **fenix847mm only**, using the `ghcr.io/matco/connectiq-tester` Docker image.
- UI changes must also be checked by hand in the simulator on at least one round device (fenix/forerunner), one rectangular device (venusq2) and one Instinct (black and white, odd layout).

## Constraints that apply to every plan

- **Undo:** any new state that changes during play must be in `MatchStatus` and copied in `copy()`, or undo will silently break.
- **9-argument constructor limit** on `MatchStatus`: use setters.
- **Memory:** older devices (fr245, vivoactive4, marqgolfer, descentmk1) have small app memory. Prefer extending existing classes and parameterizing engines over adding many new classes or resources.
- **Keep the score screen simple.** The maintainer has repeatedly avoided UI that breaks across many devices (see #6 and #66). Prefer drawing relative to `dc` size over per-device layout files.
- **FIT `game_score` is a 50-char string.** Sessions with many segments (plans 2 and 3) will overflow it. See plan 2 for the proposed per-lap field. FIT developer-field size limits must be checked before changing it.
- **Strings:** user-facing text goes in `resources/strings/strings.xml`. Existing menus use some hard-coded strings; new code should prefer resources.
- **README:** update the user-facing "Functionalities", "How to use" and "Match rules reference" sections when a feature ships.
