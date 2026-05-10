
@echo off
chcp 65001 >nul
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - SMB1 and Guest Access Control
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Включение протокола SMB1 и разрешение гостевого доступа
echo.
echo [ЧТО ЭТО] Скрипт активирует устаревший протокол SMB1 и разрешает небезопасные гостевые подключения.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Необходимо для работы со старыми NAS, принтерами, сканерами и устройствами без SMB2/3.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Включит или отключит компонент Windows "SMB1Protocol".
echo   2. Управляет политикой депрекации (предупреждений) SMB1.
echo   3. Разрешит или запретит гостевой доступ (AllowInsecureGuestAuth).
echo.
echo [ВАЖНО] КРИТИЧЕСКИ СНИЖАЕТ БЕЗОПАСНОСТЬ СЕТИ!
echo [ВАЖНО] Уязвимо для атак WannaCry и других ransomware.
echo [ВАЖНО] Используйте только в изолированных сетях или с доверенными устройствами.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора. Требуется перезагрузка.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ВКЛЮЧИТЬ SMB1 и Гостевой доступ (Apply Legacy Mode)
echo [2] ОТКЛЮЧИТЬ SMB1 и Гостевой доступ (Restore Secure Mode)
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
echo [ИНФО] Включение функции SMB1Protocol...
dism /online /enable-feature /featurename:SMB1Protocol /norestart >nul 2>&1
if %errorlevel% equ 0 (
    echo [УСПЕХ] Компонент SMB1 включен.
) else (
    echo [ОШИБКА] Не удалось включить SMB1. Код: %errorlevel%
)

echo [ИНФО] Отключение политики депрекации SMB1...
dism /online /disable-feature /featurename:SMB1Protocol-Deprecation /norestart >nul 2>&1
echo [УСПЕХ] Предупреждения отключены.

echo [ИНФО] Разрешение небезопасного гостевого доступа...
reg add "HKLM\Software\Policies\Microsoft\Windows\LanmanWorkstation" /v "AllowInsecureGuestAuth" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] Гостевой доступ разрешен.

goto END

:RESTORE
echo.
echo [ИНФО] Отключение функции SMB1Protocol...
dism /online /disable-feature /featurename:SMB1Protocol /norestart >nul 2>&1
if %errorlevel% equ 0 (
    echo [УСПЕХ] Компонент SMB1 отключен.
) else (
    echo [ОШИБКА] Не удалось отключить SMB1. Код: %errorlevel%
)

echo [ИНФО] Включение политики депрекации SMB1...
dism /online /enable-feature /featurename:SMB1Protocol-Deprecation /norestart >nul 2>&1
echo [УСПЕХ] Предупреждения включены.

echo [ИНФО] Запрет небезопасного гостевого доступа...
reg add "HKLM\Software\Policies\Microsoft\Windows\LanmanWorkstation" /v "AllowInsecureGuestAuth" /t REG_DWORD /d 0 /f >nul 2>&1
echo [УСПЕХ] Гостевой доступ запрещен.

goto END

:END
echo.
echo [ИТОГ] Настройки применены. Требуется ПЕРЕЗАГРУЗКА системы.
echo [ИНФО] Перезагрузить сейчас? (Y/N)
choice /C YN /M "Перезагрузить"
if errorlevel 2 exit /b 0
shutdown.exe /f /r /t 0
exit /b 0