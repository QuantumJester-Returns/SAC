# Sea Among The Clouds (SAC)

**Build the world first, then build the game that belongs in it.**

Sea Among The Clouds is a 3D game project whose first milestone is to establish a striking, explorable arena: a vast reflective sea beneath an immense sky, with clouds drifting below and around sea level.

## Project direction

The first milestone is a convincing world foundation, not a complete game.

### Milestone 1 — The arena

- Vast, deep-blue sea with subtle surface motion and convincing reflections.
- An enormous sky with atmospheric depth and a strong sense of scale.
- Clouds positioned beneath and around the sea's altitude.
- Natural sunlight and coherent lighting between sky, clouds, and water.
- A playable space suitable for later movement and combat tests.

### Out of scope for this milestone

Do not divert effort into lobbies, dungeons, multiplayer, progression, crafting, inventory, rankings, or finished combat systems. Those depend on the world foundation and should come later.

## Intended technology

- **Unreal Engine 5** — primary game engine.
- **Blender** — modelling and asset preparation.
- **GitHub** — source control and project documentation.
- **GitHub Actions** — lightweight automated repository checks.

The exact engine version, rendering settings, asset licences, and implementation choices should be recorded as they are verified.

## Development principles

1. Build the environment before adding unrelated game systems.
2. Prefer a small number of coherent, high-quality systems over disconnected placeholders.
3. Keep the project reproducible and document setup steps.
4. Verify third-party asset licences before including assets.
5. Make visual and technical decisions through playable prototypes.

## Repository layout

- `Config/` — Unreal project configuration.
- `Content/` — game assets, maps, materials, meshes, and blueprints.
- `Docs/` — milestone specifications and technical decisions.
- `Source/` — C++ game source.
- `Prototype/` — standalone experiments used to validate environment ideas.

## Status

**Current focus:** establish the Milestone 1 arena foundation and validate the visual direction.

This repository is the project home. Update this README as implementation decisions are confirmed; do not present planned features as completed work.
