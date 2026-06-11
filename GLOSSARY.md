<h1 align="center">GeoGami — Glossary</h1>

<p align="center">
  The domain vocabulary of the GeoGami platform, written for researchers and study leaders.<br/>
  See the <a href="PLATFORM_OVERVIEW.md">Platform Overview</a> for how these pieces fit together.
</p>

---

## Core concepts

| Term | Definition |
|---|---|
| **Game** | A study instrument: an ordered sequence of **tasks** authored in the GeoGami app, played in the real world or a virtual world, in single-player or multiplayer mode. Games belong to the account that created them. |
| **Task** | One step of a game. Every task pairs a **question type** (what the participant sees) with an **answer type** (what they must do) and optional **map settings**. Tasks are either **navigation tasks** or **thematic tasks**; an **information** module can additionally show hints, rules, or context without requiring an answer. |
| **Track** (also *track session*) | The complete recording of one participant's play-through of a game: route (**waypoints**), task **events**, **answers**, photos, and timestamps. One participant run = one track. Tracks are stored on the GeoGami server and analyzed in the dashboard. |
| **Waypoint** | A single recorded position along the participant's route — GPS-based in real-world games, avatar-based in virtual games. |
| **Event** | A timestamped record of something happening during play, e.g. a task being shown or an answer being submitted. Events make per-task timing analysis possible. |
| **Session** | In dashboard terminology, the same as a track: one loaded participant run. The dashboard can load and compare multiple sessions of the same game. |

## Task families

| Term | Definition |
|---|---|
| **Navigation task** | Directs the participant to a new location. Variants differ in how the destination is communicated: **navigation to flag** (destination marker on the map), **navigation with arrow** (directional arrow), **navigation via text** (verbal instruction), **navigation via photo** (picture of the destination). |
| **Thematic task** | A location-bound task probing a specific spatial skill: **self-location** ("Where are you? Tap the map."), **object location** (find/identify an object), **direction determination** (indicate or match a viewing direction), or a **free task**. |
| **Free task** | A thematic task in which the game creator freely combines any question type with any answer type — used to build quizzes and custom challenges. |
| **Information module** | A task-like step that only presents text, images, or instructions to the participant; no answer is collected. |

## Questions, answers, evaluation

| Term | Definition |
|---|---|
| **Question type** | How a task is posed to the participant: plain text, text with a photo, with a map feature, with a target flag, with a direction arrow, etc. |
| **Answer type** | What the participant must do to respond: take a **position** (walk/move there), pick a **map point**, indicate a **direction** (by turning or by drawing on the map), take a **photo**, choose a **multiple-choice** option, enter **text** or a **number**, or **draw** on the map. |
| **Evaluation** | The automatic scoring rule attached to a task, e.g. *distance to target point*, *point in polygon*, *direction error*, *multiple-choice correctness* — or none (e.g. for photo answers, which are evaluated manually). Evaluation results appear in the dashboard tables and statistics. |

## Map settings (experimental controls)

Per-task settings that control what spatial information the participant gets — the main way to manipulate task difficulty and isolate spatial skills:

| Term | Definition |
|---|---|
| **Map type** | The base map shown: standard, satellite, 3D, blank, or combinations (e.g. satellite swipe, on-demand variants). |
| **Map rotation** | Whether the map can rotate: manual, automatic (heading-up), automatic on demand, or fixed to north. |
| **Map section / zoom** | Whether the visible extent is movable, auto-centered, or static, and whether zoom is manual or locked to the task/game extent. |
| **Reduced information** | Strips non-essential detail from the map to test orientation under minimal-information conditions. |
| **Buffer** | Reveals only a circular area (configurable 20–100 m diameter) of the map around the participant; the rest stays hidden. |
| **Location marker** | Whether the participant's own position is shown on the map: on, on demand, only at task start, or off. |
| **View-direction marker** | Same modes as the location marker, but for the device's current heading. |
| **Highlight landmarks / street section** | Visually emphasizes landmarks near the destination or the destination's street segment. |
| **Track recording scope** | Whether the route is recorded for the whole game, only the current task, or the current and next task. |

## Environments & modes

| Term | Definition |
|---|---|
| **Real-world game** | Played outdoors on a smartphone; position and heading come from GPS and compass. |
| **Virtual game** | Played indoors or remotely: the participant steers an avatar through the Unity-based **virtual environment** while the GeoGami app serves as the map controller. Identical task catalogue and data format as real-world games. |
| **Virtual environment (VE)** | The Unity 3D companion application (browser or desktop) providing virtual cities, buildings, and landscapes for virtual games. |
| **5-digit code** | The pairing code shown when starting a virtual game in the app; entering it in the virtual environment connects both to the same room on the server, enabling live avatar synchronization. |
| **Multiplayer** | Several participants playing the same game simultaneously, with real-time synchronization via the server. Available in both environments. |
| **Single-player** | One participant per game run — the default for most studies. |

## Platform & access

| Term | Definition |
|---|---|
| **GeoGami app** | The mobile/web client (iOS, Android, browser) used to author games and to play them. |
| **GeoGami server** | The central backend storing accounts, games, and tracks, and coordinating real-time play. Study leaders normally never interact with it directly. |
| **Dashboard** | The browser-based analytics tool for inspecting, comparing, and exporting tracks. Opened from the app's evaluate section. See the [Dashboard User Guide](https://github.com/geogami-team/geogami-dashboard/blob/HEAD/docs/USER_GUIDE.md). |
| **Role** | An account's permission level. Everyone can create and play games; viewing tracks requires an elevated role — **`scholar`** (researchers), **`trackAccess`** (evaluation-only access), **`contentAdmin`** / **`admin`** (platform administration). Roles are assigned by administrators. |
| **Sharing** | Granting other registered GeoGami users (by email) access to one of your games' tracks, managed from the dashboard sidebar. Shared games appear in the recipients' dashboards; the creator can revoke access at any time. |
| **Showroom** | A section of the app with demo maps, tasks, and virtual worlds — useful for previewing features before designing a study. |
| **Handbook** | The in-app help section for players. |
