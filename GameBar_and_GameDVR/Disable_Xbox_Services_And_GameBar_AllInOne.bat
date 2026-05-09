@echo off
chcp 65001 >nul

echo.
echo ============================================================
echo    AKUMEN Consulting
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Полное отключение фоновых служб Xbox, Game Bar и Game DVR
echo.
echo [ЧТО ЭТО] Монолитный скрипт, отключающий системные службы Xbox (GIP, NetApi, Auth, Save) и блокирующий запись экрана (GameDVR).
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Освобождение 50-150 МБ ОЗУ, устранение фонового сетевого трафика, предотвращение микро-фризов в играх и приложениях.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Остановит и отключит службы: XboxGipSvc, XboxNetApiSvc, XblAuthManager, XblGameSave.
echo   2. Заблокирует Game Bar, Game DVR и "Игровой режим" через реестр (HKCU и HKLM).
echo   3. Примет политики запрета записи экрана для всех пользователей.
echo.
echo [ВАЖНО] Геймпады Xbox могут перестать определяться автоматически.
echo [ВАЖНО] Игры из Microsoft Store/Xbox App могут потерять онлайн-функции.
echo [ВАЖНО] Облачные сохранения Xbox синхронизироваться не будут.
echo [ВАЖНО] Требуется перезагрузка.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Остановка и отключение служб Xbox ---
echo [ИНФО] Остановка служб Xbox...
net stop XboxGipSvc /y >nul 2>&1
net stop XboxNetApiSvc /y >nul 2>&1
net stop XblAuthManager /y >nul 2>&1
net stop XblGameSave /y >nul 2>&1
echo [УСПЕХ] Службы остановлены.

echo [ИНФО] Отключение автозапуска служб...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XboxGipSvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XboxNetApiSvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XblAuthManager" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XblGameSave" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
echo [УСПЕХ] Службы отключены.

:: --- ШАГ 2: Отключение Game Bar и Game DVR (HKCU) ---
echo [ИНФО] Отключение Game DVR и Game Bar для текущего пользователя...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "HistoricalCaptureEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AudioCaptureEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\GameBar" /v "ShowStartupPanel" /t REG_DWORD /d 0 /f >nul 2>&1
echo [УСПЕХ] Настройки пользователя применены.

:: --- ШАГ 3: Глобальная блокировка (HKLM Policies) ---
echo [ИНФО] Применение глобальных политик запрета GameDVR...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" /v "value" /t REG_DWORD /d 0 /f >nul 2>&1
echo [УСПЕХ] Глобальные политики применены.

:: --- ШАГ 4: Завершение процессов ---
echo [ИНФО] Завершение активных процессов Xbox...
taskkill /F /IM GameBar.exe >nul 2>&1
taskkill /F /IM GameBarElevatedFT.exe >nul 2>&1
taskkill /F /IM XboxGameMonitor.exe >nul 2>&1
echo [УСПЕХ] Процессы завершены.

echo.
echo [ИТОГ] Решение применено. Перезагрузите систему для полного освобождения ресурсов.
pause