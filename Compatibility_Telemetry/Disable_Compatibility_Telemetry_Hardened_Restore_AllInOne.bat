@echo off
chcp 65001 >nul
:: ==========================================================
:: ФАЙЛ: Disable_Compatibility_Telemetry_Hardened_Restore_AllInOne.bat
:: НАЗНАЧЕНИЕ: Восстановление настроек по умолчанию для служб совместимости и телеметрии
:: ==========================================================
:: ЧТО ЭТО: Скрипт отката, возвращающий службы в ручной/автоматический режим и удаляющий ограничивающие политики.
::
:: ЗАЧЕМ МЕНЯЕМ: Возврат функционала диагностики, отчетов об ошибках и мастера совместимости.
::
:: ЧТО СДЕЛАЕТ ФАЙЛ: 
:: 1. Удалит ключи политик, блокирующие сбор данных.
:: 2. Вернет тип запуска служб к значениям по умолчанию.
:: 3. Включит ранее отключенные задачи Планировщика.
::
:: ВАЖНО: Требуется перезагрузка. Некоторые задачи могут быть включены, но не активны до следующего триггера.
:: АКТИВАЦИЯ: Запуск от имени Администратора.
:: ==========================================================
:: AKUMEN Consulting
:: ==========================================================

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Удаление политик реестра ---
echo [ИНФО] Удаление политик блокировки...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /f >nul 2>&1
echo [УСПЕХ] Политики удалены.

:: --- ШАГ 2: Возврат параметров служб ---
echo [ИНФО] Возврат типа запуска служб...
:: AeLookupSvc: Manual (3)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AeLookupSvc" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
:: PcaSvc: Manual (3)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PcaSvc" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
:: DiagTrack: Auto (2)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
:: dmwappushservice: Manual (3)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
echo [УСПЕХ] Параметры служб восстановлены.

:: --- ШАГ 3: Запуск служб ---
echo [ИНФО] Запуск служб...
net start DiagTrack >nul 2>&1
net start dmwappushservice >nul 2>&1
net start AeLookupSvc >nul 2>&1
net start PcaSvc >nul 2>&1
echo [УСПЕХ] Службы запущены.

:: --- ШАГ 4: Включение задач Планировщика ---
echo [ИНФО] Включение задач диагностического отслеживания...
schtasks /change /tn "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /enable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /enable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /enable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /enable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /enable >nul 2>&1
echo [УСПЕХ] Задачи включены.

:: ==========================================================
:: AKUMEN Consulting
:: ==========================================================
echo.
echo [ИТОГ] Настройки восстановлены. Перезагрузите систему.
pause