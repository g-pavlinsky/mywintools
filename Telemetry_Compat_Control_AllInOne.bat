
@echo off
chcp 65001 >nul
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - Telemetry and Compatibility Control
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Полное отключение служб совместимости, инвентаризации и телеметрии
echo.
echo [ЧТО ЭТО] Монолитный скрипт, применяющий политики безопасности и отключающий службы диагностики.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Устранение фоновой нагрузки на ЦП/Диск, снижение сетевого трафика, повышение приватности.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Остановит активные службы телеметрии и совместимости.
echo   2. Внесет изменения в реестр для блокировки AppCompat, DiagTrack, WER и CEIP.
echo   3. Отключит задачи Планировщика заданий, связанные со сбором данных.
echo   4. Заблокирует службу через IFEO для предотвращения перезапуска.
echo.
echo [ВАЖНО] Мастер совместимости и отправка отчетов о сбоях перестанут работать.
echo [ВАЖНО] В доменной среде GPO могут переопределить настройки.
echo [ВАЖНО] Рекомендуется создать точку восстановления перед запуском.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора. Проверка: services.msc и taskschd.msc.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ОТКЛЮЧИТЬ телеметрию и совместимость (Apply)
echo [2] ВОССТАНОВИТЬ стандартные настройки (Restore)
echo [3] ВЫХОД
echo.
set /p choice="Введите номер (1-3) и нажмите Enter: "

if "%choice%"=="1" goto APPLY
if "%choice%"=="2" goto RESTORE
if "%choice%"=="3" exit /b 0
echo [ОШИБКА] Неверный выбор.
pause & exit /b 1

:APPLY
echo.
echo [ИНФО] Остановка служб телеметрии и совместимости...
net stop DiagTrack /y >nul 2>&1
net stop dmwappushservice /y >nul 2>&1
net stop AeLookupSvc /y >nul 2>&1
net stop PcaSvc /y >nul 2>&1
echo [УСПЕХ] Службы остановлены.

echo [ИНФО] Блокировка автозапуска служб через реестр...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AeLookupSvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PcaSvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
echo [УСПЕХ] Параметры запуска служб изменены.

echo [ИНФО] Применение политик совместимости приложений...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisablePCA" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 0 /f >nul 2>&1
echo [УСПЕХ] Политики AppCompat применены.

echo [ИНФО] Блокировка сбора данных (Телеметрия)...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DisableTelemetry" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] Политики телеметрии применены.

echo [ИНФО] Отключение отчетности об ошибках (WER)...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] WER отключен.

echo [ИНФО] Отключение программы улучшения качества (CEIP)...
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0 /f >nul 2>&1
echo [УСПЕХ] CEIP отключен.

echo [ИНФО] Отключение задач диагностического отслеживания...
schtasks /change /tn "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /disable >nul 2>&1
echo [УСПЕХ] Задачи отключены.

echo [ИНФО] Дополнительная блокировка запуска DiagTrack через IFEO...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\diagtrack.dll" /v "Debugger" /t REG_SZ /d "%windir%\System32\taskkill.exe" /f >nul 2>&1
echo [УСПЕХ] Дополнительная защита применена.

goto END

:RESTORE
echo.
echo [ИНФО] Восстановление типа запуска служб...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AeLookupSvc" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PcaSvc" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
echo [УСПЕХ] Тип запуска служб восстановлен.

echo [ИНФО] Запуск служб...
net start DiagTrack >nul 2>&1
net start dmwappushservice >nul 2>&1
net start AeLookupSvc >nul 2>&1
net start PcaSvc >nul 2>&1
echo [УСПЕХ] Службы запущены.

echo [ИНФО] Удаление политик AppCompat...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisablePCA" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /f >nul 2>&1
echo [УСПЕХ] Политики AppCompat удалены.

echo [ИНФО] Удаление политик телеметрии...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DisableTelemetry" /f >nul 2>&1
echo [УСПЕХ] Политики телеметрии удалены.

echo [ИНФО] Включение отчетности об ошибках (WER)...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /f >nul 2>&1
echo [УСПЕХ] WER включен.

echo [ИНФО] Включение CEIP...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /f >nul 2>&1
echo [УСПЕХ] CEIP включен.

echo [ИНФО] Включение задач диагностического отслеживания...
schtasks /change /tn "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /enable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /enable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /enable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /enable >nul 2>&1
schtasks /change /tn "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /enable >nul 2>&1
echo [УСПЕХ] Задачи включены.

echo [ИНФО] Удаление блокировки IFEO...
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\diagtrack.dll" /f >nul 2>&1
echo [УСПЕХ] Блокировка удалена.

goto END

:END
echo.
echo [ИТОГ] Операция завершена. Перезагрузите систему.
pause
exit /b 0