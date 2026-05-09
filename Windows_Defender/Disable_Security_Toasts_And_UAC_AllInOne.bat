@echo off
chcp 65001 >nul

echo.
echo ============================================================
echo    AKUMEN Consulting
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Отключение всплывающих уведомлений Центра безопасности и запросов UAC
echo.
echo [ЧТО ЭТО] Скрипт убирает визуальный шум: тосты "Включите защиту" и затемнение экрана при запуске от админа.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Для спокойной работы без прерываний на доверенных машинах.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Отключит тосты SecurityAndMaintenance.
echo   2. Сбросит историю уведомлений.
echo   3. Отключит запрос подтверждения UAC для администраторов (ConsentPromptBehaviorAdmin=0).
echo.
echo [ВАЖНО] UAC остается включенным (для работы Store), но не спрашивает разрешения.
echo [ВАЖНО] Снижает защиту от скрытого запуска вредоносных скриптов.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Отключение уведомлений (Toasts) ---
echo [ИНФО] Отключение уведомлений Центра безопасности...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.Defender.SecurityCenter" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1

:: Сброс кэша уведомлений
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications" /v "TimestampWhenSeen" /t REG_BINARY /d "7CAEC1EE1AECD301" /f >nul 2>&1
echo [УСПЕХ] Уведомления отключены.

:: --- ШАГ 2: Настройка UAC (Silent Admin) ---
echo [ИНФО] Отключение запросов UAC для администратора...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 0 /f >nul 2>&1
echo [УСПЕХ] UAC настроен на тихий режим.

echo.
echo [ИТОГ] Интерфейс очищен от предупреждений. Перезагрузка желательна.
pause