
@echo off
chcp 65001 >nul
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - Unified Cert Manager (Silent PFX)
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Тихая установка сертификатов (.cer .crt .pfx) без запроса пароля.
echo.
echo [ИНСТРУКЦИЯ ПО РАЗМЕЩЕНИЮ]
echo Поместите этот BAT-файл и файлы сертификатов в одну папку.
echo Папка должна быть доступна на чтение всем пользователям (для GPO).
echo.
echo [ЧТО ЭТО] Скрипт использует PowerShell для тихой установки.
echo Для файлов .pfx принудительно передается пустой пароль, чтобы избежать остановки.
echo Поддерживает Планировщик (по расписанию) и GPO (при входе).
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Для полной автоматизации. Если у PFX есть пароль, он должен быть пустым.
echo Иначе установка завершится ошибкой, но скрипт продолжит работу с остальными файлами.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Install Now: Установит сертификаты из текущей папки прямо сейчас.
echo   2. Set Scheduler: Задача на ежедневный запуск в 08:00.
echo   3. Set GPO: Запуск при входе пользователя в систему.
echo   4. Restore: Удаление всех задач и временных файлов.
echo.
echo [ВАЖНО] Требуется запуск от имени Администратора.
echo [ВАЖНО] Пути к файлам фиксируются абсолютно в момент настройки.
echo.
echo [АКТИВАЦИЯ] Проверьте наличие сертификатов в certmgr.msc.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: Универсальный поиск PowerShell
set PS_EXE=
if exist "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" set PS_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe
if exist "%ProgramFiles%\PowerShell\7\pwsh.exe" set PS_EXE="%ProgramFiles%\PowerShell\7\pwsh.exe"
if "%PS_EXE%"=="" where powershell >nul 2>&1 && set PS_EXE=powershell.exe
if "%PS_EXE%"=="" (echo [ОШИБКА] PowerShell не найден! & pause & exit /b 1)

echo [УСПЕХ] Найден исполнитель: %PS_EXE%

set SOURCE_DIR=%~dp0
set SCHED_WORKER=%WINDIR%\AKUMEN_CertWorker.ps1
set GPO_WORKER=%WINDIR%\System32\GroupPolicy\User\Scripts\Logon\AKUMEN_CertInstaller.ps1

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] УСТАНОВИТЬ СЕЙЧАС (Install Certificates)
echo [2] НАСТРОИТЬ ШЕДУЛЕР (Ежедневно в 08:00)
echo [3] НАСТРОИТЬ GPO (При входе всех пользователей)
echo [4] ОТКАТ (Удалить всю автоматизацию)
echo [5] ВЫХОД
echo.
set /p choice="Введите номер (1-5) и нажмите Enter: "

if "%choice%"=="1" goto INSTALL_NOW
if "%choice%"=="2" goto SET_SCHEDULER
if "%choice%"=="3" goto SET_GPO
if "%choice%"=="4" goto RESTORE
if "%choice%"=="5" exit /b 0
echo [ОШИБКА] Неверный выбор.
pause & exit /b 1

:INSTALL_NOW
echo.
echo [ИНФО] Тихая установка сертификатов из: %SOURCE_DIR%

if not exist "%SOURCE_DIR%" (
    echo [ОШИБКА] Каталог не существует!
    pause & exit /b 1
)

%PS_EXE% -NoProfile -ExecutionPolicy ByPass -Command "$dir = '%SOURCE_DIR%'; Get-ChildItem $dir -Include *.cer,*.crt,*.pfx | ForEach-Object { if ($_.Extension -eq '.pfx') { certutil -importPFX -user My $_.FullName '' } else { certutil -addstore -user My $_.FullName } }; Write-Host 'Installation Complete'"

goto END

:SET_SCHEDULER
echo.
echo [ИНФО] Создание независимого исполнителя для Шедулера...

echo $dir = "%SOURCE_DIR%" > "%SCHED_WORKER%"
echo Get-ChildItem $dir -Include *.cer,*.crt,*.pfx ^| ForEach-Object { >> "%SCHED_WORKER%"
echo     if ($_.Extension -eq '.pfx') { certutil -importPFX -user My $_.FullName '' } >> "%SCHED_WORKER%"
echo     else { certutil -addstore -user My $_.FullName } >> "%SCHED_WORKER%"
echo } >> "%SCHED_WORKER%"

schtasks /delete /tn "AKUMEN_CertScheduler" /f >nul 2>&1
schtasks /create /tn "AKUMEN_CertScheduler" /tr "\"%PS_EXE%\" -NoProfile -ExecutionPolicy ByPass -File \"%SCHED_WORKER%\"" /sc daily /st 08:00 /ru "SYSTEM" /rl HIGHEST /f >nul 2>&1

echo [УСПЕХ] Задача создана на 08:00 ежедневно.

goto END

:SET_GPO
echo.
echo [ИНФО] Настройка Групповой Политики (Logon Script)...

if not exist "%WINDIR%\System32\GroupPolicy\User\Scripts\Logon\" mkdir "%WINDIR%\System32\GroupPolicy\User\Scripts\Logon\"

echo $dir = "%SOURCE_DIR%" > "%GPO_WORKER%"
echo Get-ChildItem $dir -Include *.cer,*.crt,*.pfx ^| ForEach-Object { >> "%GPO_WORKER%"
echo     if ($_.Extension -eq '.pfx') { certutil -importPFX -user My $_.FullName '' } >> "%GPO_WORKER%"
echo     else { certutil -addstore -user My $_.FullName } >> "%GPO_WORKER%"
echo } >> "%GPO_WORKER%"

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Logon\0\0" /v "Script" /t REG_SZ /d "\"%PS_EXE%\"" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Logon\0\0" /v "Parameters" /t REG_SZ /d "-NoProfile -ExecutionPolicy ByPass -File \"%GPO_WORKER%\"" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Logon\0\0" /v "Script" /t REG_SZ /d "\"%PS_EXE%\"" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Logon\0\0" /v "Parameters" /t REG_SZ /d "-NoProfile -ExecutionPolicy ByPass -File \"%GPO_WORKER%\"" /f >nul 2>&1

gpupdate /force >nul 2>&1

echo [УСПЕХ] Скрипт назначен на вход в систему для всех пользователей.

goto END

:RESTORE
echo.
echo [ИНФО] Полный откат автоматизации...

schtasks /delete /tn "AKUMEN_CertScheduler" /f >nul 2>&1
if exist "%SCHED_WORKER%" del /f /q "%SCHED_WORKER%"

reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Logon\0\0" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Logon\0\0" /f >nul 2>&1
if exist "%GPO_WORKER%" del /f /q "%GPO_WORKER%"

gpupdate /force >nul 2>&1

echo [УСПЕХ] Все задачи и политики удалены.

goto END

:END
echo.
echo [ИТОГ] Операция завершена.
pause
exit /b 0