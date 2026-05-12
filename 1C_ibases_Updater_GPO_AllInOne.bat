
@echo off
chcp 65001 >nul 2>&1
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - 1C Base Updater via GPO Module
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Обновление ibases.v8i у всех вошедших в систему пользователей домена.
echo.
echo [ИНСТРУКЦИЯ ПО РАЗМЕЩЕНИЮ]
echo 1. Создайте папку, доступную всем пользователям на чтение (например C:\Public\1C).
echo 2. Поместите в нее этот BAT-файл и файл ibases.v8i.
echo 3. Запустите BAT-файл от имени Администратора.
echo.
echo [ЧТО ЭТО] Скрипт автоматически находит любую установленную версию PowerShell.
echo Создает автономный скрипт обновления и назначает его через Local GPO.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Для автоматической раздачи актуальных подключений 1С всем сотрудникам.
echo Работает при каждом входе пользователя в систему независимо от версии ОС.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Update Now: Немедленно обновит ibases.v8i в профиле текущего пользователя.
echo   2. Set GPO: Настроит автообновление при входе любого пользователя.
echo   3. Restore: Удалит настройки GPO и временные файлы.
echo.
echo [ВАЖНО] Папка с файлами не должна перемещаться после настройки GPO.
echo [ВАЖНО] Требуется запуск от имени Администратора.
echo.
echo [АКТИВАЦИЯ] Перезайдите в систему для проверки работы GPO.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: Универсальный поиск PowerShell
set PS_EXE=
if exist "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" set PS_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe
if exist "%ProgramFiles%\PowerShell\7\pwsh.exe" set PS_EXE="%ProgramFiles%\PowerShell\7\pwsh.exe"
if exist "%ProgramFiles(x86)%\PowerShell\7\pwsh.exe" set PS_EXE="%ProgramFiles(x86)%\PowerShell\7\pwsh.exe"

if "%PS_EXE%"=="" (
    where powershell >nul 2>&1 && set PS_EXE=powershell.exe
)

if "%PS_EXE%"=="" (
    echo [ОШИБКА] PowerShell не найден в системе.
    pause & exit /b 1
)

echo [УСПЕХ] Найден исполнитель: %PS_EXE%

set SOURCE_DIR=%~dp0
set SOURCE_FILE=%SOURCE_DIR%ibases.v8i
set GPO_WORKER=%WINDIR%\System32\GroupPolicy\User\Scripts\Logon\AKUMEN_1CUpdater.ps1

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ОБНОВИТЬ СЕЙЧАС (Update ibases.v8i)
echo [2] НАСТРОИТЬ GPO (Автообновление при входе)
echo [3] ОТКАТ (Удалить GPO и скрипт)
echo [4] ВЫХОД
echo.
set /p choice="Введите номер (1-4) и нажмите Enter: "

if "%choice%"=="1" goto UPDATE_NOW
if "%choice%"=="2" goto SET_GPO
if "%choice%"=="3" goto RESTORE
if "%choice%"=="4" exit /b 0
echo [ОШИБКА] Неверный выбор.
pause & exit /b 1

:UPDATE_NOW
echo.
echo [ИНФО] Обновление списков баз 1С...

if not exist "%SOURCE_FILE%" (
    echo [ОШИБКА] Файл ibases.v8i не найден в папке: %SOURCE_DIR%
    pause & exit /b 1
)

%PS_EXE% -NoProfile -ExecutionPolicy ByPass -Command "$targetDir = Join-Path -Path ([Environment]::GetFolderPath('ApplicationData')) -ChildPath '\1C\1CEStart'; $targetDir2 = Join-Path -Path ([Environment]::GetFolderPath('LocalApplicationData')) -ChildPath '\1C\1CEStart'; if (-Not (Test-Path -Path $targetDir)) { New-Item -Path $targetDir -ItemType Directory -Force }; if (-Not (Test-Path -Path $targetDir2)) { New-Item -Path $targetDir2 -ItemType Directory -Force }; Copy-Item -Path '%SOURCE_FILE%' -Destination $targetDir -Force; Copy-Item -Path '%SOURCE_FILE%' -Destination $targetDir2 -Force; Write-Host 'Update Complete'"

if %errorlevel% equ 0 (
    echo [УСПЕХ] Файл ibases.v8i успешно обновлен.
) else (
    echo [ОШИБКА] Не удалось обновить файл.
)

goto END

:SET_GPO
echo.
echo [ИНФО] Настройка автоматического обновления через GPO...

if not exist "%SOURCE_FILE%" (
    echo [ОШИБКА] Файл ibases.v8i не найден в папке: %SOURCE_DIR%
    pause & exit /b 1
)

if not exist "%WINDIR%\System32\GroupPolicy\User\Scripts\Logon\" mkdir "%WINDIR%\System32\GroupPolicy\User\Scripts\Logon\"

:: Создаем PowerShell скрипт с полным путем к источнику
echo $sourceFile = "%SOURCE_FILE%" > "%GPO_WORKER%"
echo $targetDir = Join-Path -Path ([Environment]::GetFolderPath("ApplicationData")) -ChildPath "\1C\1CEStart" >> "%GPO_WORKER%"
echo $targetDir2 = Join-Path -Path ([Environment]::GetFolderPath("LocalApplicationData")) -ChildPath "\1C\1CEStart" >> "%GPO_WORKER%"
echo if (-Not (Test-Path -Path $targetDir)) { New-Item -Path $targetDir -ItemType Directory -Force } >> "%GPO_WORKER%"
echo if (-Not (Test-Path -Path $targetDir2)) { New-Item -Path $targetDir2 -ItemType Directory -Force } >> "%GPO_WORKER%"
echo Copy-Item -Path $sourceFile -Destination $targetDir -Force >> "%GPO_WORKER%"
echo Copy-Item -Path $sourceFile -Destination $targetDir2 -Force >> "%GPO_WORKER%"

:: Назначаем скрипт через реестр Local GPO
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Logon\0\0" /v "Script" /t REG_SZ /d "\"%PS_EXE%\"" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Logon\0\0" /v "Parameters" /t REG_SZ /d "-NoProfile -ExecutionPolicy ByPass -File \"%GPO_WORKER%\"" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Logon\0\0" /v "Script" /t REG_SZ /d "\"%PS_EXE%\"" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Logon\0\0" /v "Parameters" /t REG_SZ /d "-NoProfile -ExecutionPolicy ByPass -File \"%GPO_WORKER%\"" /f >nul 2>&1

gpupdate /force >nul 2>&1

echo [УСПЕХ] GPO настроена. Путь к файлу зафиксирован: %SOURCE_FILE%

goto END

:RESTORE
echo.
echo [ИНФО] Очистка настроек GPO...

reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Logon\0\0" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Logon\0\0" /f >nul 2>&1

if exist "%GPO_WORKER%" del /f /q "%GPO_WORKER%"

gpupdate /force >nul 2>&1

echo [УСПЕХ] Автоматическое обновление отключено.

goto END

:END
echo.
echo [ИТОГ] Операция завершена.
pause
exit /b 0