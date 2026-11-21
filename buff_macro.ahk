#Requires AutoHotkey v2.0

; ================= НАСТРОЙКИ =================
X_COORD := 611
Y_COORD := 27
; Основной цвет в формате BGR (в AHK PixelGetColor возвращает 0xBBGGRR)
BUFF_HEX := "0xF986DD"

; Список допустимых оттенков (в RGB, как у вас в комментарии)
ValidColors := ["F986DD", "ED8DD6", "D38EC2", "F787D7", "E59DD1"]
; =============================================

; Горячая клавиша F8 — запуск/пауза скрипта
Toggle := false
F8:: {
    global Toggle
    Toggle := !Toggle
    ToolTip Toggle ? "Макрос ЗАПУЩЕН (F8 — стоп)" : "Макрос НА ПАУЗЕ"
    SetTimer () => ToolTip(), -1500
}

; Горячая клавиша F9 — аварийный выход из скрипта
F9::ExitApp

HumanSleep(minSec, maxSec) {
    ; Random принимает миллисекунды
    ms := Random(Round(minSec * 1000), Round(maxSec * 1000))
    Sleep ms
}

PressKeyHuman(key) {
    Send "{" key " down}"
    HumanSleep(0.05, 0.12)
    Send "{" key " up}"
}

GetPixelHexRGB(x, y) {
    ; Координаты относительно экрана (как maim в X11)
    CoordMode "Pixel", "Screen"
    ; "RGB" заставляет вернуть цвет в привычном виде 0xRRGGBB
    color := PixelGetColor(x, y, "RGB")
    ; Убираем префикс "0x" и приводим к верхнему регистру
    return SubStr(Format("{:06X}", color & 0xFFFFFF), 1, 6)
}

IsColorValid(hex6) {
    for valid in ValidColors {
        if (hex6 = valid)
            return true
    }
    return false
}

; Основной цикл
Sleep 3000

loop {
    if (!Toggle) {
        Sleep 200
        continue
    }

    currentHex := GetPixelHexRGB(X_COORD, Y_COORD)
    ; Выводим текущий цвет в подсказку или лог (в AHK нет стандартной консоли без доп. кода)
    OutputDebug "Color: #" currentHex "`n"

    if (!IsColorValid(currentHex)) {
        PressKeyHuman("2")
        HumanSleep(0.4, 0.8)

        PressKeyHuman("3")
        HumanSleep(0.25, 0.5)

        PressKeyHuman("3")
    }

    HumanSleep(0.8, 1.3)
}