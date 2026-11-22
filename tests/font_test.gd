extends SceneTree
func _initialize() -> void:
    var font: Font = load("res://assets/NotoSansKR.ttf")
    var strings := ["세 줄 단어창", "시작하기  →", "이어갈 판  1 / 5", "소리 켬 · M 키", "사용법", "창 5 / 5", "목표 · 세로로 읽기", "CAT DOG SUN", "1행의 화살표를 눌러 보세요!", "한 행이 움직이면 세 세로 단어가 모두 변합니다", "이해했어요 · 시작 →", "↑↓ 행 선택 · ←→ 이동 · 1/2/3 바로 선택", "다시", "♪ 소리", "○ 소리", "다시 인쇄할까요?", "현재 판을 처음부터 시작합니다", "현재 판 다시", "처음부터", "돌아가기", "인쇄 성공!", "다음 창으로 이어집니다", "다음 판 →", "잉크가 다했어요", "12번 안에 세 단어를 맞춰 보세요", "다섯 창 완성!", "총 1번의 이동 · 최고 1번", "‹ › OK"]
    var missing := []
    for s in strings:
        for ch in s:
            if not font.has_char(ch.unicode_at(0)) and not missing.has(ch):
                missing.append(ch)
    print("FONT MISSING: ", missing, " / strings ", strings.size())
    quit(1 if missing.size() else 0)
