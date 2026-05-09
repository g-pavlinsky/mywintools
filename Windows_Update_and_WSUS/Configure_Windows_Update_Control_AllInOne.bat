@echo off
chcp 65001 >nul

echo.
echo ============================================================
echo    AKUMEN Consulting
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Конфигуратор политик Windows Update и драйверов
echo.
echo [ЧТО ЭТО] Универсальный инструмент управления источниками обновлений и поведением системы.
echo.
echo [ВАЖНО] Выберите нужный режим в меню ниже.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- МЕНЮ ВЫБОРА ---
echo.
echo ВЫБЕРИТЕ РЕЖИМ ОБНОВЛЕНИЙ:
echo [1] WSUS (Корпоративный: сервер server.wsus, ручная установка)
echo [2] РУЧНОЙ (Домашний: сервера Microsoft, уведомления перед установкой)
echo [3] ТОЛЬКО БЛОКИРОВКА ДРАЙВЕРОВ (Не менять основные настройки WU)
echo.
set /p mode="Введите номер (1-3): "

if "%mode%"=="1" goto MODE_WSUS
if "%mode%"=="2" goto MODE_MANUAL
if "%mode%"=="3" goto MODE_DRIVERS_ONLY
echo [ОШИБКА] Неверный выбор.
pause & exit /b 1

:: --- РЕЖИМ 1: WSUS ---
:MODE_WSUS
echo.
echo [ИНФО] Применение настроек WSUS...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "WUServer" /t REG_SZ /d "http://server.wsus" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "WUStatusServer" /t REG_SZ /d "http://server.wsus" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "UseWUServer" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DoNotConnectToWindowsUpdateInternetLocations" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableDualScan" /t REG_DWORD /d 1 /f >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 5 /f >nul 2>&1
goto APPLY_COMMON

:: --- РЕЖИМ 2: РУЧНОЙ (Интернет) ---
:MODE_MANUAL
echo.
echo [ИНФО] Применение настроек Ручного режима (Internet)...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "WUServer" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "WUStatusServer" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "UseWUServer" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DoNotConnectToWindowsUpdateInternetLocations" /t REG_DWORD /d 0 /f >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUOptions" /t REG_DWORD /d 5 /f >nul 2>&1
goto APPLY_COMMON

:: --- РЕЖИМ 3: ТОЛЬКО ДРАЙВЕРЫ ---
:MODE_DRIVERS_ONLY
echo.
echo [ИНФО] Режим только блокировки драйверов. Основные настройки WU не меняются.
goto APPLY_DRIVERS

:: --- ОБЩИЕ НАСТРОЙКИ (Применяются к режимам 1 и 2) ---
:APPLY_COMMON
echo [ИНФО] Применение общих настроек контроля...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableWindowsUpdateAccess" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "AllowMUUpdateService" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "AutomaticMaintenanceEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "IncludeRecommendedUpdates" /t REG_DWORD /d 0 /f >nul 2>&1

:: --- БЛОКИРОВКА ДРАЙВЕРОВ (Применяется всегда) ---
:APPLY_DRIVERS
echo [ИНФО] Блокировка автоматической установки драйверов...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d 1 /f >nul 2>&1

echo [УСПЕХ] Настройки применены.
echo.
echo [ИТОГ] Выполните 'gpupdate /force' или перезагрузите ПК.
pause