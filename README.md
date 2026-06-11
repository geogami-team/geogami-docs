# GeoGami documentation

Cross-component documentation for the GeoGami platform. Audience-first: start with the document that matches your role.

## For researchers & study leaders

- **[Platform Overview](PLATFORM_OVERVIEW.md)** — what the platform consists of, how a study flows through it (design → run → analyze → export), what data is recorded, and how access works. **Start here.**
- **[Glossary](GLOSSARY.md)** — definitions of every platform term: games, tasks, tracks, map settings, roles, …
- **[Dashboard User Guide](https://github.com/origami-team/geogami-dashboard/blob/main/docs/USER_GUIDE.md)** — step-by-step guide to analyzing and exporting track data.

## For developers

Each component repository has its own README with setup, configuration, and deployment instructions:

- [geogami](https://github.com/origami-team/geogami) — Angular/Ionic mobile & web client
- [origami-backend](https://github.com/origami-team/origami-backend) — Node/Express + Socket.IO backend
- [geogami-dashboard](https://github.com/origami-team/geogami-dashboard) — R Shiny analytics dashboard
- [geogami-virtual-environment-dev](https://github.com/origami-team/geogami-virtual-environment-dev) — Unity 3D virtual environment

## Planned

- REST API reference (geogami-server)
- Socket.IO event reference (app ↔ server ↔ virtual environment)
- Track JSON / data-model reference (currently: "GeoGami JSON documentation.pdf" in geogami-dashboard)
- Study-leader how-to guides (creating a game, running a virtual session, exporting for R/Python)
