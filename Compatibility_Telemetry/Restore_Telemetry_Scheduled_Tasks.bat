@echo off
chcp 65001 >nul
:: ==========================================================
:: ФАЙЛ: Restore_Telemetry_Scheduled_Tasks.bat
:: НАЗНАЧЕНИЕ: Возврат задач планировщика телеметрии в активное состояние
:: ==========================================================
:: ЧТО ЭТО: Инверсия скрипта Disable_Telemetry_Scheduled_Tasks.bat.
::
:: ЗАЧЕМ НУЖЕН: Если требуется восстановить штатный сбор данных
:: для диагностики или соответствия корпоративным политикам.
::
:: ЧТО СДЕЛАЕТ ФАЙЛ:
:: 1. Включит задачи Appraiser, ProgramDataUpdater, AitAgent, Consolidator.
::
:: ВАЖНО:
:: - Требуются права Администратора.
:: - Задачи вернутся в расписание, определенное системой по умолчанию.
:: АКТИВАЦИЯ:
:: 1. Запустите от имени Администратора.
:: 2. Перезагрузите ПК.
:: ==========================================================
:: AKUMEN Consulting
:: ==========================================================

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Включение Microsoft Compatibility Appraiser ---
echo [ИНФО] Включение задачи: Microsoft Compatibility Appraiser...
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Enable >nul 2>&1
if %errorlevel% equ 0 (
    echo [УСПЕХ] Задача включена.
) else (
    echo [ОШИБКА] Ошибка включения. Код: %errorlevel%
)

:: --- ШАГ 2: Включение ProgramDataUpdater ---
echo [ИНФО] Включение задачи: ProgramDataUpdater...
schtasks /Change /TN "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /Enable >nul 2>&1
if %errorlevel% equ 0 (
    echo [УСПЕХ] Задача включена.
) else (
    echo [ОШИБКА] Ошибка включения. Код: %errorlevel%
)

:: --- ШАГ 3: Включение AitAgent ---
echo [ИНФО] Включение задачи: AitAgent...
schtasks /Change /TN "\Microsoft\Windows\Application Experience\AitAgent" /Enable >nul 2>&1
if %errorlevel% equ 0 (
    echo [УСПЕХ] Задача включена.
) else (
    echo [ОШИБКА] Ошибка включения. Код: %errorlevel%
)

:: --- ШАГ 4: Включение Consolidator ---
echo [ИНФО] Включение задачи: Consolidator...
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Enable >nul 2>&1
if %errorlevel% equ 0 (
    echo [УСПЕХ] Задача включена.
) else (
    echo [ОШИБКА] Ошибка включения. Код: %errorlevel%
)

echo.
echo [ИТОГ] Задачи планировщика восстановлены.
pause