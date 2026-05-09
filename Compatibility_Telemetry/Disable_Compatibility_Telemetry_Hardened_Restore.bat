@echo off
chcp 65001 >nul
:: ==========================================================
:: ФАЙЛ: Disable_Compatibility_Telemetry_Hardened_Restore.bat
:: НАЗНАЧЕНИЕ: Восстановление служб телеметрии и включение триггеров планировщика
:: ==========================================================
:: ЧТО ЭТО: Откатывающий скрипт, применяющий дефолтные настройки реестра и активирующий службы/задачи.
::
:: ЗАЧЕМ МЕНЯЕМ: Полная инверсия основного решения для возврата системной диагностики и сбора данных.
::
:: ЧТО СДЕЛАЕТ ФАЙЛ: Применит реестр по умолчанию, запустит службы, включит отключенные задачи планировщика.
::
:: ВАЖНО: Требуется запуск от имени Администратора. Восстанавливает отправку отчетов и телеметрию. Перезагрузка рекомендована.
:: АКТИВАЦИЯ: Двойной клик от имени Администратора. Проверка: services.msc и taskschd.msc.
:: ==========================================================
:: AKUMEN Consulting
:: ==========================================================

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Применение конфигурации реестра (Откат) ---
echo [ИНФО] Выполняется: Импорт настроек по умолчанию...
reg import "%~dp0Disable_Compatibility_Telemetry_Hardened_Restore.reg" >nul 2>&1
if %errorlevel% equ 0 (
echo [УСПЕХ] Шаг 1 выполнен.
) else (
echo [ОШИБКА] Не удалось выполнить шаг 1. Код: %errorlevel%
)

:: --- ШАГ 2: Запуск служб телеметрии ---
echo [ИНФО] Выполняется: Запуск служб...
net start AeLookupSvc >nul 2>&1 & net start PcaSvc >nul 2>&1 & net start DiagTrack >nul 2>&1 & net start dmwappushservice >nul 2>&1
if %errorlevel% equ 0 (
echo [УСПЕХ] Шаг 2 выполнен.
) else (
echo [ОШИБКА] Не удалось выполнить шаг 2. Код: %errorlevel%
)

:: --- ШАГ 3: Включение триггеров в Планировщике заданий ---
echo [ИНФО] Выполняется: Активация задач планировщика...
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Enable >nul 2>&1 & schtasks /Change /TN "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /Enable >nul 2>&1 & schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Enable >nul 2>&1 & schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Enable >nul 2>&1 & schtasks /Change /TN "\Microsoft\Windows\Windows Error Reporting\QueueReporting" /Enable >nul 2>&1
if %errorlevel% equ 0 (
echo [УСПЕХ] Шаг 3 выполнен.
) else (
echo [ОШИБКА] Не удалось выполнить шаг 3. Код: %errorlevel%
)

echo.
echo [ИТОГ] Решение отменено. Перезагрузите систему для полного восстановления функций.
pause