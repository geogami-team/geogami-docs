<p align="center">
  <img src="https://github.com/origami-team/geogami/blob/master/src/assets/icons/icon.png" width="100" alt="GeoGami logo"/>
</p>

<h1 align="center">GeoGami — Track Data Reference</h1>

<p align="center">
  The structure of GeoGami track JSON files, for researchers analyzing exported data in R, Python, or any other tool.<br/>
  New to the platform? Read the <a href="PLATFORM_OVERVIEW.md">Researcher Overview</a> first.
</p>

---

A **track** is the complete recording of one participant's play-through of a game. This document describes every field in a track JSON file. It was written against the GeoGami app v4.x and verified against the code that produces the files (the app's `TrackerService`) — the field tables below describe what is actually written, not just what the database schema allows.

## Table of contents

- [Getting track files](#getting-track-files)
- [Top-level structure](#top-level-structure)
- [Multiplayer tracks](#multiplayer-tracks)
- [`waypoints` — the recorded route](#waypoints--the-recorded-route)
- [`events` — actions and answers](#events--actions-and-answers)
- [The `task` snapshot inside events](#the-task-snapshot-inside-events)
- [`device` — the recording device](#device--the-recording-device)
- [Analysis recipes](#analysis-recipes)
- [Caveats and gotchas](#caveats-and-gotchas)

---

## Getting track files

| Method | How |
|---|---|
| **Dashboard (recommended)** | Open the dashboard from the app's evaluate page, select a game and sessions, then **Download** in the sidebar — you get a zip of the raw JSON files. |
| **On-device copy** | The app also saves every finished track locally on the player's device at `Documents/origami/tracks/<gameName>-<startTime>.json`. Useful as a backup if the upload failed. |
| **REST API** | `GET /track/gametracks/:gameId` (all tracks of a game) or `GET /track/:trackId` (single track), JWT-authenticated with an elevated role. |

**File naming and participant IDs.** Files are named from the game name, player name(s), and start timestamp (e.g. `Spiel 1_Girls power !!!!!_2025-04-14T12_44_04.375Z.json`). There is **no dedicated participant ID** in the data — the file name (or the `players` array plus `start` time) is the conventional participant identifier. If your study needs clean participant IDs, encode them in the player name participants enter at game start.

## Top-level structure

```jsonc
{
  "_id": "66602444e939ff001db342be",     // track ID (MongoDB ObjectId)
  "game": "665c4349e939ff001db33933",    // ID of the played game
  "name": "Spiel 1",                     // game name
  "start": "2024-06-05T08:24:34.615Z",   // ISO 8601, game started
  "end":   "2024-06-05T08:39:31.795Z",   // ISO 8601, game finished
  "device": { ... },                     // see "device" section
  "waypoints": [ ... ],                  // see "waypoints" section
  "events": [ ... ],                     // see "events" section
  "answers": null,                       // ALWAYS null — answers live inside events!
  "players": ["Girls power !!!!!"],      // player name(s) entered at game start
  "playersCount": 1,
  "isMultiplayerGame": true,             // only present for multiplayer tracks
  "createdAt": "...", "updatedAt": "...",// server-side timestamps
  "__v": 0                               // MongoDB internal, ignore
}
```

> ⚠️ The top-level `answers` field is always `null`. The actual answers are recorded as **events** (`ON_OK_CLICKED`, `PHOTO_SELECTED`, `MULTIPLE_CHOICE_SELECTED`) — see below.

## Multiplayer tracks

In a multiplayer game all players share **one** track document and `isMultiplayerGame` is `true`. Four fields then become *arrays indexed by player number* (player 1 at index 0, and so on):

| Field | Single-player | Multiplayer |
|---|---|---|
| `players` | `["name"]` | `["name1", "name2", …]` |
| `waypoints` | array of waypoint objects | array **of arrays** of waypoint objects, one per player |
| `events` | array of event objects | array **of arrays** of event objects, one per player |
| `device` | one device object | array of device objects, one per player |

Always check `isMultiplayerGame` before parsing: a script written for single-player files will silently mis-read a multiplayer file (it would treat each player's array as one "waypoint").

## `waypoints` — the recorded route

Waypoints are recorded continuously while a task is active: on **every geolocation update** in real-world games, and at most **once per second** in virtual games. Each waypoint:

| Field | Type | Meaning |
|---|---|---|
| `timestamp` | string (ISO 8601) | When the waypoint was recorded |
| `position` | object | The player's position — see below |
| `mapViewport` | object | What the map showed at that moment — see below |
| `compassHeading` | number | Device compass heading in degrees from north (avatar heading in virtual games) |
| `interaction.panCount` | int | Map pans by the user since the task started |
| `interaction.zoomCount` | number | Zoom changes by the user since the task started |
| `interaction.rotation` | number | Accumulated device/avatar rotation in degrees since the task started (heading changes > 15° are summed) |
| `taskNo` | int | Index of the task being played |
| `taskCategory` | string | `"nav"` (navigation), `"theme"` (thematic), or `"info"` (information) |

**`position`** is a standard geolocation reading:

```jsonc
{
  "timestamp": 1717575874615,            // epoch milliseconds (0 in virtual games!)
  "coords": {
    "latitude": 51.969,  "longitude": 7.596,
    "altitude": 98.3,                    // metres
    "accuracy": 5.1,                     // metres (GPS accuracy)
    "altitudeAccuracy": 8.0,
    "heading": 214.4,                    // movement direction, degrees
    "speed": 1.32                        // m/s
  }
}
```

**`mapViewport`** captures the visible map: `bounds` (`_sw`/`_ne` corners with `lng`/`lat`), `center` (`lng`/`lat`), `zoom`, `bearing` (map rotation in degrees), and `pitch` (camera tilt in degrees). Together with `interaction`, this lets you reconstruct not only where the participant was but what map information they had.

> **Virtual games:** positions come from the Unity avatar, not GPS. The Unity scene coordinates are converted to pseudo lat/lng (`lat = z / 111200`, `lng = x / 111000`), `position.timestamp` is always `0` (use the waypoint's own `timestamp` instead), and the GPS-specific fields (`accuracy`, `altitude`, `speed`, …) are absent or meaningless.

## `events` — actions and answers

Events are discrete actions. Every event shares a common envelope — the same `timestamp`, `position`, `mapViewport`, and `compassHeading` fields as waypoints, plus:

| Field | Type | Meaning |
|---|---|---|
| `type` | string | Event type — see table below |
| `task` | object | **Full snapshot of the active task definition** (see next section); absent before the first task starts |
| `interaction` | object | Same counters as waypoints, but the rotation field is named `rotationCount` here |
| *(type-specific fields)* | | See below |

### Event types

| `type` | When | Extra fields |
|---|---|---|
| `INIT_GAME` | Once, when the game starts | — |
| `INIT_TASK` | Each time a new task is shown — **use these to segment the track into tasks** | — |
| `ON_MAP_CLICKED` | Player tapped the map | `clickPosition` (`latitude`/`longitude`), `clickDirection`, `map` (map type) |
| `ON_OK_CLICKED` | Player submitted an answer with the OK button | `correct` (boolean), `answer` (shape depends on the task's answer type — see below) |
| `PHOTO_SELECTED` | Player chose a photo in a multiple-choice photo task | `answer`, `correct` |
| `MULTIPLE_CHOICE_SELECTED` | Player chose a text option | `answer`, `correct` |
| `WAYPOINT_REACHED` | Player arrived at a navigation target | — |
| `FINISHED_GAME` | Once, when the game ends | — |

### `answer` payload shapes (in `ON_OK_CLICKED`)

The `answer` object depends on the task's **answer type** (`task.answer.type`):

| Answer type | `answer` contains | `correct` means |
|---|---|---|
| `POSITION` | `target` (`[lng, lat]` of the goal), `position` (full position object), `distance` (metres to target) | Distance ≤ the task's `settings.accuracy` (default **10 m**) |
| `MAP_POINT` (self-location) | `clickPosition` (`[lng, lat]`), `distance` (metres from the player's true position) | Distance below the arrival threshold |
| `MAP_POINT` (object location) | `clickPosition` | Click inside the task's target polygon |
| `DIRECTION` | `compassHeading` (degrees) | Within **30°** of the target bearing |
| `MAP_DIRECTION` | `clickDirection` (degrees drawn on the map) | Within **30°** of the reference direction (photo bearing or actual heading) |
| `MULTIPLE_CHOICE` | `selectedPhoto` | The chosen photo is the correct one |
| `MULTIPLE_CHOICE_TEXT` | `selectedChoice` | The chosen option is the correct one |
| `NUMBER` | `numberInput` | Equals the task's stored solution |
| `TEXT` | `text` | Always `true` if non-empty (free text is not auto-scored) |
| `PHOTO` | `photo` (URL of the uploaded image on the GeoGami server) | Always `true` if a photo was taken (manual scoring) |

A failed/empty submission is still logged (`correct: false` with `undefined`/`null` payload fields), and with `multipleTries` enabled a single task can have several `ON_OK_CLICKED` events — usually you want the **last** one per task, or all of them if you study error patterns.

## The `task` snapshot inside events

Every event carries the full definition of the task that was active, so each track is self-contained (you don't need the game definition to analyze it):

| Field | Meaning |
|---|---|
| `_id`, `name` | Task ID and name |
| `category` | `"nav"`, `"theme"`, or `"info"` |
| `type` | Subtask type, e.g. `"nav-flag"`, `"theme-loc"`, `"theme-object"`, `"theme-direction"`, `"free"` |
| `question` | `type` (e.g. `TEXT`, `MAP_FEATURE_PHOTO`, …), `text` (the instruction shown), plus type-specific content (photos, geometry, direction) |
| `answer` | `type` (e.g. `POSITION`, `MAP_POINT`, …), `mode`, and for position tasks the target as a GeoJSON feature (`position.geometry.coordinates`) |
| `evaluate` | Which evaluation rule applies |
| `settings` | `feedback`, `multipleTries`, `confirmation`, `accuracy` (arrival tolerance in metres), `showMarker`, `keepMarker`, `keepDrawing`, `drawPointOnly` |
| `mapFeatures` | The map configuration during the task: `zoombar`, `pan`, `rotation`, `material` (map style), `position` / `direction` (marker modes), `track` / `keepTrack` (route display), `streetSection`, `reducedInformation`, `landmarks`, `reducedMapSectionDiameter`, `swipeLayer`/`switchLayer` (virtual worlds) |
| `virEnvType`, `isVEBuilding`, `floor`, `initialFloor` | Virtual-environment specifics (which world/building/floor) |

The `mapFeatures` block is the record of your **experimental conditions** — when comparing tasks across participants, read it from the data instead of trusting your memory of the game design.

## `device` — the recording device

```jsonc
{
  "model": "iPad",  "platform": "ios",
  "operatingSystem": "ios",  "osVersion": "16.6",
  "isVirtual": false,                    // true = emulator/simulator
  "appName": "GeoGami",  "appVersion": "4.0.0",  "appBuild": "1",
  "appId": "com.ifgi.geogami",
  "device_name": "iPad",  "device_manufacturer": "Apple"
}
```

Useful for filtering (e.g. exclude simulator runs via `isVirtual`) and for reporting the apparatus in publications.

## Analysis recipes

- **Segment into tasks:** split the `events` array at `INIT_TASK` events; everything until the next `INIT_TASK` belongs to that task. Waypoints carry `taskNo` directly.
- **Task duration:** time between an `INIT_TASK` and the last `ON_OK_CLICKED` / `WAYPOINT_REACHED` before the next `INIT_TASK`.
- **Route length:** sum of haversine distances between consecutive waypoints of a task (filter by `taskNo`; consider dropping points with poor `coords.accuracy` first).
- **Final answer per task:** the last answer-bearing event (`ON_OK_CLICKED`, `PHOTO_SELECTED`, `MULTIPLE_CHOICE_SELECTED`) within the task segment.
- **Map-interaction effort:** `interaction` counters reset at each task start, so the values at the task's last waypoint are per-task totals.
- **Photos:** the `photo` field in answers is a URL on the GeoGami server; the dashboard's *Pictures* tab downloads them, or fetch them directly while your session token is valid.

## Caveats and gotchas

- `answers` at the top level is always `null` — answers are inside `events`.
- Multiplayer files nest `waypoints`/`events`/`device` one level deeper (per player). Check `isMultiplayerGame` first.
- In virtual games, coordinates are pseudo lat/lng derived from Unity scene units and `position.timestamp` is `0`; distances computed from them are in "virtual metres" via the same conversion, comparable within a world but not to real-world GPS quality.
- `interaction.zoomCount` may be fractional (the app halves the raw counter to compensate for double-fired zoom events).
- The rotation counter is `rotation` in waypoints but `rotationCount` in events; it accumulates only heading changes larger than 15°.
- Direction correctness uses a fixed ±30° threshold; position correctness uses the task's `settings.accuracy` (default 10 m) — relevant when comparing error magnitudes to the `correct` flag.
- Tracks of aborted games may lack `FINISHED_GAME` and `end` may equal the moment the app gave up, not a task completion.

---

**Related:** [Researcher Overview](PLATFORM_OVERVIEW.md) · [Glossary](GLOSSARY.md) · [Dashboard User Guide](https://github.com/geogami-team/geogami-dashboard/blob/HEAD/docs/USER_GUIDE.md)

**Contact:** Spatial Intelligence Lab (SIL), Institute for Geoinformatics, University of Münster — geogami(at)uni-muenster.de — <https://geogami.ifgi.de>
