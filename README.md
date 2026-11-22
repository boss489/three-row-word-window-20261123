# 세 줄 단어창 / Three-Row Word Window

An independent five-level Korean/English letterpress word puzzle made in Godot 4.7.2. Shift three letter rows until the three vertical words read CAT, DOG, SUN. Each stage has twelve taps. All game logic and artwork render inside Godot; the HTML is only the engine's Web export shell.

Play: choose a row with ↑/↓ or 1/2/3; ←/→ rotate. Mouse/touch use each row's left and right keys. Enter advances. The title offers continuation at the highest unlocked stage; cleared stages can be replayed from the chapter selector. M toggles sound. Save stores unlocked stage, lowest full-run taps and mute, not a mid-stage position.

Local: `godot --headless --editor --path . --quit`; `godot --headless --path . --script tests/model_test.gd`; `godot --headless --path . --export-release Web docs/index.html`. Serve `docs/` via HTTP (not file://) for browser play.
