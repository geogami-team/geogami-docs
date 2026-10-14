<p align="center">
  <img src="https://github.com/origami-team/geogami/blob/master/src/assets/icons/icon.png" width="100" alt="GeoGami logo"/>
</p>

<h1 align="center">How-to: Manage the Editor Views (Administrators)</h1>

<p align="center">
  Decide which optional controls the <b>Simple</b> view of the game editor shows, and keep an eye on account and game activity.<br/>
  For authors: <a href="HOWTO_CREATE_A_GAME.md#simple-and-advanced-view">Simple and Advanced view</a> · Background: <a href="GLOSSARY.md">Glossary</a>
</p>

---

## Who can do this

Only accounts with the **`admin`** role. A `contentAdmin` can neither open these pages nor change the configuration (the server refuses the request too). Everybody else only *reads* the configuration, because the editor needs it to decide what to show.

## App management

Administrators see an **App management** card on the app's start page. It opens a page with three tools:

| Tool | What it is for |
|---|---|
| **Users** | List, create, edit and delete accounts; change roles. |
| **Editor visibility** | Choose which optional controls the Simple view shows (this guide). |
| **Audit log** | Who did what: see [The audit log](#the-audit-log). A number on the card and on this tool counts the entries you have not read yet. |

## Editor visibility

The game editor has two views. **Advanced** always shows everything an author is allowed to use. **Simple** shows the essential tools; which *optional* controls it also shows is decided here, once, for **all** users.

1. Open **App management → Editor visibility**.
2. Every control is listed in groups (game save screen, navigation tasks, thematic tasks, Map features dialog, virtual worlds, all tasks), with a short description and the screens where authors meet it. Use the search box to find one.
3. For each optional control choose:
   - **Simple + Advanced** — shown in both views.
   - **Advanced only** — shown only after an author switches to Advanced.
   
   Controls marked **Always shown** (a lock) are essential and cannot be changed.
4. **Preview** shows how many controls (and which) the Simple view will show with your draft.
5. Press **Save**. **Discard changes** drops your edits; **Restore defaults** puts the built-in defaults into the draft (they apply only after you press Save).

### What the defaults are

Everything not listed here is shown in Simple. These are **Advanced only** until you change them:

- **Game (save screen):** map section (boundary), data-sharing consent switch.
- **Navigation tasks:** navigation with text instructions, exploration task, keep the flag on the map, arrival accuracy.
- **Thematic tasks:** the free-task options *text and map marking*, *text and photo* and *answer by drawing*; the direction-task options *arrow* and *photo*; several trials; search area; the *Map features* entry (also for information tasks).
- **Map features dialog:** zoom, map section movement, map rotation, map type, view-direction marker, track recording, street highlight, buffer, landmark highlighting. (The location marker stays in Simple.)
- **Virtual worlds:** avatar start position and direction, avatar speed, disable avatar rotation, environment settings, map size.

### What a change does — and does not do

- **It applies to everyone, at their next editing session.** Someone who is editing a game right now keeps the configuration they started with, so controls never disappear under their hands. Switching between Simple and Advanced always works immediately.
- **It never changes games or tasks.** Hiding a control only hides it in the editor: the stored values stay as they are, they are saved unchanged, and the game plays exactly as before. If an author opens a task that uses a setting Simple hides, the editor says so ("This task uses advanced settings") and offers to switch to Advanced.
- **Two administrators at once.** If someone else saved while you were editing, your save is refused and the page tells you. *Reload latest version* loads their configuration and applies your own changes on top of it; then save again.
- **If the server cannot be reached,** the editor carries on with the last configuration it knew, or the built-in defaults. Advanced is always available.

## The audit log

The audit log (admin only) records sensitive and administrative actions. Entries show the time, who did it, who or what it concerned, a short summary and the IP address. They are kept for 12 months (security alerts are kept indefinitely).

| Entry | When |
|---|---|
| Account created (self-registration) | Someone registers; the account is both actor and subject. |
| Account created (by admin) | An administrator creates an account (the role is shown). |
| Account deleted (by owner / by admin) | An account is deleted. |
| Password changed / reset, email change requested | Account security events. |
| Role changed | A user's role is changed (old → new). |
| Game created | An author saves a new game (name and number of tasks). |
| Game edited | A save changed a game; the entry names the **fields** that changed (for example `name`, `tasks`), never their content. A save that changes nothing leaves no entry. |
| Editor visibility changed | An administrator saved a new configuration (each control: old → new). |
| Rate limit reached | A security alert: too many requests to a protected endpoint. |

!!! note
    Every game save by any author adds an entry, so the unread number can grow quickly on an active installation.

---

**Related:** [REST API Reference — `/editor-visibility` and `/audit`](API_REFERENCE.md#editor-visibility--simpleadvanced-policy) · [Developer Overview](DEVELOPER_OVERVIEW.md)

**Contact:** Spatial Intelligence Lab (SIL), Institute for Geoinformatics, University of Münster — geogami(at)uni-muenster.de — <https://geogami.uni-muenster.de>
