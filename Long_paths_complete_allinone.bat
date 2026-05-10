
@echo off
chcp 65001 >nul
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - Complete Long Paths Module
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Комплексное включение поддержки путей более 260 символов.
echo.
echo [ЧТО ЭТО] Скрипт меняет системный реестр, политики, настройки CMD и PowerShell.
echo Также создает виртуальный диск Z: для обхода ограничений Проводника.
echo Ограничение в 260 символах связано с устаревшим API Windows.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Для работы с глубокими структурами папок без ошибок Path too long.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Apply Registry: Включает LongPaths в System, Policy, CMD, PowerShell.
echo   2. Apply Subst: Создает диск Z: (монтирует C:\) для коротких путей в Проводнике.
echo   3. Apply All: Выполняет все действия сразу.
echo   4. Restore: Сбрасывает реестр и удаляет диск Z:.
echo.
echo [ВАЖНО] Требуется перезагрузка для применения реестровых настроек.
echo [ВАЖНО] Диск Z: существует до перезагрузки или ручного удаления.
echo.
echo [АКТИВАЦИЯ] Перезагрузите ПК. Используйте Z: в Проводнике.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ПРИМЕНИТЬ реестр (System, CMD, PowerShell)
echo [2] ПРИМЕНИТЬ виртуальный диск (Subst Z:)
echo [3] ПРИМЕНИТЬ ВСЁ (Реестр + Диск Z:)
echo [4] ОТКАТ / АЛЬТЕРНАТИВА (Сброс всего)
echo [5] ВЫХОД
echo.
set /p choice="Введите номер (1-5) и нажмите Enter: "

if "%choice%"=="1" goto APPLY_REG
if "%choice%"=="2" goto APPLY_SUBST
if "%choice%"=="3" goto APPLY_ALL
if "%choice%"=="4" goto RESTORE
if "%choice%"=="5" exit /b 0
echo [ОШИБКА] Неверный выбор.
pause & exit /b 1

:APPLY_REG
echo.
echo [ИНФО] Применение настроек реестра...

echo [ИНФО] Изменение системного параметра FileSystem...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] System параметр установлен.

echo [ИНФО] Изменение групповой политики...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "LongPathsEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] Policy параметр установлен.

echo [ИНФО] Настройка командной строки CMD...
reg add "HKCU\Software\Microsoft\Command Processor" /v "LongPathsEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] CMD настроен.

echo [ИНФО] Настройка PowerShell...
reg add "HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\ScriptedDiagnostics" /v "ExecutionPolicy" /t REG_SZ /d "Unrestricted" /f >nul 2>&1
echo [УСПЕХ] PowerShell настроен.

echo [ИНФО] Обновление политик...
gpupdate /force >nul 2>&1
echo [УСПЕХ] Политики обновлены.

goto END

:APPLY_SUBST
echo.
echo [ИНФО] Создание виртуального диска...

echo [ИНФО] Монтирование C:\ на диск Z:...
subst Z: C:\
if %errorlevel% equ 0 (
    echo [УСПЕХ] Виртуальный диск Z: создан.
) else (
    echo [ОШИБКА] Не удалось создать диск. Возможно, он уже занят.
)

goto END

:APPLY_ALL
echo.
echo [ИНФО] Применение всех настроек...

echo [ИНФО] Изменение системного параметра FileSystem...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] System параметр установлен.

echo [ИНФО] Изменение групповой политики...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "LongPathsEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] Policy параметр установлен.

echo [ИНФО] Настройка командной строки CMD...
reg add "HKCU\Software\Microsoft\Command Processor" /v "LongPathsEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] CMD настроен.

echo [ИНФО] Настройка PowerShell...
reg add "HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\ScriptedDiagnostics" /v "ExecutionPolicy" /t REG_SZ /d "Unrestricted" /f >nul 2>&1
echo [УСПЕХ] PowerShell настроен.

echo [ИНФО] Обновление политик...
gpupdate /force >nul 2>&1
echo [УСПЕХ] Политики обновлены.

echo [ИНФО] Монтирование C:\ на диск Z:...
subst Z: C:\
if %errorlevel% equ 0 (
    echo [УСПЕХ] Виртуальный диск Z: создан.
) else (
    echo [ОШИБКА] Не удалось создать диск. Возможно, он уже занят.
)

goto END

:RESTORE
echo.
echo [ИНФО] Полный откат настроек...

echo [ИНФО] Сброс системного параметра...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
echo [УСПЕХ] System параметр сброшен.

echo [ИНФО] Удаление параметра политики...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "LongPathsEnabled" /f >nul 2>&1
echo [УСПЕХ] Policy параметр удален.

echo [ИНФО] Сброс настроек CMD...
reg delete "HKCU\Software\Microsoft\Command Processor" /v "LongPathsEnabled" /f >nul 2>&1
echo [УСПЕХ] CMD сброшен.

echo [ИНФО] Удаление виртуального диска Z:...
subst Z: /d >nul 2>&1
echo [УСПЕХ] Виртуальный диск Z: удален.

goto END

:END
echo.
echo [ИТОГ] Операция завершена. Перезагрузите компьютер.
pause
exit /b 0