@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - 1C EDT Performance Tuner
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Глубокий поиск и оптимизация всех версий 1C:EDT.
echo.
echo [ИНСТРУКЦИЯ]
echo Запустите этот файл от имени Администратора.
echo Скрипт самостоятельно просканирует все доступные диски системы.
echo.
echo [ЧТО ЭТО] Скрипт выполняет рекурсивный поиск папок с именем "1CEDT" на всех дисках.
echo Внутри каждой найденной папки он также рекурсивно ищет файл 1cedt.ini.
echo Найденные файлы обновляются: увеличивается память и меняется путь к temp.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Для ускорения работы EDT и предотвращения вылетов.
echo 1. Память (-Xmx): Настраивается доля от объема вашей ОЗУ (в МЕГАБАЙТАХ).
echo 2. На самом быстром диске (желательно NVME M.2) создается короткая папка (например, C:\tmp) для ускорения операций Java.
echo EDT очень чувствительна к длине путей во временных файлах, и к скорости их чтения и записи.
echo.
echo [АЛЬТЕРНАТИВНЫЙ СПОСОБ (РУЧНОЙ)]
echo Если вы хотите настроить всё вручную:
echo 1. Найдите файл 1cedt.ini в папке components вашей версии EDT.
echo 2. Измените строку -Xmx на нужное значение (например, -Xmx8192m).
echo 3. Добавьте строку -Djava.io.tmpdir=C:\tmp (путь к вашей быстрой папке).
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Apply: Рекурсивно найдет все установки EDT на всех дисках и применит настройки.
echo   2. Restore: Уберет внесенные изменения и вернет стандартные значения.
echo.
echo [ВАЖНО] Требуется запуск от имени Администратора.
echo [ВАЖНО] Поиск по всем дискам может занять некоторое время.
echo [ВАЖНО] Изменения вступят в силу при следующем запуске EDT.
echo.
echo [АКТИВАЦИЯ] Перезапустите 1C:EDT после выполнения скрипта.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ГЕНЕРАЦИЯ PS1 ФАЙЛА ---
set "TEMP_PS=%TEMP%\edt_config.ps1"
if exist "%TEMP_PS%" del /f /q "%TEMP_PS%"

:: 1. Функция поиска
echo function Find-Edt-All-Disks { > "%TEMP_PS%"
echo     $foundFiles = @() >> "%TEMP_PS%"
echo     $drives = Get-Volume ^| Where-Object { $_.DriveLetter } ^| Select-Object -ExpandProperty DriveLetter >> "%TEMP_PS%"
echo     foreach ($d in $drives) { >> "%TEMP_PS%"
echo         $folders = Get-ChildItem -Path "${d}:\" -Directory -Filter "*1CEDT*" -Recurse -ErrorAction SilentlyContinue >> "%TEMP_PS%"
echo         foreach ($folder in $folders) { >> "%TEMP_PS%"
echo             $ini = Get-ChildItem -Path $folder.FullName -Filter "1cedt.ini" -Recurse -ErrorAction SilentlyContinue ^| Select-Object -First 1 >> "%TEMP_PS%"
echo             if ($ini) { >> "%TEMP_PS%"
echo                 if ($foundFiles -notcontains $ini.FullName) { >> "%TEMP_PS%"
echo                     $foundFiles += $ini.FullName >> "%TEMP_PS%"
echo                 } >> "%TEMP_PS%"
echo             } >> "%TEMP_PS%"
echo         } >> "%TEMP_PS%"
echo     } >> "%TEMP_PS%"
echo     if ($foundFiles.Count -gt 0) { return $foundFiles } else { return "NOT_FOUND" } >> "%TEMP_PS%"
echo } >> "%TEMP_PS%"

:: 2. Функция обработки (принимает Ratio как аргумент)
echo. >> "%TEMP_PS%"
echo function Edit-Edt-Ini { >> "%TEMP_PS%"
echo     param([string]$Action, [string]$IniPath, [string]$TmpPath, [double]$Ratio) >> "%TEMP_PS%"
echo. >> "%TEMP_PS%"
echo     if (-not (Test-Path $IniPath)) { Write-Error "File not found"; return } >> "%TEMP_PS%"
echo. >> "%TEMP_PS%"
echo     $totalMemGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB) >> "%TEMP_PS%"
echo     $recommendedMB = [math]::Max(4096, [math]::Floor(($totalMemGB * 1024 * $Ratio))) >> "%TEMP_PS%"
echo     $xmxValue = "-Xmx${recommendedMB}m" >> "%TEMP_PS%"
echo. >> "%TEMP_PS%"
echo     Write-Host "[INFO] RAM: ${totalMemGB}GB. Ratio: ${Ratio}. Setting Max Heap: ${recommendedMB}MB" >> "%TEMP_PS%"
echo. >> "%TEMP_PS%"
echo     $content = Get-Content $IniPath -Encoding ASCII >> "%TEMP_PS%"
echo     $newContent = @() >> "%TEMP_PS%"
echo     $xmxFound = $false >> "%TEMP_PS%"
echo     $tmpdirFound = $false >> "%TEMP_PS%"
echo. >> "%TEMP_PS%"
echo     foreach ($line in $content) { >> "%TEMP_PS%"
echo         if ($line -match '^\s*-Xmx') { >> "%TEMP_PS%"
echo             if ($Action -eq "Apply") { $newContent += $xmxValue } else { $newContent += "-Xmx4096m" } >> "%TEMP_PS%"
echo             $xmxFound = $true >> "%TEMP_PS%"
echo         } elseif ($line -match '^\s*-Djava.io.tmpdir=') { >> "%TEMP_PS%"
echo             if ($Action -eq "Apply") { $newContent += "-Djava.io.tmpdir=${TmpPath}" } else { continue } >> "%TEMP_PS%"
echo             $tmpdirFound = $true >> "%TEMP_PS%"
echo         } else { >> "%TEMP_PS%"
echo             $newContent += $line >> "%TEMP_PS%"
echo         } >> "%TEMP_PS%"
echo     } >> "%TEMP_PS%"
echo. >> "%TEMP_PS%"
echo     if ($Action -eq "Apply") { >> "%TEMP_PS%"
echo         if (-not $xmxFound) { $newContent += $xmxValue } >> "%TEMP_PS%"
echo         if (-not $tmpdirFound) { $newContent += "-Djava.io.tmpdir=${TmpPath}" } >> "%TEMP_PS%"
echo     } >> "%TEMP_PS%"
echo. >> "%TEMP_PS%"
echo     $newContent ^| Set-Content $IniPath -Encoding ASCII >> "%TEMP_PS%"
echo     Write-Host "[OK] Done: $IniPath" >> "%TEMP_PS%"
echo } >> "%TEMP_PS%"

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ПРИМЕНИТЬ ОПТИМИЗАЦИЮ (Apply)
echo [2] ОТКАТ (Restore Defaults)
echo [3] ВЫХОД
echo.
set /p choice="Введите номер (1-3) и нажмите Enter: "

if "%choice%"=="1" goto APPLY
if "%choice%"=="2" goto RESTORE
if "%choice%"=="3" goto CLEANUP
echo [ОШИБКА] Неверный выбор.
goto CLEANUP

:APPLY
echo.
echo [ВЫБОР ДОЛИ ПАМЯТИ]
echo Сколько оперативной памяти выделить под EDT?
echo [1] 1/3 от общего объема (Рекомендуется для стандартных ПК)
echo [2] 1/4 от общего объема (Рекомендуется для рабочих станций с большим объемом памяти)
echo.
set /p MEM_CHOICE="Ваш выбор (1 или 2): "

if "%MEM_CHOICE%"=="2" (
    set "RATIO=0.25"
) else (
    set "RATIO=0.3333"
)

echo.
echo [ИНФО] Рекурсивный поиск папок 1CEDT на всех дисках системы...

:: Загружаем функции и выполняем поиск
powershell -NoProfile -ExecutionPolicy ByPass -Command ". '%TEMP_PS%'; Find-Edt-All-Disks" > "%TEMP%\edt_ini_list.txt"

set /p FIRST_LINE=<"%TEMP%\edt_ini_list.txt"
if "%FIRST_LINE%"=="NOT_FOUND" (
    echo [ОШИБКА] Папки 1CEDT не найдены ни на одном диске.
    goto CLEANUP
)

:: --- МЕНЮ ВЫБОРА ДИСКА ---
echo.
echo [ВЫБОР ДИСКА ДЛЯ ПАПКИ TMP]
echo.

powershell -NoProfile -Command "(Get-Volume | Where-Object { $_.DriveLetter } | Select-Object -ExpandProperty DriveLetter) -join ' '" > "%TEMP%\drive_list.txt"
set /p DRIVE_LIST=<"%TEMP%\drive_list.txt"

set IDX=0
for %%D in (%DRIVE_LIST%) do (
    set /a IDX+=1
    set "DRIVE_!IDX!=%%D"
)
set TOTAL_DRIVES=!IDX!

echo ВЫБЕРИТЕ ДИСК:
for /L %%i in (1,1,%TOTAL_DRIVES%) do (
    echo [%%i] Диск !DRIVE_%%i!:
)
echo [*] Ввести букву вручную
echo.

set /p DISK_CHOICE="Ваш выбор (номер или буква): "

set "TMP_DISK="
set IS_NUM=0
for /L %%i in (1,1,%TOTAL_DRIVES%) do (
    if "%DISK_CHOICE%"=="%%i" set "IS_NUM=1"
)

if "%IS_NUM%"=="1" (
    for /L %%i in (1,1,%TOTAL_DRIVES%) do (
        if "%DISK_CHOICE%"=="%%i" set "TMP_DISK=!DRIVE_%%i!"
    )
) else (
    set "TMP_DISK=%DISK_CHOICE%"
)

set "TMP_DISK=%TMP_DISK::=%"
set "TMP_DISK=%TMP_DISK:\=%"
set "TMP_PATH=%TMP_DISK%:\tmp"

if not exist "%TMP_PATH%" mkdir "%TMP_PATH%"
echo [ИНФО] Папка tmp создана: %TMP_PATH%
echo.

:: Обрабатываем файлы, передавая выбранную пропорцию (Ratio)
for /f "usebackq delims=" %%i in ("%TEMP%\edt_ini_list.txt") do (
    echo [ОБРАБОТКА] %%i
    powershell -NoProfile -ExecutionPolicy ByPass -Command ". '%TEMP_PS%'; Edit-Edt-Ini -Action 'Apply' -IniPath '%%i' -TmpPath '%TMP_PATH%' -Ratio %RATIO%"
    echo.
)

echo [УСПЕХ] Все версии обработаны.
goto CLEANUP

:RESTORE
echo.
echo [ИНФО] Рекурсивный поиск папок 1CEDT...

powershell -NoProfile -ExecutionPolicy ByPass -Command ". '%TEMP_PS%'; Find-Edt-All-Disks" > "%TEMP%\edt_ini_list.txt"

set /p FIRST_LINE=<"%TEMP%\edt_ini_list.txt"
if "%FIRST_LINE%"=="NOT_FOUND" (
    echo [ОШИБКА] Папки 1CEDT не найдены.
    goto CLEANUP
)

for /f "usebackq delims=" %%i in ("%TEMP%\edt_ini_list.txt") do (
    echo [ОБРАБОТКА] %%i
    powershell -NoProfile -ExecutionPolicy ByPass -Command ". '%TEMP_PS%'; Edit-Edt-Ini -Action 'Restore' -IniPath '%%i'"
    echo.
)

echo [УСПЕХ] Настройки сброшены.
goto CLEANUP

:CLEANUP
if exist "%TEMP_PS%" del /f /q "%TEMP_PS%" >nul 2>&1
if exist "%TEMP%\edt_ini_list.txt" del /f /q "%TEMP%\edt_ini_list.txt" >nul 2>&1
if exist "%TEMP%\drive_list.txt" del /f /q "%TEMP%\drive_list.txt" >nul 2>&1
echo.
echo [ИТОГ] Операция завершена.
pause
exit /b 0