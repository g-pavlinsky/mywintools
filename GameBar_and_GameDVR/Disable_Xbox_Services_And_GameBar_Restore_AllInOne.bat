@echo off
chcp 65001 >nul

echo.
echo ============================================================
echo    AKUMEN Consulting (RESTORE)
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Включение служб Xbox и восстановление Game Bar
echo.
echo [ЧТО ЭТО] Возврат стандартных настроек запуска служб и удаление политик блокировки записи.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Восстановление функционала геймпадов, облачных сохранений и записи экрана.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Вернет тип запуска служб Xbox в значение по умолчанию (Manual/Auto).
echo   2. Удалит политики блокировки GameDVR.
echo   3. Сбросит настройки Game Bar к стандартным.
echo.
echo [ВАЖНО] Требуется перезагрузка.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Возврат типа запуска служб ---
echo [ИНФО] Восстановление автозапуска служб Xbox...
:: XboxGipSvc - Manual (3), XboxNetApiSvc - Manual (3), XblAuthManager - Manual (3), XblGameSave - Manual (3)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XboxGipSvc" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XboxNetApiSvc" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XblAuthManager" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XblGameSave" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
echo [УСПЕХ] Тип запуска служб восстановлен.

:: --- ШАГ 2: Запуск служб ---
echo [ИНФО] Запуск служб Xbox...
net start XboxGipSvc >nul 2>&1
net start XboxNetApiSvc >nul 2>&1
net start XblAuthManager >nul 2>&1
net start XblGameSave >nul 2>&1
echo [УСПЕХ] Службы запущены.

:: --- ШАГ 3: Удаление политик и сброс настроек ---
echo [ИНФО] Удаление блокировок GameDVR...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" /v "value" /f >nul 2>&1

echo [ИНФО] Сброс настроек Game Bar...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "HistoricalCaptureEnabled" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AllowGameDVR" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AudioCaptureEnabled" /f >nul 2>&1
reg delete "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\GameBar" /v "ShowStartupPanel" /f >nul 2>&1
echo [УСПЕХ] Настройки сброшены.

echo.
echo [ИТОГ] Функционал Xbox восстановлен. Перезагрузите систему.
pause