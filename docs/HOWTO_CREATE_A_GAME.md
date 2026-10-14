<p align="center">
  <img src="https://github.com/origami-team/geogami/blob/master/src/assets/icons/icon.png" width="100" alt="GeoGami logo"/>
</p>

<h1 align="center">How-to: Create a Game as a Study Instrument</h1>

<p align="center">
  Step-by-step guide for researchers designing a GeoGami game.<br/>
  Background reading: <a href="PLATFORM_OVERVIEW.md">Researcher Overview</a> · <a href="GLOSSARY.md">Glossary</a>
</p>

---

## Before you start

- You need a **verified GeoGami account** — any account can create games (no special role required).
- Decide the two structural choices up front; they can't be changed later without rebuilding the game:
  - **Environment:** real world (outdoor GPS play) or virtual world (Unity 3D environment).
  - **Mode:** single-player or multiplayer (with a fixed number of players).
- Browse the app's **Showroom** first if you're new — it demos the task types, map settings, and virtual worlds you'll be choosing from.

## 1. Start a new game

1. Log in and choose **Create game**.
2. Pick the environment (real / virtual) and mode (single / multiplayer, incl. number of players).
3. **Virtual games:** select the virtual environment the game will play in — a city, building, or landscape (some worlds offer a mirrored variant, useful as a counterbalancing condition). The world choice is stored with the game (`virEnvType`), so participants automatically get the right 3D world.
4. **Real-world games:** center the map on your study area.

## 2. Add tasks

A game is an ordered sequence of tasks; participants play them in order. For each task you choose:

1. **Task family** — see the [Glossary](GLOSSARY.md#task-families) for the full catalogue:
   - **Navigation task** (to flag / with arrow / via text / via photo) — moves the participant to a location.
   - **Thematic task** (self-location, object location, direction determination) — probes a spatial skill at a location.
   - **Free task** — combine any question type with any answer type (quizzes, custom designs).
   - **Information module** — instructions, consent text, or context between tasks; collects no answer.
2. **Question and answer details** — the instruction text shown, target locations/polygons, photos, multiple-choice options, etc.
3. **Behaviour settings** — `feedback` (tell the participant if they were right), `multipleTries` (let them retry until correct), `confirmation` (require an explicit OK), `accuracy` (arrival tolerance in metres for position tasks; default 10 m). These directly shape what your answer data looks like — with `multipleTries` on, expect several answer events per task ([details](TRACK_DATA_REFERENCE.md#answer-payload-shapes-in-on_ok_clicked)).
4. **Map settings** — your experimental controls: map type, rotation mode, position/direction markers, reduced information, buffer, landmark highlighting, … ([full list](GLOSSARY.md#map-settings-experimental-controls)). Every map setting is recorded into the track with each task, so your conditions are always reconstructible from the data.

## Simple and Advanced view

The editor opens in **Simple** view, which shows the essential tools. Use the **Simple / Advanced** switch at the top of a task dialog (and of the save screen) to reveal more options at any time; the (i) button next to it explains the two views. Your choice is remembered for your account on this server, and the same view is used in all dialogs of the game you are editing.

- **Switching is only a change of view.** Nothing you typed, uploaded or selected is lost or reset, and settings that Simple hides keep their values and are saved unchanged.
- **Advanced-only controls** (initially): navigation via text and exploration tasks, keeping the flag, arrival accuracy, most map settings (zoom, movement, rotation, map type, view-direction marker, track recording, street highlight, buffer, landmarks) and the *Map features* entry of thematic/information tasks, some free-task and direction-task options, several trials, the search area, the game boundary and the consent switch on the save screen, and some virtual-world settings (avatar start position and speed, environment settings, map size). Everything else is in both views.
- **Existing games.** If a task or game uses a setting that Simple hides, a notice ("This task uses advanced settings") says so and offers **Review settings**, which switches to Advanced.
- **Who decides.** The administrators of your GeoGami installation choose which optional controls Simple shows; see [How-to: Manage the editor views](HOWTO_MANAGE_THE_EDITOR_VIEWS.md). If you need a control that is not in Simple, switch to Advanced.

## 3. Name, save, pilot

1. Give the game a **name** and **place**. The name appears in track files and exports — a systematic scheme (e.g. `StudyX-ConditionA`) pays off at analysis time.
2. **Save** the game, then **play it through yourself** end to end — check task order, texts, target tolerances, and that the last task ends the game cleanly (the track uploads at the end).
3. For virtual games, also pilot once on the actual study hardware (performance differs between laptops, tablets, and headsets).

The game is saved as a **draft** — only you (and content moderators) can see it, so you can pilot in peace. To collect pilot data you don't need to publish: **share** the draft from the dashboard and play it via the share link. When it's ready for the public, **publish** it from your game list (My games → *Publish*); it then shows up in the public *Published* list. You can unpublish it back to a draft at any time.

## Good to know

- **Editing:** you can edit your games later (Edit game), but don't edit between participants of the same study — the task definition is snapshotted into each track, so mid-study edits create inconsistent data.
- **Deleting is hiding:** deleting a game only sets it invisible; existing tracks remain analyzable.
- **Participant IDs:** GeoGami has no participant-ID field. The **player name entered at game start** is your identifier — decide the scheme before the first session ([why this matters](TRACK_DATA_REFERENCE.md#getting-track-files)).
- **Collaboration:** colleagues who should see the resulting tracks don't need access to the game itself — share the tracks from the dashboard sidebar ([overview](PLATFORM_OVERVIEW.md#accounts-roles-and-data-access)).

**Next:** [Run a virtual session](HOWTO_RUN_A_VIRTUAL_SESSION.md) · [Export & analyze the data](HOWTO_ANALYZE_TRACKS.md)
