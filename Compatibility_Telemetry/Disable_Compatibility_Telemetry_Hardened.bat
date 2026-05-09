@echo off
chcp 65001 >nul
:: ==========================================================
:: ФАЙЛ: Disable_Compatibility_Telemetry_Hardened.bat
:: НАЗНАЧЕНИЕ: Применение политик телеметрии, остановка служб и отключение триггеров
:: ==========================================================
:: ЧТО ЭТО: Гибридный установщик, который останавливает активные службы, применяет реестр и блокирует задачи планировщика.
::
:: ЗАЧЕМ МЕНЯЕМ: Изменения в реестре не останавливают запущенные процессы немедленно, а задачи планировщика могут запускать их снова.
::
:: ЧТО СДЕЛАЕТ ФАЙЛ: Остановит службы телеметрии, импортирует .reg, отключит триггеры Application Experience, CEIP и WER.
::
:: ВАЖНО: Требуется запуск от имени Администратора. Отключает отправку отчетов и диагностику совместимости. В доменной среде настройки могут быть переопределены GPO.
:: АКТИВАЦИЯ: Двойной клик от имени Администратора. Проверка: services.msc (статус служб) и taskschd.msc (статус задач).
:: ==========================================================
:: AKUMEN Consulting
:: ==========================================================

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Остановка служб телеметрии и совместимости ---
echo [ИНФО] Выполняется: Остановка служб...
net stop DiagTrack /y >nul 2>&1 & net stop dmwappushservice /y >nul 2>&1 & net stop PcaSvc /y >nul 2>&1 & net stop AeLookupSvc /y >nul 2>&1
if %errorlevel% equ 0 (
echo [УСПЕХ] Шаг 1 выполнен.
) else (
echo [ОШИБКА] Не удалось выполнить шаг 1. Код: %errorlevel%
)

:: --- ШАГ 2: Применение конфигурации реестра ---
echo [ИНФО] Выполняется: Импорт .reg файла...
reg import "%~dp0Disable_Compatibility_Telemetry_Hardened.reg" >nul 2>&1
if %errorlevel% equ 0 (
echo [УСПЕХ] Шаг 2 выполнен.
) else (
echo [ОШИБКА] Не удалось выполнить шаг 2. Код: %errorlevel%
)

:: --- ШАГ 3: Отключение триггеров в Планировщике заданий ---
echo [ИНФО] Выполняется: Блокировка задач телеметрии...
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable >nul 2>&1 & schtasks /Change /TN "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /Disable >nul 2>&1 & schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable >nul 2>&1 & schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable >nul 2>&1 & schtasks /Change /TN "\Microsoft\Windows\Windows Error Reporting\QueueReporting" /Disable >nul 2>&1
if %errorlevel% equ 0 (
echo [УСПЕХ] Шаг 3 выполнен.
) else (
echo [ОШИБКА] Не удалось выполнить шаг 3. Код: %errorlevel%
)

echo.
echo [ИТОГ] Решение применено. Перезагрузите систему для полного вступления изменений в силу.
pause