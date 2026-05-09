@echo off
chcp 65001 >nul

echo.
echo ============================================================
echo    AKUMEN Consulting (RESTORE)
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Восстановление стандартных настроек телеметрии и совместимости
echo.
echo [ЧТО ЭТО] Скрипт отката, возвращающий службы, реестр и задачи в состояние по умолчанию.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Возврат функционала диагностики и отчетов об ошибках.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Вернет тип запуска служб в значение по умолчанию (Auto/Manual).
echo   2. Удалит ограничивающие ключи реестра политик.
echo   3. Включит задачи Планировщика заданий.
echo   4. Удалит блокировку IFEO.
echo.
echo [ВАЖНО] Для полного восстановления может потребоваться переустановка компонентов диагностики, если они были повреждены.
echo [ВАЖНО] Требуется перезагрузка.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Возврат типа запуска служб ---
echo [ИНФО] Восстановление типа запуска служб...
:: DiagTrack - Manual (3), dmwappushservice - Manual (3), AeLookupSvc - Manual (3), PcaSvc - Auto (2)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AeLookupSvc" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PcaSvc" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
echo [УСПЕХ] Тип запуска служб восстановлен.

:: --- ШАГ 2: Запуск служб ---
echo [ИНФО] Запуск служб...
net start DiagTrack >nul 2>&1
net start dmwappushservice >nul 2>&1
net start AeLookupSvc >nul 2>&1
net start PcaSvc >nul 2>&1
echo [УСПЕХ] Службы запущены.

:: --- ШАГ 3: Удаление политик AppCompat ---
echo [ИНФО] Удаление политик AppCompat...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisablePCA" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /f >nul 2>&1
echo [УСПЕХ] Политики AppCompat удалены.

:: --- ШАГ 4: Удаление политик DataCollection ---
echo [ИНФО] Удаление политик телеметрии...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DisableTelemetry" /f >nul 2>&1
echo [УСПЕХ] Политики телеметрии удалены.

:: --- ШАГ 5: Удаление политик WER ---
echo [ИНФО] Включение отчетности об ошибках (WER)...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /f >nul 2>&1
echo [УСПЕХ] WER включен.

:: --- ШАГ 6: Удаление политик SQMClient ---
echo [ИНФО] Включение CEIP...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /f >nul 2>&1
echo [УСПЕХ] CEIP включен.

:: --- ШАГ 7: Включение задач Планировщика ---
echo [ИНФО] Включение задач диагностического отслеживания...
schtasks /change /tn "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /enable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /enable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /enable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /enable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /enable >nul 2>&1
echo [УСПЕХ] Задачи включены.

:: --- ШАГ 8: Удаление дополнительной блокировки ---
echo [ИНФО] Удаление блокировки IFEO...
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\diagtrack.dll" /f >nul 2>&1
echo [УСПЕХ] Блокировка удалена.

echo.
echo [ИТОГ] Настройки восстановлены. Перезагрузите систему.
pause