@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - 1C Developer Dangerous Action Protection
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Отключение "Защиты от опасных действий" по умолчанию в ОС для разработчиков 1С.
echo.
echo [ИНСТРУКЦИЯ]
echo Запустите этот файл от имени Администратора.
echo Скрипт самостоятельно найдет все установленные версии платформы 1С.
echo.
echo [ЧТО ЭТО] Скрипт сканирует папки Program Files и Program Files (x86).
echo В каждой найденной папке 1cv8 он обновляет файл conf\conf.cfg.
echo Параметр DisableUnsafeActionProtection устанавливается в значение .* .
echo Файл сохраняется в кодировке UTF-16 LE (родная для 1С).
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Для ускорения разработки и тестирования.
echo Позволяет запускать обработки и внешние отчеты без постоянных предупреждений системы безопасности 1С.
echo Значение .* означает разрешение любых действий без подтверждения.
echo.
echo [АЛЬТЕРНАТИВНЫЙ СПОСОБ (РУЧНОЙ)]
echo Если вы не хотите менять настройки платформы глобально, можно отключить защиту точечно:
echo 1. Откройте нужную базу в режиме Конфигуратор.
echo 2. Меню: Администрирование - Пользователи - Открыть.
echo 3. На вкладке "Основные" снимите галочку "Защита от опасных действий".
echo 4. Нажмите ОК. Это действие нужно повторять для каждого пользователя каждой базы отдельно.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Apply: Найдет все папки 1cv8 и пропишет ключ в их conf.cfg.
echo   2. Restore: Полностью удалит строку с этим ключом из всех conf.cfg.
echo.
echo [ВАЖНО] Требуется запуск от имени Администратора для записи в Program Files.
echo [ВАЖНО] Изменения вступят в силу при следующем запуске Конфигуратора.
echo.
echo [АКТИВАЦИЯ] Перезапустите 1С:Предприятие после выполнения.
echo ============================================================
echo.

:: --- ПРОВЕРКА ПРАВ ---
echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ОШИБКА] Запустите от имени Администратора!
    pause
    exit /b 1
)
echo [УСПЕХ] Права подтверждены.

:: --- ПОДГОТОВКА ВРЕМЕННЫХ СКРИПТОВ ---
set "TEMP_PS_ADD=%TEMP%\1c_conf_add.ps1"
set "TEMP_PS_DEL=%TEMP%\1c_conf_del.ps1"

findstr /B "::#ADD#" "%~f0" > "%TEMP_PS_ADD%"
findstr /B "::#DEL#" "%~f0" > "%TEMP_PS_DEL%"

powershell -NoProfile -Command "(Get-Content '%TEMP_PS_ADD%') -replace '^::#ADD# ', '' | Set-Content '%TEMP_PS_ADD%' -Encoding ASCII"
powershell -NoProfile -Command "(Get-Content '%TEMP_PS_DEL%') -replace '^::#DEL# ', '' | Set-Content '%TEMP_PS_DEL%' -Encoding ASCII"

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ПРИМЕНИТЬ НАСТРОЙКИ (Включить для разработчика)
echo [2] ОТКАТ (Удалить настройку)
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
echo [ИНФО] Поиск и обновление всех установок 1С...
echo.

set COUNT=0
for %%P in ("%ProgramFiles%" "%ProgramFiles(x86)%") do (
    set "RAW_PATH=%%~P"
    set "CHECK_DIR=!RAW_PATH!\1cv8"
    
    if exist "!CHECK_DIR!" (
        echo [НАЙДЕНО] Папка: !CHECK_DIR!
        set "CFG_FILE=!CHECK_DIR!\conf\conf.cfg"
        
        if not exist "!CHECK_DIR!\conf" mkdir "!CHECK_DIR!\conf"

        powershell -NoProfile -ExecutionPolicy ByPass -File "%TEMP_PS_ADD%" -FilePath "!CFG_FILE!"
        set /a COUNT+=1
        echo.
    )
)

if %COUNT% gtr 0 (
    echo [УСПЕХ] Обработано папок: %COUNT%
) else (
    echo [ОШИБКА] Папки 1cv8 не найдены ни в Program Files, ни в x86.
)
goto CLEANUP

:RESTORE
echo.
echo [ИНФО] Удаление настроек из всех установок 1С...
echo.

set COUNT=0
for %%P in ("%ProgramFiles%" "%ProgramFiles(x86)%") do (
    set "RAW_PATH=%%~P"
    set "CHECK_DIR=!RAW_PATH!\1cv8"
    
    if exist "!CHECK_DIR!\conf\conf.cfg" (
        echo [НАЙДЕНО] Очистка: !CHECK_DIR!\conf\conf.cfg
        
        powershell -NoProfile -ExecutionPolicy ByPass -File "%TEMP_PS_DEL%" -FilePath "!CHECK_DIR!\conf\conf.cfg"
        set /a COUNT+=1
        echo.
    )
)

if %COUNT% gtr 0 (
    echo [УСПЕХ] Очищено файлов: %COUNT%
) else (
    echo [ИНФО] Файлы conf.cfg с этим параметром не найдены.
)
goto CLEANUP

:CLEANUP
if exist "%TEMP_PS_ADD%" del /f /q "%TEMP_PS_ADD%" >nul 2>&1
if exist "%TEMP_PS_DEL%" del /f /q "%TEMP_PS_DEL%" >nul 2>&1

echo.
echo [ИТОГ] Операция завершена.
pause
exit /b 0

:: ==================================================================================================
:: ВСТРОЕННЫЙ КОД POWERSHELL (Safe Line Processing)
:: ==================================================================================================

::#ADD# param([string]$FilePath)
::#ADD# $newLine = 'DisableUnsafeActionProtection=.*'
::#ADD# if (Test-Path $FilePath) {
::#ADD#     $content = Get-Content $FilePath -Encoding Unicode -ErrorAction SilentlyContinue
::#ADD#     $found = $false
::#ADD#     $newContent = @()
::#ADD#     foreach ($line in $content) {
::#ADD#         if ($line -match '^\s*DisableUnsafeActionProtection\s*=') {
::#ADD#             $newContent += $newLine
::#ADD#             $found = $true
::#ADD#         } else {
::#ADD#             $newContent += $line
::#ADD#         }
::#ADD#     }
::#ADD#     if (-not $found) {
::#ADD#         $newContent += $newLine
::#ADD#     }
::#ADD#     $newContent | Set-Content $FilePath -Encoding Unicode
::#ADD#     Write-Host "[OK] Processed: $FilePath"
::#ADD# } else {
::#ADD#     Set-Content $FilePath -Value $newLine -Encoding Unicode
::#ADD#     Write-Host "[OK] Created: $FilePath"
::#ADD# }

::#DEL# param([string]$FilePath)
::#DEL# if (Test-Path $FilePath) {
::#DEL#     $content = Get-Content $FilePath -Encoding Unicode -ErrorAction SilentlyContinue
::#DEL#     $newContent = @()
::#DEL#     foreach ($line in $content) {
::#DEL#         if ($line -notmatch '^\s*DisableUnsafeActionProtection\s*=') {
::#DEL#             $newContent += $line
::#DEL#         }
::#DEL#     }
::#DEL#     if ($newContent.Count -eq 0) {
::#DEL#         Remove-Item $FilePath -Force
::#DEL#     } else {
::#DEL#         $newContent | Set-Content $FilePath -Encoding Unicode
::#DEL#     }
::#DEL#     Write-Host "[OK] Cleaned: $FilePath"
::#DEL# }