
@echo off
chcp 65001 >nul 2>&1
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - Windows Update Configurator
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Конфигуратор политик Windows Update и драйверов
echo.
echo [ЧТО ЭТО] Универсальный инструмент управления источниками обновлений и поведением системы.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Контроль над автоматическими обновлениями, блокировка нежелательных драйверов или настройка корпоративного WSUS.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Настроит источник обновлений (WSUS / Internet / Без изменений).
echo   2. Установит режим установки (Ручной / Автоматический).
echo   3. Заблокирует или разрешит автоматическую установку драйверов.
echo   4. Позволит сбросить все политики к заводским настройкам (Откат).
echo.
echo [ВАЖНО] Изменения вступают в силу после перезагрузки или gpupdate /force.
echo [ВАЖНО] Блокировка драйверов может потребовать ручной установки устройств.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

echo.
echo ВЫБЕРИТЕ РЕЖИМ ОБНОВЛЕНИЙ:
echo [1] WSUS (Корпоративный: сервер server.wsus, ручная установка, сервера Microsoft недоступны)
echo [2] РУЧНОЙ (Домашний: сервера Microsoft, уведомления перед установкой)
echo [3] ТОЛЬКО БЛОКИРОВКА ДРАЙВЕРОВ (Не менять основные настройки WU)
echo [4] ПОЛНЫЙ СБРОС (Restore Defaults)
echo [5] ВЫХОД
echo.
set /p choice="Введите номер (1-5) и нажмите Enter: "

if "%choice%"=="1" goto MODE_WSUS
if "%choice%"=="2" goto MODE_MANUAL
if "%choice%"=="3" goto MODE_DRIVERS_ONLY
if "%choice%"=="4" goto RESTORE
if "%choice%"=="5" exit /b 0
echo [ОШИБКА] Неверный выбор.
pause & exit /b 1

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

:MODE_DRIVERS_ONLY
echo.
echo [ИНФО] Режим только блокировки драйверов. Основные настройки WU не меняются.
goto APPLY_DRIVERS

:APPLY_COMMON
echo [ИНФО] Применение общих настроек контроля...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DisableWindowsUpdateAccess" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "AllowMUUpdateService" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "AutomaticMaintenanceEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "IncludeRecommendedUpdates" /t REG_DWORD /d 0 /f >nul 2>&1

:APPLY_DRIVERS
echo [ИНФО] Блокировка автоматической установки драйверов...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] Настройки применены.
goto END

:RESTORE
echo.
echo [ИНФО] Полный сброс политик Windows Update...

:: Очистка ветки WindowsUpdate
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f >nul 2>&1

:: Очистка ветки AU
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /f >nul 2>&1

:: Сброс поиска драйверов
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /f >nul 2>&1

echo [УСПЕХ] Политики сброшены до заводских настроек.
goto END

:END
echo.
echo [ИТОГ] Операция завершена. Выполните 'gpupdate /force' или перезагрузите ПК.
pause
exit /b 0