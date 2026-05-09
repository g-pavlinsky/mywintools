@echo off
chcp 65001 >nul

echo.
echo ============================================================
echo    AKUMEN Consulting (RESTORE)
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Включение Windows Defender и SmartScreen
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Удаление политик ---
echo [ИНФО] Удаление политик отключения...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiVirus" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /f >nul 2>&1
echo [УСПЕХ] Политики удалены.

:: --- ШАГ 2: Включение служб ---
echo [ИНФО] Включение служб защиты...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WinDefend" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdNisSvc" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
echo [УСПЕХ] Службы восстановлены.

:: --- ШАГ 3: Включение задач ---
echo [ИНФО] Включение задач обслуживания...
powershell -Command "$tasks = @('Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance', 'Microsoft\Windows\Windows Defender\Windows Defender Cleanup', 'Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan', 'Microsoft\Windows\Windows Defender\Windows Defender Verification'); foreach ($t in $tasks) { Enable-ScheduledTask -TaskName $t -ErrorAction SilentlyContinue }"
echo [УСПЕХ] Задачи включены.

echo.
echo [ИТОГ] Защита восстановлена. ПЕРЕЗАГРУЗИТЕ систему.
pause