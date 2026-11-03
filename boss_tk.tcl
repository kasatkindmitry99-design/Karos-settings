#!/usr/bin/env wish

# Файл данных
set file "$env(HOME)/.bosses"

# КД боссов
array set cds {
    "Слобрет" {2 30}
    "Вулкан"  {2 30}
    "Снежка"  {2 30}
    "Матка"    {4 00}
    "Капилка" {3 00}
    "Капа"    {3 30}
    "Балка"   {7 30}
    "Король"  {7 30}
}

set boss_list {"Слобрет" "Вулкан" "Снежка" "Матка" "Капилка" "Капа" "Балка" "Король"}

# Инициализация файла
if {![file exists $file]} {
    set f [open $file w]
    foreach b $boss_list { puts $f "$b|--:--" }
    close $f
}

# Чтение данных
proc load_data {} {
    global file resp_data
    set f [open $file r]
    while {[gets $f line] >= 0} {
        set parts [split $line "|"]
        if {[llength $parts] == 2} {
            set resp_data([lindex $parts 0]) [lindex $parts 1]
        }
    }
    close $f
}

# Расчет спавна
proc calc_resp {boss time_str} {
    global cds file resp_data
    set time_str [string map {" " ":"} [string trim $time_str]]
    if {$time_str eq ""} return

    set parts [split $time_str ":"]
    if {[llength $parts] != 2} return
    
    scan [lindex $parts 0] %d h
    scan [lindex $parts 1] %d m
    if {$h < 0 || $h > 23 || $m < 0 || $m > 59} return

    set cd [set cds($boss)]
    set cd_h [lindex $cd 0]
    set cd_m [lindex $cd 1]

    set kill_sec [expr {$h * 3600 + $m * 60}]
    set resp_add [expr {$cd_h * 3600 + $cd_m * 60}]
    
    set t1 [expr {($kill_sec + $resp_add) % 86400}]
    set t2 [expr {($t1 + 3600) % 86400}]

    set h1 [expr {$t1 / 3600}]; set m1 [expr {($t1 % 3600) / 60}]
    set h2 [expr {$t2 / 3600}]; set m2 [expr {($t2 % 3600) / 60}]

    set resp_data($boss) [format "%02d:%02d–%02d:%02d" $h1 $m1 $h2 $m2]

    set f [open $file w]
    foreach b [array names resp_data] {
        puts $f "$b|$resp_data($b)"
    }
    close $f
}

# Сохранение всех введенных полей
proc save_all {} {
    global boss_list inputs
    foreach b $boss_list {
        set val [$inputs($b) get]
        if {$val ne ""} {
            calc_resp $b $val
            $inputs($b) delete 0 end
        }
    }
}

# Безопасный выход
proc safe_exit {} {
    save_all
    exit
}

# Функция обновления часов в заголовке (без секунд, раз в минуту)
proc update_title {} {
    set current_time [clock format [clock seconds] -format "%H:%M"]
    wm title . "Таймер Боссов — $current_time"
    # Повторный вызов через 60000 мс (60 секунд / 1 минута)
    after 60000 update_title
}

# Отключаем принятие фокуса ввода на уровне оконного менеджера X11
wm focusmodel . passive
wm attributes . -topmost 1
. configure -background "#353535"

# Указываем Cinnamon не передавать фокус этому окну
catch {wm attributes . -type utility}

# Размеры окна
set win_width 320
set win_height 280
set screen_width [winfo screenwidth .]
set screen_height [winfo screenheight .]

# Позиция в правом нижнем углу
set x [expr {$screen_width - $win_width - 20}]
set y [expr {$screen_height - $win_height - 50}]

wm geometry . "${win_width}x${win_height}+${x}+${y}"
wm resizable . 0 0

# Сохранение при закрытии
wm protocol . WM_DELETE_WINDOW safe_exit

package require Ttk
ttk::style theme use clam

# Палитра Mint-L-Dark-Red
ttk::style configure TFrame -background "#353535"
ttk::style configure TLabel -background "#353535" -foreground "#e1e1e1" -font {Sans 10}
ttk::style configure Resp.TLabel -background "#353535" -foreground "#e57373" -font {Sans 10}
ttk::style configure TEntry -fieldbackground "#2b2b2b" -foreground "#ffffff" -bordercolor "#454545" -lightcolor "#454545" -darkcolor "#454545" -font {Sans 10}

# Стиль для кнопок
ttk::style configure Dark.TButton -background "#454545" -foreground "#ffffff" -font {Sans 10} -borderwidth 0 -padding 4
ttk::style map Dark.TButton -background {active "#555555" pressed "#333333"}

load_data

# Контейнер для формы
ttk::frame .f -padding "8 8 8 8"
pack .f -fill both -expand true

# Отрисовка элементов
set row 0
foreach b $boss_list {
    ttk::label .f.lbl_name_$row -text "$b" -width 8
    ttk::label .f.lbl_resp_$row -textvariable resp_data($b) -width 13 -style Resp.TLabel
    ttk::entry .f.ent_$row -width 8 -justify center

    grid .f.lbl_name_$row -row $row -column 0 -padx 3 -pady 2 -sticky w
    grid .f.lbl_resp_$row -row $row -column 1 -padx 3 -pady 2
    grid .f.ent_$row -row $row -column 2 -padx 3 -pady 2 -sticky e
    
    set inputs($b) .f.ent_$row
    incr row
}

# Кнопки внизу
ttk::button .f.btn_exit -text "Выход" -command safe_exit -style Dark.TButton
ttk::button .f.btn_save -text "Сохранить" -command save_all -style Dark.TButton

grid .f.btn_exit -row $row -column 0 -pady "8 2" -padx 3 -sticky ew
grid .f.btn_save -row $row -column 1 -columnspan 2 -pady "8 2" -padx 3 -sticky ew

# Сохранение по Enter
bind . <Return> save_all

# Запуск обновления часов в заголовке
update_title
