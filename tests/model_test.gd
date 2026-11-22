extends SceneTree
const Model = preload("res://model.gd")
var count := 0
var failures := 0

func check(condition: bool, message: String) -> void:
    if not condition:
        push_error(message)
        failures += 1
    count += 1

func _initialize() -> void:
    var m = Model.new()
    for i in 5:
        m.reset_level(i)
        check(m.columns() != Model.TARGETS, "start solved %d" % i)
        var expected := 0
        for r in 3:
            expected += Model.STARTS[i][r]
            for tap in Model.STARTS[i][r]:
                m.rotate(r, -1)
        check(expected <= 6 and m.columns() == Model.TARGETS, "unsolvable %d" % i)
        check(m.status == ("SUCCESS" if i == 4 else "LEVEL_CLEAR"), "status %d" % i)
    m.reset_level(2)
    var original = m.offsets.duplicate()
    m.rotate(0, 1)
    m.rotate(0, -1)
    check(m.offsets == original, "inverse")
    for i in 3:
        m.rotate(1, 1)
    check(m.offsets == original, "right x3 identity")
    m.reset_level(0)
    for i in 9:
        m.rotate(1, 1)
    m.rotate(2, 1)
    m.rotate(2, -1)
    check(m.status == "PLAYING", "premature fail")
    m.rotate(0, -1)
    check(m.status == "LEVEL_CLEAR" and m.moves == 12, "twelfth win priority")
    m.reset_level(0)
    for i in 12:
        m.rotate(1, 1)
    check(m.status == "FAILURE" and m.moves == 12, "twelfth incorrect fails")
    check(m.rotate(0, -1) == "FAILURE", "failed game immutable")
    m.reset_level(0)
    check(m.moves == 0 and m.offsets == Model.STARTS[0], "restart")
    m.unlocked = 4
    m.best = 19
    m.mute = true
    var n = Model.new()
    n.load_data(m.save_data())
    check(n.unlocked == 4 and n.best == 19 and n.mute, "save/load")
    n.load_data({"unlocked": 999, "best": -900})
    check(n.unlocked == 4 and n.best == -1, "save validation")
    print("MODEL %s: %d assertions, %d failures" % ["PASS" if failures == 0 else "FAIL", count, failures])
    quit(1 if failures else 0)
