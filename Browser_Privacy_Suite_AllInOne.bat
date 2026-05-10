
@echo off
chcp 65001 >nul
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - Browser Privacy & Control Suite
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Централизованное управление приватностью и поведением всех браузеров.
echo.
echo [ЧТО ЭТО] Набор политик для отключения синхронизации, телеметрии и навязчивых функций.
echo Скрипт работает через реестр (GPO) и не требует удаления самих браузеров.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Чтобы ваши пароли, история и закладки не улетали в чужие облака.
echo А также чтобы браузеры не висели в памяти после закрытия.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Chrome: Отключит синхронизацию и фоновый режим.
echo   2. Edge: Отключит синхронизацию, обновления и первый запуск.
echo   3. Firefox: Отключит телеметрию и сбор данных (через policies.json).
echo   4. Яндекс: Отключит синхронизацию и Алису.
echo   5. Opera: Отключит синхронизацию и новости.
echo.
echo [ВАЖНО] Требуется запуск от имени Администратора.
echo [ВАЖНО] Изменения вступают в силу после перезапуска браузера.
echo.
echo [АКТИВАЦИЯ] Перезапустите браузеры после выполнения.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ОТКЛЮЧИТЬ ВСЁ (Full Privacy Lockdown)
echo [2] ТОЛЬКО CHROME (Sync Off)
echo [3] ТОЛЬКО EDGE (Disable & Block)
echo [4] ТОЛЬКО FIREFOX (Telemetry Off)
echo [5] ТОЛЬКО YANDEX (Sync Off)
echo [6] ТОЛЬКО OPERA (Sync Off)
echo [7] ОТКАТ (Включить синхронизацию обратно)
echo [8] ВЫХОД
echo.
set /p choice="Введите номер (1-8) и нажмите Enter: "

if "%choice%"=="1" goto APPLY_ALL
if "%choice%"=="2" goto CHROME_ONLY
if "%choice%"=="3" goto EDGE_ONLY
if "%choice%"=="4" goto FIREFOX_ONLY
if "%choice%"=="5" goto YANDEX_ONLY
if "%choice%"=="6" goto OPERA_ONLY
if "%choice%"=="7" goto RESTORE
if "%choice%"=="8" exit /b 0
echo [ОШИБКА] Неверный выбор.
pause & exit /b 1

:APPLY_ALL
call :CHROME_ONLY
call :EDGE_ONLY
call :FIREFOX_ONLY
call :YANDEX_ONLY
call :OPERA_ONLY
goto END

:CHROME_ONLY
echo.
echo [ИНФО] Настройка Google Chrome...
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SyncDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "MetricsReportingEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
taskkill /F /IM chrome.exe >nul 2>&1
echo [УСПЕХ] Chrome: Синхронизация и телеметрия отключены.
goto :EOF

:EDGE_ONLY
echo.
echo [ИНФО] Настройка Microsoft Edge...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "SyncDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "HideFirstRunExperience" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v "DoNotUpdateToEdgeWithChromium" /t REG_DWORD /d 1 /f >nul 2>&1
schtasks /change /tn "\Microsoft\EdgeUpdate\EdgeUpdateTaskMachineCore" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\EdgeUpdate\EdgeUpdateTaskMachineUA" /disable >nul 2>&1
taskkill /F /IM msedge.exe >nul 2>&1
echo [УСПЕХ] Edge: Синхронизация и обновления отключены.
goto :EOF

:FIREFOX_ONLY
echo.
echo [ИНФО] Настройка Mozilla Firefox...
:: Создаем папку policies если нет
if not exist "%ProgramFiles%\Mozilla Firefox\distribution" mkdir "%ProgramFiles%\Mozilla Firefox\distribution"
(
echo {
echo   "policies": {
echo     "DisableTelemetry": true,
echo     "DisableFirefoxStudies": true,
echo     "DisablePocket": true,
echo     "DisableFirefoxAccounts": true,
echo     "NoDefaultBookmarks": true,
echo     "OfferToSaveLogins": false,
echo     "OfferToSaveLoginsDefault": false
echo   }
echo }
) > "%ProgramFiles%\Mozilla Firefox\distribution\policies.json"
taskkill /F /IM firefox.exe >nul 2>&1
echo [УСПЕХ] Firefox: Телеметрия и аккаунты отключены.
goto :EOF

:YANDEX_ONLY
echo.
echo [ИНФО] Настройка Yandex Browser...
reg add "HKLM\SOFTWARE\Policies\Yandex\YandexBrowser" /v "SyncDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Yandex\YandexBrowser" /v "AliceEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
taskkill /F /IM browser.exe >nul 2>&1
echo [УСПЕХ] Yandex: Синхронизация и Алиса отключены.
goto :EOF

:OPERA_ONLY
echo.
echo [ИНФО] Настройка Opera / Opera GX...
reg add "HKLM\SOFTWARE\Policies\Opera Software\Opera Stable" /v "SyncDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Opera Software\Opera GX Stable" /v "SyncDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
taskkill /F /IM opera.exe >nul 2>&1
taskkill /F /IM operagx.exe >nul 2>&1
echo [УСПЕХ] Opera: Синхронизация отключена.
goto :EOF

:RESTORE
echo.
echo [ИНФО] Возврат настроек по умолчанию...
reg delete "HKLM\SOFTWARE\Policies\Google\Chrome" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Edge" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Yandex\YandexBrowser" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Opera Software" /f >nul 2>&1
if exist "%ProgramFiles%\Mozilla Firefox\distribution\policies.json" del /f /q "%ProgramFiles%\Mozilla Firefox\distribution\policies.json"
schtasks /change /tn "\Microsoft\EdgeUpdate\EdgeUpdateTaskMachineCore" /enable >nul 2>&1
schtasks /change /tn "\Microsoft\EdgeUpdate\EdgeUpdateTaskMachineUA" /enable >nul 2>&1
echo [УСПЕХ] Политики удалены. Синхронизация доступна.
goto END

:END
echo.
echo [ИТОГ] Операция завершена. Перезапустите браузеры.
pause
exit /b 0