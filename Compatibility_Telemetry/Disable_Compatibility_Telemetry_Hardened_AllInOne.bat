@echo off
chcp 65001 >nul

echo.
echo ============================================================
echo    AKUMEN Consulting
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Полное отключение служб совместимости, инвентаризации и телеметрии
echo.
echo [ЧТО ЭТО] Монолитный скрипт, применяющий политики безопасности и отключающий службы диагностики напрямую через CMD.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Устранение фоновой нагрузки на ЦП/Диск, снижение сетевого трафика, повышение приватности.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Остановит активные службы телеметрии и совместимости.
echo   2. Внесет изменения в реестр для блокировки AppCompat, DiagTrack, WER и CEIP.
echo   3. Отключит задачи Планировщика заданий, связанные со сбором данных.
echo   4. Заблокирует службу через образ диска (Image File Execution Options) для предотвращения перезапуска.
echo.
echo [ВАЖНО] Мастер совместимости и отправка отчетов о сбоях перестанут работать. Требуется перезагрузка.
echo [ВАЖНО] В доменной среде GPO могут переопределить настройки.
echo [ВАЖНО] Рекомендуется создать точку восстановления перед запуском.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора. Проверка: services.msc и taskschd.msc.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Остановка служб ---
echo [ИНФО] Остановка служб телеметрии и совместимости...
net stop DiagTrack /y >nul 2>&1
net stop dmwappushservice /y >nul 2>&1
net stop AeLookupSvc /y >nul 2>&1
net stop PcaSvc /y >nul 2>&1
echo [УСПЕХ] Службы остановлены.

:: --- ШАГ 2: Изменение реестра (Конфигурация служб) ---
echo [ИНФО] Блокировка автозапуска служб через реестр...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AeLookupSvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PcaSvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
echo [УСПЕХ] Параметры запуска служб изменены.

:: --- ШАГ 3: Политики AppCompat ---
echo [ИНФО] Применение политик совместимости приложений...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisablePCA" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 0 /f >nul 2>&1
echo [УСПЕХ] Политики AppCompat применены.

:: --- ШАГ 4: Политики DataCollection (Телеметрия) ---
echo [ИНФО] Блокировка сбора данных (Телеметрия)...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DisableTelemetry" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] Политики телеметрии применены.

:: --- ШАГ 5: Политики Windows Error Reporting ---
echo [ИНФО] Отключение отчетности об ошибках (WER)...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] WER отключен.

:: --- ШАГ 6: Политики SQMClient (CEIP) ---
echo [ИНФО] Отключение программы улучшения качества (CEIP)...
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0 /f >nul 2>&1
echo [УСПЕХ] CEIP отключен.

:: --- ШАГ 7: Отключение задач Планировщика ---
echo [ИНФО] Отключение задач диагностического отслеживания...
schtasks /change /tn "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /disable >nul 2>&1
echo [УСПЕХ] Задачи отключены.

:: --- ШАГ 8: Дополнительная блокировка (Proactive Hardening) ---
echo [ИНФО] Дополнительная блокировка запуска DiagTrack через IFEO...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\diagtrack.dll" /v "Debugger" /t REG_SZ /d "%windir%\System32\taskkill.exe" /f >nul 2>&1
echo [УСПЕХ] Дополнительная защита применена.

echo.
echo [ИТОГ] Решение применено. Перезагрузите систему для полного вступления в силу.
pause