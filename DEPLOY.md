# Deployment

Target: new public `boss489/three-row-word-window-20261123` repository; GitHub Pages from `main/docs` with `.nojekyll`. Generated Godot Web output is `docs/index.html`, `index.js`, `index.wasm`, `index.pck`, and worklet/icon assets. Build: `godot --headless --path . --export-release Web docs/index.html`.

Verification checklist: repository public; `main` remote SHA equals local HEAD; Pages latest build `built` for SHA; live HTML, JS, WASM, PCK hashes equal local docs; public browser plays. Deployment completion and exact SHA should be recorded only after those reads.
