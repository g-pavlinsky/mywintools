
@echo off
chcp 65001 >nul 2>&1
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - Flexible USB Control Module
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Гибкое управление доступом к различным типам USB-устройств.
echo.
echo [ЧТО ЭТО] Скрипт позволяет выборочно блокировать флешки, внешние диски или токены.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Для тонкой настройки безопасности: от запрета только флешек до полной блокировки.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Блокирует только USB-флешки (токены и внешние HDD работают).
echo   2. Блокирует все накопители (флешки, HDD, SSD), но оставляет токены.
echo   3. Блокирует ВСЕ (флешки, HDD, токены).
echo   4. Полный откат (разрешить всё).
echo.
echo [ВАЖНО] Требуется перезагрузка для полного применения изменений.
echo [ВАЖНО] Внутренние диски (C:, D:) не затрагиваются ни при каком варианте.
echo.
echo [АКТИВАЦИЯ] Проверьте подключение устройств после перезагрузки.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] БЛОКИРОВАТЬ ТОЛЬКО ФЛЕШКИ (Токены и HDD работают)
echo [2] БЛОКИРОВАТЬ НАКОПИТЕЛИ (Флешки, HDD, SSD заблокированы. Токены работают)
echo [3] БЛОКИРОВАТЬ ВСЁ (Флешки, HDD, Токены заблокированы)
echo [4] ОТКАТ (Разрешить все USB-устройства)
echo [5] ВЫХОД
echo.
set /p choice="Введите номер (1-5) и нажмите Enter: "

if "%choice%"=="1" goto BLOCK_FLASH
if "%choice%"=="2" goto BLOCK_STORAGE
if "%choice%"=="3" goto BLOCK_ALL
if "%choice%"=="4" goto RESTORE
if "%choice%"=="5" exit /b 0
echo [ОШИБКА] Неверный выбор.
pause & exit /b 1

:BLOCK_FLASH
echo.
echo [ИНФО] Блокировка только USB-флешек (usbstor)...
sc stop usbstor >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\usbstor" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
echo [УСПЕХ] usbstor отключен. Токены и внешние HDD могут работать (если используют другие драйверы).
goto END

:BLOCK_STORAGE
echo.
echo [ИНФО] Блокировка всех накопителей (usbstor)...
sc stop usbstor >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\usbstor" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
echo [УСПЕХ] usbstor отключен.
echo [ИНФО] Проверка службы Smart Card (токены)...
sc query scserver | find "RUNNING" >nul 2>&1
if %errorlevel% neq 0 (
    sc config scserver start= auto >nul 2>&1
    sc start scserver >nul 2>&1
    echo [УСПЕХ] Служба Smart Card активна.
) else (
    echo [УСПЕХ] Служба Smart Card уже активна.
)
goto END

:BLOCK_ALL
echo.
echo [ИНФО] Полная блокировка внешних USB-устройств...
sc stop usbstor >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\usbstor" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
echo [УСПЕХ] usbstor отключен.
sc stop scserver >nul 2>&1
sc config scserver start= disabled >nul 2>&1
echo [УСПЕХ] scserver отключен.
goto END

:RESTORE
echo.
echo [ИНФО] Восстановление полного доступа к USB...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\usbstor" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
echo [УСПЕХ] usbstor включен.
sc config scserver start= demand >nul 2>&1
echo [УСПЕХ] scserver включена.
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDriveTypeAutoRun" /f >nul 2>&1
echo [УСПЕХ] Настройки автозапуска сброшены.
goto END

:END
echo.
echo [ИТОГ] Операция завершена. Перезагрузите компьютер.
pause
exit /b 0