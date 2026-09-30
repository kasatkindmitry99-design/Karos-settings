#!/bin/bash

# Имя нашего файла скрипта
SCRIPT_NAME="boss_tk.tcl"
SCRIPT_PATH="$HOME/$SCRIPT_NAME"

PID=$(pgrep -f "$SCRIPT_NAME")

if [ -n "$PID" ]; then
    # Если запущен — отправляем сигнал на закрытие (Tcl сам выполнит safe_exit)
    kill -15 "$PID"
else
    # Если не запущен — открываем
    "$SCRIPT_PATH" &
fi