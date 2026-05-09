@echo off
chcp 65001 >nul

echo.
echo ============================================================
echo    AKUMEN Consulting
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Полное отключение Windows Defender, SmartScreen и связанных служб
echo.
echo [ЧТО ЭТО] Агрессивный скрипт, блокирующий антивирусное ядро, облачную защиту и планировщик.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Устранение ложных срабатываний, снижение нагрузки на ЦП/Диск, работа с тестовым ПО.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Отключит Tamper Protection (если возможно).
echo   2. Применит политики полного отключения Defender и SmartScreen.
echo   3. Отключит службы WinDefend, WdNisSvc, WdFilter.
echo   4. Отключит задачи Планировщика обслуживания Defender.
echo.
echo [ВАЖНО] СИСТЕМА ОСТАНЕТСЯ БЕЗ АНТИВИРУСА!
echo [ВАЖНО] Tamper Protection может мешать. Если службы вернутся — отключите его вручную в GUI.
echo [ВАЖНО] Требуется перезагрузка.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Политики отключения Defender и SmartScreen ---
echo [ИНФО] Применение политик отключения...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiVirus" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpyNetReporting" /t REG_DWORD /d 0 /f >nul 2>&1

:: SmartScreen
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Edge\SmartScreenEnabled" /ve /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d 0 /f >nul 2>&1

echo [УСПЕХ] Политики применены.

:: --- ШАГ 2: Отключение служб ---
echo [ИНФО] Отключение служб защиты...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WinDefend" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdNisSvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdNisDrv" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdFilter" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
echo [УСПЕХ] Службы отключены.

:: --- ШАГ 3: Отключение задач Планировщика (PowerShell) ---
echo [ИНФО] Отключение задач обслуживания Defender...
powershell -Command "$tasks = @('Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance', 'Microsoft\Windows\Windows Defender\Windows Defender Cleanup', 'Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan', 'Microsoft\Windows\Windows Defender\Windows Defender Verification'); foreach ($t in $tasks) { Disable-ScheduledTask -TaskName $t -ErrorAction SilentlyContinue }"
echo [УСПЕХ] Задачи отключены.

echo.
echo [ИТОГ] Defender отключен. ПЕРЕЗАГРУЗИТЕ систему.
pause