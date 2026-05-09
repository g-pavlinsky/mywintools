@echo off
chcp 65001 >nul

echo.
echo ============================================================
echo    AKUMEN Consulting
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Умное переключение BitLocker на режим No-TPM + PIN
echo.
echo [ЧТО ЭТО] Скрипт автоматически расшифровывает диск (если нужно), применяет политики и включает шифрование с PIN.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Безопасная смена метода аутентификации без ручного ожидания расшифровки.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Проверит текущий статус шифрования.
echo   2. Если зашифровано: запустит расшифровку и будет ЖДАТЬ её окончания.
echo   3. Применит политики реестра для режима No-TPM + PIN.
echo   4. Включит шифрование с запросом нового PIN.
echo.
echo [ВАЖНО] Процесс расшифровки может занять от 20 минут до нескольких часов.
echo [ВАЖНО] Не выключайте питание компьютера во время выполнения скрипта.
echo [ВАЖНО] ЗАПОМНИТЕ новый PIN-код.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора. Подключите ПК к сети (для ноутбуков).
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Проверка состояния и Расшифровка (если требуется) ---
echo [ИНФО] Проверка статуса BitLocker...
for /f "tokens=*" %%a in ('manage-bde -status C: ^| findstr /C:"Conversion Status"') do set "STATUS=%%a"
for /f "tokens=*" %%a in ('manage-bde -status C: ^| findstr /C:"Percentage Encrypted"') do set "PERCENT=%%a"

echo [СТАТУС] %STATUS%
echo [СТАТУС] %PERCENT%

:: Проверка, нужно ли расшифровывать (если Protection On или Percentage > 0%)
echo %STATUS% | findstr /C:"Fully Encrypted" >nul
if %errorlevel% equ 0 (
    echo [ИНФО] Диск полностью зашифрован. Требуется расшифровка для смены метода.
    echo [ИНФО] Запуск процесса расшифровки...
    manage-bde -off C:
    
    echo [ИНФО] Ожидание полной расшифровки (это может занять много времени)...
    :WAIT_LOOP
    timeout /t 10 /nobreak >nul
    for /f "tokens=*" %%a in ('manage-bde -status C: ^| findstr /C:"Percentage Encrypted"') do set "CURRENT_PERCENT=%%a"
    echo [ПРОГРЕСС] %CURRENT_PERCENT%
    
    :: Проверка на 0.0% или Fully Decrypted
    manage-bde -status C: | findstr /C:"Fully Decrypted" >nul
    if %errorlevel% equ 0 goto DECRYPTION_DONE
    
    manage-bde -status C: | findstr /C:"Percentage Encrypted:  0.0%" >nul
    if %errorlevel% equ 0 goto DECRYPTION_DONE
    
    goto WAIT_LOOP
)

:DECRYPTION_DONE
echo [УСПЕХ] Диск расшифрован или был незашифрован.

:: --- ШАГ 2: Применение политик реестра ---
echo [ИНФО] Блокировка старых методов и включение No-TPM + PIN...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\BitLocker" /v "AllowBitLockerWithoutTPM" /t REG_DWORD /d 1 /f >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseAdvancedStartup" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "EnableBDEWithNoTPM" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "EnableNonTPM" /t REG_DWORD /d 1 /f >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPM" /t REG_DWORD /d 2 /f >nul 2>&1       :: No TPM
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPMPIN" /t REG_DWORD /d 2 /f >nul 2>&1     :: Require PIN
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPMKey" /t REG_DWORD /d 3 /f >nul 2>&1     :: No USB
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPMKeyPIN" /t REG_DWORD /d 3 /f >nul 2>&1  :: No USB+PIN
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseSmartCard" /t REG_DWORD /d 3 /f >nul 2>&1  :: No SmartCard

echo [УСПЕХ] Политики применены.

:: --- ШАГ 3: Включение шифрования с новым методом ---
echo [ИНФО] Инициация шифрования с PIN...
echo [ИНФО] Введите новый PIN-код в появившемся окне.
manage-bde -on C: -tpmnone -pin

if %errorlevel% equ 0 (
    echo [УСПЕХ] Шифрование запущено.
) else (
    echo [ОШИБКА] Не удалось запустить шифрование. Проверьте логи.
)

echo.
echo [ИТОГ] Перезагрузите систему для активации защиты.
pause