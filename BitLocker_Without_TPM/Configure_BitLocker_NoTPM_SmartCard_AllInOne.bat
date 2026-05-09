@echo off
chcp 65001 >nul

echo.
echo ============================================================
echo    AKUMEN Consulting
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Умное переключение BitLocker на режим No-TPM + SmartCard
echo.
echo [ЧТО ЭТО] Автоматическая расшифровка (если нужно) и включение защиты по Смарт-карте.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Переход на аппаратную аутентификацию (PKI) без TPM.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Проверит статус шифрования.
echo   2. Если зашифровано: расшифрует диск и будет ЖДАТЬ окончания.
echo   3. Применит политики: Запрет PIN/USB, Требование SmartCard.
echo   4. Включит шифрование с запросом смарт-карты.
echo.
echo [ВАЖНО] Требуется валидная смарт-карта с сертификатом.
echo [ВАЖНО] Процесс расшифровки долог. Не выключайте ПК.
echo [ВАЖНО] Без карты система НЕ ЗАГРУЗИТСЯ.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора. Вставьте карту.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Проверка состояния и Расшифровка ---
echo [ИНФО] Проверка статуса BitLocker...
manage-bde -status C: | findstr /C:"Fully Encrypted" >nul
if %errorlevel% equ 0 (
    echo [ИНФО] Диск зашифрован. Запуск расшифровки для смены метода...
    manage-bde -off C:
    
    echo [ИНФО] Ожидание полной расшифровки...
    :WAIT_LOOP_SC
    timeout /t 10 /nobreak >nul
    manage-bde -status C: | findstr /C:"Fully Decrypted" >nul
    if %errorlevel% equ 0 goto DECRYPTION_DONE_SC
    
    manage-bde -status C: | findstr /C:"Percentage Encrypted:  0.0%" >nul
    if %errorlevel% equ 0 goto DECRYPTION_DONE_SC
    
    for /f "tokens=*" %%a in ('manage-bde -status C: ^| findstr /C:"Percentage Encrypted"') do echo [ПРОГРЕСС] %%a
    goto WAIT_LOOP_SC
)

:DECRYPTION_DONE_SC
echo [УСПЕХ] Диск готов к новой конфигурации.

:: --- ШАГ 2: Применение политик (SmartCard Only) ---
echo [ИНФО] Настройка реестра (No TPM + SmartCard Only)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\BitLocker" /v "AllowBitLockerWithoutTPM" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\BitLocker" /v "AllowBitLockerWithoutSecureBoot" /t REG_DWORD /d 1 /f >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseAdvancedStartup" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "EnableBDEWithNoTPM" /t REG_DWORD /d 1 /f >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPM" /t REG_DWORD /d 2 /f >nul 2>&1       :: No TPM
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPMPIN" /t REG_DWORD /d 3 /f >nul 2>&1     :: No PIN
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPMKey" /t REG_DWORD /d 3 /f >nul 2>&1     :: No USB
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPMKeyPIN" /t REG_DWORD /d 3 /f >nul 2>&1  :: No USB+PIN
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseSmartCard" /t REG_DWORD /d 2 /f >nul 2>&1  :: Require SmartCard

echo [УСПЕХ] Политики применены.

:: --- ШАГ 3: Включение шифрования ---
echo [ИНФО] Инициация шифрования со Смарт-картой...
manage-bde -on C: -tpmnone -sc

if %errorlevel% equ 0 (
    echo [УСПЕХ] Шифрование запущено.
) else (
    echo [ОШИБКА] Ошибка. Проверьте драйверы карты и сертификат.
)

echo.
echo [ИТОГ] Перезагрузите систему. Не извлекайте карту.
pause