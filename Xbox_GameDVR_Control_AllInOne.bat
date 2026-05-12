
@echo off
chcp 65001 >nul 2>&1
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - Xbox and GameDVR Control
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Полное отключение фоновых служб Xbox, Game Bar и Game DVR
echo.
echo [ЧТО ЭТО] Монолитный скрипт, отключающий системные службы Xbox и блокирующий запись экрана.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Освобождение ОЗУ, устранение фонового трафика, предотвращение микро-фризов в играх.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Остановит и отключит службы: XboxGipSvc, XboxNetApiSvc, XblAuthManager, XblGameSave.
echo   2. Заблокирует Game Bar, Game DVR и "Игровой режим" через реестр.
echo   3. Примет политики запрета записи экрана для всех пользователей.
echo   4. Позволит вернуть функционал Xbox (Откат).
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

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ОТКЛЮЧИТЬ Xbox и GameDVR (Apply Performance Mode)
echo [2] ВКЛЮЧИТЬ Xbox и GameDVR (Restore Functionality)
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

echo [ИНФО] Применение глобальных политик запрета GameDVR...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" /v "value" /t REG_DWORD /d 0 /f >nul 2>&1
echo [УСПЕХ] Глобальные политики применены.

echo [ИНФО] Завершение активных процессов Xbox...
taskkill /F /IM GameBar.exe >nul 2>&1
taskkill /F /IM GameBarElevatedFT.exe >nul 2>&1
taskkill /F /IM XboxGameMonitor.exe >nul 2>&1
echo [УСПЕХ] Процессы завершены.

goto END

:RESTORE
echo.
echo [ИНФО] Включение автозапуска служб Xbox (Manual/Auto)...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XboxGipSvc" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XboxNetApiSvc" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XblAuthManager" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XblGameSave" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
echo [УСПЕХ] Службы восстановлены.

echo [ИНФО] Сброс настроек Game Bar и Game DVR...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AllowGameDVR" /f >nul 2>&1
reg delete "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /f >nul 2>&1
echo [УСПЕХ] Настройки пользователя сброшены.

echo [ИНФО] Удаление глобальных запретов GameDVR...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" /v "value" /f >nul 2>&1
echo [УСПЕХ] Глобальные политики удалены.

goto END

:END
echo.
echo [ИТОГ] Операция завершена. Перезагрузите систему.
pause
exit /b 0