
@echo off
chcp 65001 >nul
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - Defender Exclusion Manager Radmin Server
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Добавление исключений в Защитник Windows (Microsoft Defender)
echo.
echo [ЧТО ЭТО] Скрипт управляет списком исключений для антивирусной проверки.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Предотвращение ложных срабатываний и блокировки легитимного ПО (например, RServer).
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Добавит указанный путь в исключения Защитника.
echo   2. Позволит удалить добавленное исключение при необходимости.
echo.
echo [ВАЖНО] Требуется запуск от имени Администратора.
echo [ВАЖНО] Снижение уровня защиты системы при добавлении ненадежных путей.
echo.
echo [АКТИВАЦИЯ] Проверьте список исключений в настройках Защитника Windows.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ДОБАВИТЬ исключение (C:\Windows\SysWOW64\rserver30)
echo [2] УДАЛИТЬ исключение (Restore)
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
echo [ИНФО] Добавление исключения в Защитник Windows...

PowerShell.exe -ExecutionPolicy Bypass -Command "Add-MpPreference -ExclusionPath 'C:\Windows\SysWOW64\rserver30'"
if %errorlevel% equ 0 (
    echo [УСПЕХ] Исключение успешно добавлено.
) else (
    echo [ОШИБКА] Не удалось добавить исключение. Проверьте путь или состояние Защитника.
)

goto END

:RESTORE
echo.
echo [ИНФО] Удаление исключения из Защитника Windows...

PowerShell.exe -ExecutionPolicy Bypass -Command "Remove-MpPreference -ExclusionPath 'C:\Windows\SysWOW64\rserver30'"
if %errorlevel% equ 0 (
    echo [УСПЕХ] Исключение успешно удалено.
) else (
    echo [ОШИБКА] Не удалось удалить исключение. Возможно, его не существует.
)

goto END

:END
echo.
echo [ИТОГ] Операция завершена.
pause
exit /b 0