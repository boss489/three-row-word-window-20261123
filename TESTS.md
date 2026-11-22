# Verification — 2026-11-23

- Godot 4.7.2 headless editor import: passed.
- `godot --headless --path . --script tests/model_test.gd`: 24 assertions, 0 failures. Covers five levels, inverse/identity, success priority and limit, restart/save behavior.
- `godot --headless --path . --script tests/font_test.gd`: 28 visible UI string samples, 0 missing characters with bundled Noto Sans KR.
- Web export: `godot --headless --path . --export-release Web docs/index.html` returned 0; local HTTP returned 200 for index and pack.
- Chrome/Playwright actual WebAssembly/WebGL run at 640×960 and 320×640: title, tutorial, active board, success, failure captured in `qa/`; no JS page/console errors. Desktop keyboard and mobile touch both solved L1 and reached L2 12-move failure. Mobile touch emulation was disabled after testing found duplicate mouse/touch events; retest confirmed active board and success.
- 320px layout: 640×960 design letterboxed to 320×480 within 320×640; arrow targets are 100×94 design units (50×47 CSS px), action buttons wider. Text/UI and overlays inspected; small captions are compact but not clipped. Physical device not tested.
- Manual screenshot review confirmed all named states; no error overlay or missing Korean glyph in inspected screens. `qa/` contains local image evidence. The public URL was also exercised in Chrome desktop/mobile emulation through all five screen types with zero page/console errors, and its six Web assets matched local bytes by SHA-256.
