# World Study 01 — The First Horizon

This is an early, browser-based visual study for **Sea Among The Clouds**. It exists to test composition, scale, cloud placement, water colour, and the overall emotional direction before the Unreal Engine implementation.

## Run it

Open `index.html` through a local static web server. Because it uses JavaScript modules, opening the file directly with `file://` may be blocked by browser security rules.

For example, from this folder:

```bash
python -m http.server 8000
```

Then visit `http://localhost:8000`.

The Three.js module is loaded from jsDelivr, so the first run requires an internet connection.

## Controls

- Drag: orbit the camera.
- Scroll: zoom.
- Right-drag: pan.

## Current scope

- Procedural sky gradient and sunlight focal point.
- Animated, low-amplitude water surface.
- Stylized sky-coloured Fresnel reflection approximation.
- Procedural cloud clusters at multiple distances and heights.
- Orbit camera for visual inspection.

## Known limitations

This is a composition prototype, not a physically accurate ocean renderer. It does not yet include true planar or ray-traced reflections, volumetric clouds, a player controller, or Unreal Engine assets. Those belong in the later engine implementation.

## Review questions

1. Does the sea feel vast and calm?
2. Do the clouds feel strangely close to the sea rather than like a normal sky backdrop?
3. Does the horizon communicate scale?
4. Is the palette mysterious and beautiful without becoming too bright or washed out?
