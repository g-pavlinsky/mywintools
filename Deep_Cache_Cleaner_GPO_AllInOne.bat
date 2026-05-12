
@echo off
chcp 65001 >nul 2>&1
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - Extended Deep Cache Cleaner Module
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Тотальная очистка системы, профилей и безопасных зон Roaming.
echo.
echo [ИНСТРУКЦИЯ ПО РАЗМЕЩЕНИЮ И ЗАПУСКУ]
echo 1. Запустите этот файл один раз от имени Администратора в любом месте.
echo 2. Скрипт сам создаст все необходимые файлы в системных папках Windows.
echo 3. Для автоматической работы выберите пункт [5] (Настроить GPO).
echo.
echo [ПОДДЕРЖИВАЕМЫЕ БРАУЗЕРЫ И ПРИЛОЖЕНИЯ]
echo - Google Chrome, Yandex Browser, Microsoft Edge, Opera/GX.
echo - Mozilla Firefox: Умный поиск профилей и очистка cache2.
echo - 1C Enterprise: Сброс кэша конфигураций каждые 10 входов (счетчик).
echo - Adobe Creative Cloud: Очистка Media Cache (Premiere/After Effects).
echo - Java Runtime: Очистка устаревшего кэша развертывания.
echo.
echo [БЕЗОПАСНАЯ ОЧИСТКА ROAMING]
echo Скрипт чистит только мусорные папки в AppData\Roaming, не трогая настройки:
echo - Recent Items: История последних открытых файлов (исправлено).
echo - Roaming Temp: Временные файлы, ошибочно созданные программами в Roaming.
echo - Adobe/Java Caches: Специфичный кэш, который часто разрастается.
echo.
echo [СИСТЕМНАЯ ГЛУБОКАЯ ОЧИСТКА]
echo - Windows Update: Удаление старых пакетов из SoftwareDistribution.
echo - Event Logs: Полная очистка журналов событий (Application, System, Security).
echo - DNS Cache: Сброс сетевых разрешений для устранения проблем с доступом.
echo - Prefetch: Удаление данных о запуске программ.
echo - WER Reports: Удаление отчетов об ошибках и дампов памяти.
echo.
echo [МОДУЛИ ОЧИСТКИ]
echo 1. Current User Only: Вы + Safe Roaming + Браузеры + 1C.
echo 2. Other Users Only: Сканирует C:\Users и чистит ВСЕ остальные профили.
echo 3. System Only: Только системные службы и журналы (без профилей).
echo 4. Global Clean: Объединяет все три пункта выше (Total Clean) без пауз.
echo 5. Set GPO: Автоочистка при входе (Current User + Safe Roaming).
echo.
echo [ЗАЧЕМ ЭТО НУЖНО]
echo - Пункт 2 полезен, если нужно почистить "забытые" профили без входа в них.
echo - Пункт 3 освобождает место на системном диске C: без трогания личных данных.
echo - Пункт 4 — это "ядерный вариант" для полного обслуживания ПК.
echo.
echo [ВАЖНО] Требуется запуск от имени Администратора.
echo [ВАЖНО] Глобальная очистка может занять значительное время.
echo [ВАЖНО] Закройте все программы перед запуском пункта [1] или [4].
echo.
echo [АКТИВАЦИЯ] Перезайдите в систему под любым пользователем для проверки GPO.
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

set GPO_WORKER=%WINDIR%\System32\GroupPolicy\User\Scripts\Logon\AKUMEN_CacheCleaner.ps1

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ТОЛЬКО ТЕКУЩИЙ ПОЛЬЗОВАТЕЛЬ (You + Safe Roaming)
echo [2] ТОЛЬКО ОСТАЛЬНЫЕ ПОЛЬЗОВАТЕЛИ (Others in C:\Users)
echo [3] ТОЛЬКО СИСТЕМА (Windows Update, Logs, DNS)
echo [4] ГЛОБАЛЬНАЯ ОЧИСТКА (All Users + System + Roaming)
echo [5] НАСТРОИТЬ GPO (Автоочистка при входе)
echo [6] ОТКАТ (Удалить GPO)
echo [7] ВЫХОД
echo.
set /p choice="Введите номер (1-7) и нажмите Enter: "

if "%choice%"=="1" goto CLEAN_CURRENT
if "%choice%"=="2" goto CLEAN_OTHERS
if "%choice%"=="3" goto CLEAN_SYSTEM
if "%choice%"=="4" goto CLEAN_GLOBAL
if "%choice%"=="5" goto SET_GPO
if "%choice%"=="6" goto RESTORE
if "%choice%"=="7" exit /b 0
echo [ОШИБКА] Неверный выбор.
pause & exit /b 1

:CLEAN_CURRENT
echo.
echo [ИНФО] Очистка текущего пользователя и Safe Roaming...
%PS_EXE% -NoProfile -ExecutionPolicy ByPass -Command "$counterFile = Join-Path $env:USERPROFILE '1CCounter.txt'; if (!(Test-Path $counterFile)) { 0 | Out-File $counterFile }; $c = [int](Get-Content $counterFile); $c++; $c | Out-File $counterFile; Write-Host 'Cleaning Local...'; Remove-Item -Path \"$env:TEMP\*\" -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path \"$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db\" -Force -ErrorAction SilentlyContinue; Remove-Item -Path \"$env:LOCALAPPDATA\Yandex\YandexBrowser\User Data\Default\Cache\*\" -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path \"$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*\" -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path \"$env:LOCALAPPDATA\Opera Software\*\Cache\*\" -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path \"$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*\" -Recurse -Force -ErrorAction SilentlyContinue; Get-ChildItem -Path \"$env:APPDATA\Mozilla\Firefox\Profiles\" -Directory | Where-Object { $_.Name -like '*default*' } | ForEach-Object { Remove-Item -Path \"$_.FullName\cache2\*\" -Recurse -Force -ErrorAction SilentlyContinue }; Write-Host 'Cleaning Safe Roaming...'; Remove-Item -Path \"$env:APPDATA\Microsoft\Windows\Recent\*\" -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path \"$env:APPDATA\Adobe\Common\Media Cache Files\*\" -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path \"$env:APPDATA\Sun\Java\Deployment\cache\*\" -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path \"$env:APPDATA\Temp\*\" -Recurse -Force -ErrorAction SilentlyContinue; if ($c -ge 10) { Write-Host 'Cleaning 1C...'; Remove-Item -Path \"$env:USERPROFILE\.1C\*\" -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path \"$env:APPDATA\1C\1Cv8\*\" -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path \"$env:LOCALAPPDATA\1C\1Cv8\*\" -Recurse -Force -ErrorAction SilentlyContinue; 0 | Out-File $counterFile }"
echo [УСПЕХ] Текущий пользователь очищен.
goto :EOF

:CLEAN_OTHERS
echo.
echo [ИНФО] Очистка остальных пользователей в C:\Users...
%PS_EXE% -NoProfile -ExecutionPolicy ByPass -Command "Write-Host 'Scanning C:\Users...'; Get-ChildItem 'C:\Users' -Directory | Where-Object { $_.Name -ne 'Public' -and $_.Name -ne 'Default' -and $_.Name -ne $env:USERNAME } | ForEach-Object { $uPath = $_.FullName; Write-Host \"Cleaning: $uPath\"; Remove-Item -Path \"$uPath\AppData\Local\Temp\*\" -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path \"$uPath\AppData\Local\Microsoft\Windows\INetCache\*\" -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path \"$uPath\AppData\Local\Microsoft\Windows\WebCache\*\" -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path \"$uPath\AppData\Local\Yandex\YandexBrowser\User Data\Default\Cache\*\" -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path \"$uPath\AppData\Local\Google\Chrome\User Data\Default\Cache\*\" -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path \"$uPath\AppData\Roaming\Microsoft\Windows\Recent\*\" -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path \"$uPath\AppData\Roaming\Adobe\Common\Media Cache Files\*\" -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path \"$uPath\AppData\Roaming\Sun\Java\Deployment\cache\*\" -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path \"$uPath\AppData\Roaming\Temp\*\" -Recurse -Force -ErrorAction SilentlyContinue }; Write-Host 'Other Users Clean Complete.'"
echo [УСПЕХ] Остальные пользователи очищены.
goto :EOF

:CLEAN_SYSTEM
echo.
echo [ИНФО] Запуск системной очистки...
echo [ИНФО] Остановка служб...
net stop wuauserv >nul 2>&1 & net stop cryptSvc >nul 2>&1 & net stop bits >nul 2>&1 & net stop msiserver >nul 2>&1
echo [ИНФО] Очистка Update...
del /q /f /s C:\Windows\SoftwareDistribution\Download\*.* >nul 2>&1
echo [ИНФО] Запуск служб...
net start wuauserv >nul 2>&1 & net start cryptSvc >nul 2>&1 & net start bits >nul 2>&1 & net start msiserver >nul 2>&1
echo [ИНФО] Очистка журналов...
for /F "tokens=*" %%G in ('wevtutil el') do (wevtutil cl "%%G" >nul 2>&1)
echo [ИНФО] Сброс DNS...
ipconfig /flushdns >nul 2>&1
echo [ИНФО] Очистка Prefetch и WER...
del /q /f /s C:\Windows\Prefetch\*.* >nul 2>&1
del /q /f /s C:\ProgramData\Microsoft\Windows\WER\ReportArchive\*.* >nul 2>&1
del /q /f /s C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*.* >nul 2>&1
echo [УСПЕХ] Система очищена.
goto :EOF

:CLEAN_GLOBAL
echo.
echo [ИНФО] Запуск ГЛОБАЛЬНОЙ очистки (Все модули)...
call :CLEAN_CURRENT
call :CLEAN_OTHERS
call :CLEAN_SYSTEM
echo [УСПЕХ] Глобальная очистка завершена.
goto END

:SET_GPO
echo.
echo [ИНФО] Настройка GPO (Current User + Safe Roaming)...
if not exist "%WINDIR%\System32\GroupPolicy\User\Scripts\Logon\" mkdir "%WINDIR%\System32\GroupPolicy\User\Scripts\Logon\"
echo $counterFile = Join-Path $env:USERPROFILE '1CCounter.txt' > "%GPO_WORKER%"
echo if (!(Test-Path $counterFile)) { 0 ^| Out-File $counterFile } >> "%GPO_WORKER%"
echo $c = [int](Get-Content $counterFile) >> "%GPO_WORKER%"
echo $c++ >> "%GPO_WORKER%"
echo $c ^| Out-File $counterFile >> "%GPO_WORKER%"
echo Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue >> "%GPO_WORKER%"
echo Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Force -ErrorAction SilentlyContinue >> "%GPO_WORKER%"
echo Remove-Item -Path "$env:LOCALAPPDATA\Yandex\YandexBrowser\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue >> "%GPO_WORKER%"
echo Remove-Item -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue >> "%GPO_WORKER%"
echo Remove-Item -Path "$env:LOCALAPPDATA\Opera Software\*\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue >> "%GPO_WORKER%"
echo Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue >> "%GPO_WORKER%"
echo Get-ChildItem -Path "$env:APPDATA\Mozilla\Firefox\Profiles" -Directory ^| Where-Object { $_.Name -like '*default*' } ^| ForEach-Object { Remove-Item -Path "$_.FullName\cache2\*" -Recurse -Force -ErrorAction SilentlyContinue } >> "%GPO_WORKER%"
echo Remove-Item -Path "$env:APPDATA\Microsoft\Windows\Recent\*" -Recurse -Force -ErrorAction SilentlyContinue >> "%GPO_WORKER%"
echo Remove-Item -Path "$env:APPDATA\Adobe\Common\Media Cache Files\*" -Recurse -Force -ErrorAction SilentlyContinue >> "%GPO_WORKER%"
echo Remove-Item -Path "$env:APPDATA\Sun\Java\Deployment\cache\*" -Recurse -Force -ErrorAction SilentlyContinue >> "%GPO_WORKER%"
echo Remove-Item -Path "$env:APPDATA\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue >> "%GPO_WORKER%"
echo if ($c -ge 10) { Remove-Item -Path "$env:USERPROFILE\.1C\*" -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path "$env:APPDATA\1C\1Cv8\*" -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item -Path "$env:LOCALAPPDATA\1C\1Cv8\*" -Recurse -Force -ErrorAction SilentlyContinue; 0 ^| Out-File $counterFile } >> "%GPO_WORKER%"

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Logon\0\0" /v "Script" /t REG_SZ /d "\"%PS_EXE%\"" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Logon\0\0" /v "Parameters" /t REG_SZ /d "-NoProfile -ExecutionPolicy ByPass -File \"%GPO_WORKER%\"" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Logon\0\0" /v "Script" /t REG_SZ /d "\"%PS_EXE%\"" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Logon\0\0" /v "Parameters" /t REG_SZ /d "-NoProfile -ExecutionPolicy ByPass -File \"%GPO_WORKER%\"" /f >nul 2>&1
gpupdate /force >nul 2>&1
echo [УСПЕХ] GPO настроена.
goto END

:RESTORE
echo.
echo [ИНФО] Удаление GPO...
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Logon\0\0" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Logon\0\0" /f >nul 2>&1
if exist "%GPO_WORKER%" del /f /q "%GPO_WORKER%"
gpupdate /force >nul 2>&1
echo [УСПЕХ] Откат выполнен.
goto END

:END
echo.
echo [ИТОГ] Операция завершена.
pause
exit /b 0