extends Node2D

const Model = preload("res://model.gd")
const INK = Color("173e43")
const PAPER = Color("f4ebd6")
const CREAM = Color("fff8e7")
const CORAL = Color("d77b61")
const GOLD = Color("c29244")
const AQUA = Color("5c9d97")
var font: Font = preload("res://assets/NotoSansKR.ttf")
var model = Model.new()
var screen := "TITLE"
var selected_row := 0
var tutorial_moved := false
var chapter := 0
var previous_screen := "PLAYING"
var anim_row := -1
var anim_time := 0.0
var anim_dir := 0
var tone_player: AudioStreamPlayer

func _ready() -> void:
    load_save()
    chapter = model.unlocked
    tone_player = AudioStreamPlayer.new()
    add_child(tone_player)
    queue_redraw()

func _process(delta: float) -> void:
    if anim_time > 0:
        anim_time = maxf(0.0, anim_time - delta)
        queue_redraw()

func save_progress() -> void:
    var file := FileAccess.open("user://word_window.json", FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify(model.save_data()))

func load_save() -> void:
    if FileAccess.file_exists("user://word_window.json"):
        var file := FileAccess.open("user://word_window.json", FileAccess.READ)
        if file != null:
            var parsed = JSON.parse_string(file.get_as_text())
            if parsed is Dictionary:
                model.load_data(parsed)

func start_level(index: int) -> void:
    model.reset_level(index)
    selected_row = 0
    screen = "PLAYING"
    queue_redraw()

func advance() -> void:
    if screen == "TITLE":
        screen = "TUTORIAL"
        tutorial_moved = false
    elif screen == "TUTORIAL":
        if tutorial_moved:
            start_level(chapter)
            return
    elif screen == "LEVEL_CLEAR":
        start_level(model.level + 1)
        return
    elif screen == "SUCCESS":
        chapter = 0
        start_level(0)
        return
    elif screen == "FAILURE":
        start_level(model.level)
        return
    elif screen == "RESTART":
        start_level(model.level)
        return
    queue_redraw()

func rotate_row(row: int, direction: int) -> void:
    if screen == "TUTORIAL":
        if row != 0:
            return
        tutorial_moved = true
        model.offsets[0] = posmod(model.offsets[0] + direction, 3)
    elif screen == "PLAYING":
        var result: String = model.rotate(row, direction)
        if result != "PLAYING":
            screen = result
            save_progress()
    else:
        return
    selected_row = row
    anim_row = row
    anim_dir = direction
    anim_time = 0.16
    tone(440.0 if direction < 0 else 520.0)
    queue_redraw()

func tone(hz: float) -> void:
    if model.mute:
        return
    var pcm := PackedByteArray()
    var samples := 1700
    for n in samples:
        var fade := float(samples - n) / samples
        var value := int(sin(TAU * hz * n / 22050.0) * 3600.0 * fade)
        pcm.append(value & 255)
        pcm.append((value >> 8) & 255)
    var wav := AudioStreamWAV.new()
    wav.format = AudioStreamWAV.FORMAT_16_BITS
    wav.mix_rate = 22050
    wav.stereo = false
    wav.data = pcm
    tone_player.stream = wav
    tone_player.play()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        var code: Key = event.keycode
        if code == KEY_M:
            model.mute = not model.mute
            save_progress()
        elif screen == "PLAYING" or screen == "TUTORIAL":
            if code == KEY_UP:
                selected_row = posmod(selected_row - 1, 3)
            elif code == KEY_DOWN:
                selected_row = posmod(selected_row + 1, 3)
            elif code >= KEY_1 and code <= KEY_3:
                selected_row = code - KEY_1
            elif code == KEY_LEFT:
                rotate_row(selected_row, -1)
            elif code == KEY_RIGHT:
                rotate_row(selected_row, 1)
            elif code == KEY_ENTER or code == KEY_KP_ENTER:
                advance()
            elif code == KEY_ESCAPE:
                previous_screen = screen
                screen = "RESTART"
        elif code == KEY_ENTER or code == KEY_KP_ENTER:
            advance()
        elif code == KEY_ESCAPE and screen == "RESTART":
            screen = previous_screen
        queue_redraw()
    elif (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or (event is InputEventScreenTouch and event.pressed):
        var p: Vector2 = event.position
        if screen == "PLAYING" or screen == "TUTORIAL":
            for r in 3:
                var y := 422.0 + r * 114.0
                if p.y >= y and p.y <= y + 94:
                    if p.x >= 30 and p.x <= 135:
                        rotate_row(r, -1)
                        return
                    if p.x >= 505 and p.x <= 610:
                        rotate_row(r, 1)
                        return
                    selected_row = r
            if screen == "TUTORIAL" and tutorial_moved and p.y >= 842:
                advance()
                return
            if screen == "PLAYING" and p.y >= 842 and p.x < 330:
                previous_screen = screen
                screen = "RESTART"
            elif screen == "PLAYING" and p.y >= 842 and p.x >= 330:
                model.mute = not model.mute
                save_progress()
        elif screen == "TITLE":
            if p.y >= 640 and p.y < 764:
                advance()
            elif p.y >= 764 and p.y < 865:
                chapter = posmod(chapter + 1, model.unlocked + 1)
            elif p.y >= 865:
                model.mute = not model.mute
                save_progress()
        elif screen == "TUTORIAL" and tutorial_moved:
            advance()
        elif screen == "RESTART":
            if p.y >= 430 and p.y < 545:
                start_level(model.level)
            elif p.y >= 545 and p.y < 660:
                model.cumulative = 0
                start_level(0)
            elif p.y >= 660:
                screen = previous_screen
        else:
            advance()
        queue_redraw()

func block(x: float, y: float, w: float, h: float, color: Color, edge: Color = INK) -> void:
    draw_rect(Rect2(x + 5, y + 7, w, h), Color(0.1, 0.2, 0.2, 0.15))
    draw_rect(Rect2(x, y, w, h), color)
    draw_rect(Rect2(x, y, w, h), edge, false, 3)
    draw_line(Vector2(x + 9, y + 9), Vector2(x + 27, y + 9), edge, 2)
    draw_line(Vector2(x + w - 27, y + h - 9), Vector2(x + w - 9, y + h - 9), edge, 2)

func label(text: String, x: float, baseline: float, size: int = 24, color: Color = INK, centered := false) -> void:
    var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
    draw_string(font, Vector2(x - width * 0.5 if centered else x, baseline), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func button(text: String, x: float, y: float, w: float, h: float, fill: Color = CREAM, size: int = 27) -> void:
    block(x, y, w, h, fill)
    label(text, x + w * 0.5, y + h * 0.5 + size * 0.34, size, INK, true)

func ornament(x: float, y: float, radius: float) -> void:
    draw_arc(Vector2(x, y), radius, -PI, 0, 16, INK, 3)
    draw_line(Vector2(x - radius, y), Vector2(x + radius, y), INK, 3)
    draw_circle(Vector2(x, y - radius * 0.5), radius * 0.15, GOLD)
    for i in 5:
        var a := PI * (float(i + 1) / 6.0) + PI
        draw_line(Vector2(x, y - radius * 0.5) + Vector2(cos(a), sin(a)) * radius * 0.22, Vector2(x, y - radius * 0.5) + Vector2(cos(a), sin(a)) * radius * 0.32, GOLD, 2)

func backdrop() -> void:
    draw_rect(Rect2(0, 0, 640, 960), INK)
    for i in 16:
        draw_line(Vector2(0, i * 64 + 15), Vector2(640, i * 64 - 20), Color("31575a"), 1)
    block(17, 20, 606, 917, PAPER)
    draw_rect(Rect2(31, 34, 578, 889), INK, false, 2)
    for i in 7:
        var xx := 46.0 + i * 91
        draw_line(Vector2(xx, 51), Vector2(xx + 13, 51), GOLD, 3)
        draw_line(Vector2(xx, 909), Vector2(xx + 13, 909), GOLD, 3)
    ornament(320, 152, 77)

func _draw() -> void:
    backdrop()
    if screen == "TITLE":
        draw_title()
    else:
        draw_board()
        if screen == "RESTART":
            overlay("다시 인쇄할까요?", "현재 판을 처음부터 시작합니다", ["현재 판 다시", "처음부터", "돌아가기"])
        elif screen == "LEVEL_CLEAR":
            overlay("인쇄 성공!", "다음 창으로 이어집니다", ["다음 판 →"])
        elif screen == "FAILURE":
            overlay("잉크가 다했어요", "12번 안에 세 단어를 맞춰 보세요", ["다시 인쇄 →"])
        elif screen == "SUCCESS":
            overlay("다섯 창 완성!", "총 %d번의 이동 · 최고 %d번" % [model.cumulative, model.best], ["처음부터 →"])

func draw_title() -> void:
    label("세 줄 단어창", 320, 275, 56, INK, true)
    label("THREE-ROW WORD WINDOW", 320, 315, 19, AQUA, true)
    for c in 3:
        block(82 + c * 164, 356, 145, 153, CREAM)
        label(["C", "D", "S"][c], 154 + c * 164, 447, 78, INK, true)
        label(["CAT", "DOG", "SUN"][c], 154 + c * 164, 482, 20, GOLD, true)
    label("세 행을 돌려 세로 단어를 완성하세요", 320, 579, 25, INK, true)
    button("시작하기  →", 82, 645, 476, 110, CORAL, 36)
    button("이어갈 판  %d / 5" % (chapter + 1), 82, 773, 476, 88, CREAM, 27)
    label("소리 %s   ·   M 키" % ("끔" if model.mute else "켬"), 320, 895, 23, INK, true)

func draw_board() -> void:
    var tutorial := screen == "TUTORIAL"
    label("세 줄 단어창", 320, 208, 39, INK, true)
    label("%s  ·  %02d / 12 이동" % [("사용법" if tutorial else "창 %d / 5" % (model.level + 1)), model.moves], 320, 247, 22, AQUA, true)
    label("목표 · 세로로 읽기", 320, 286, 21, INK, true)
    for c in 3:
        var col: String = model.columns()[c]
        var matched: bool = col == Model.TARGETS[c]
        block(143 + c * 119, 304, 110, 97, Color("d4e9d8") if matched else CREAM, GOLD if matched else INK)
        label(Model.TARGETS[c], 198 + c * 119, 360, 28, INK, true)
        label("OK" if matched else "·", 198 + c * 119, 388, 20, INK, true)
    var rr := model.rows()
    for r in 3:
        var y := 422.0 + r * 114.0
        button("‹", 36, y, 94, 94, CORAL if r == selected_row else CREAM, 59)
        button("›", 510, y, 94, 94, CORAL if r == selected_row else CREAM, 59)
        block(149, y, 342, 94, CREAM, AQUA if r == selected_row else INK)
        var shift := (anim_dir * anim_time / 0.16 * 17.0) if anim_row == r else 0.0
        for c in 3:
            var x := 206.0 + c * 114.0 + shift
            draw_line(Vector2(149 + (c + 1) * 114, y + 13), Vector2(149 + (c + 1) * 114, y + 82), Color("c4bfab"), 2) if c < 2 else null
            label(rr[r][c], x, y + 66, 58, INK, true)
        label("%d" % (r + 1), 145, y + 15, 17, AQUA, true)
    if tutorial:
        label("1행의 화살표를 눌러 보세요!", 320, 817, 27, INK, true)
        label("한 행이 움직이면 세 세로 단어가 모두 변합니다", 320, 848, 20, INK, true)
        if tutorial_moved:
            button("이해했어요 · 시작 →", 71, 865, 498, 72, GOLD, 25)
        else:
            label("↑↓ 행 선택 · ←→ 이동 · 1/2/3 바로 선택", 320, 909, 18, AQUA, true)
    else:
        label("현재  %s   /   %s   /   %s" % [model.columns()[0], model.columns()[1], model.columns()[2]], 320, 817, 25, INK, true)
        button("다시", 45, 847, 252, 78, CREAM, 25)
        button("%s  소리" % ("○" if model.mute else "♪"), 343, 847, 252, 78, CREAM, 25)

func overlay(title: String, sub: String, choices: Array) -> void:
    draw_rect(Rect2(18, 20, 604, 917), Color(0.06, 0.2, 0.22, 0.81))
    block(49, 296, 542, 462, PAPER)
    ornament(320, 367, 44)
    label(title, 320, 428, 38, INK, true)
    label(sub, 320, 470, 20, INK, true)
    for i in choices.size():
        button(choices[i], 85, 494 + i * 104, 470, 89, CORAL if i == 0 else CREAM, 27)
