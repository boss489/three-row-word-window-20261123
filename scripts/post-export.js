// Keep the exported Godot canvas at its native 2:3 ratio while coloring the unused viewport.
const fs = require('node:fs');
const path = require('node:path');
const target = path.join(__dirname, '..', 'docs', 'index.html');
let html = fs.readFileSync(target, 'utf8');
function replaceOnce(from, to) {
  const count = html.split(from).length - 1;
  if (count !== 1) throw new Error(`Expected one export marker, found ${count}: ${from}`);
  html = html.replace(from, to);
}
replaceOnce('background-color: black;', 'background-color: #173e43;');
replaceOnce('touch-action: none;\n}', 'touch-action: none;\n\tmin-height: 100dvh;\n\tdisplay: flex;\n\talign-items: center;\n\tjustify-content: center;\n}');
replaceOnce('#canvas {\n\tdisplay: block;\n}', '#canvas {\n\tdisplay: block;\n\twidth: min(100vw, 66.667dvh) !important;\n\theight: min(150vw, 100dvh) !important;\n}');
replaceOnce('"canvasResizePolicy":2', '"canvasResizePolicy":1');
fs.writeFileSync(target, html);
console.log('Post-export canvas shell applied:', target);
