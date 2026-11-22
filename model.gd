extends RefCounted
class_name WordModel

const ROWS = ["CDS", "AOU", "TGN"]
const TARGETS = ["CAT", "DOG", "SUN"]
const STARTS = [[1, 0, 0], [1, 2, 0], [2, 1, 2], [2, 2, 1], [1, 2, 2]]
const LIMIT = 12
var level := 0
var offsets := [1, 0, 0]
var moves := 0
var status := "PLAYING"
var unlocked := 0
var best := -1
var cumulative := 0
var mute := false

func reset_level(index: int) -> void:
    level = clampi(index, 0, 4)
    offsets = STARTS[level].duplicate()
    moves = 0
    status = "PLAYING"

func rows() -> Array:
    var result := []
    for r in 3:
        var s: String = ROWS[r]
        var rotated := ""
        for c in 3:
            rotated += s[(c - offsets[r] + 3) % 3]
        result.append(rotated)
    return result

func columns() -> Array:
    var rr := rows()
    var result := []
    for c in 3:
        result.append(rr[0][c] + rr[1][c] + rr[2][c])
    return result

func rotate(row: int, direction: int) -> String:
    if status != "PLAYING" or row < 0 or row > 2 or absi(direction) != 1:
        return status
    offsets[row] = posmod(offsets[row] + direction, 3)
    moves += 1
    if columns() == TARGETS:
        status = "LEVEL_CLEAR" if level < 4 else "SUCCESS"
        cumulative += moves
        unlocked = maxi(unlocked, mini(level + 1, 4))
        if status == "SUCCESS" and (best < 0 or cumulative < best):
            best = cumulative
    elif moves >= LIMIT:
        status = "FAILURE"
    return status

func save_data() -> Dictionary:
    return {"unlocked": unlocked, "best": best, "mute": mute}

func load_data(data: Dictionary) -> void:
    unlocked = clampi(int(data.get("unlocked", 0)), 0, 4)
    best = maxi(-1, int(data.get("best", -1)))
    mute = bool(data.get("mute", false))
