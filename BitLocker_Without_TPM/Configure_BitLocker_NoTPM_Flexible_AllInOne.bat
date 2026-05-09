@echo off
chcp 65001 >nul

echo.
echo ============================================================
echo    AKUMEN Consulting
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Умное переключение BitLocker на гибкий режим (PIN или SmartCard)
echo.
echo [ЧТО ЭТО] Разрешает выбор между PIN и Смарт-картой при инициации.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Расшифрует диск (если нужно) с ожиданием.
echo   2. Разрешит использование и PIN, и SmartCard.
echo   3. Запретит USB-ключи.
echo   4. Запустит мастер выбора метода.
echo.
echo [ВАЖНО] При включении вам нужно будет выбрать ОДИН метод.
echo [ВАЖНО] Долгий процесс расшифровки возможен.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Проверка состояния и Расшифровка ---
echo [ИНФО] Проверка статуса BitLocker...
manage-bde -status C: | findstr /C:"Fully Encrypted" >nul
if %errorlevel% equ 0 (
    echo [ИНФО] Диск зашифрован. Запуск расшифровки...
    manage-bde -off C:
    
    echo [ИНФО] Ожидание полной расшифровки...
    :WAIT_LOOP_FL
    timeout /t 10 /nobreak >nul
    manage-bde -status C: | findstr /C:"Fully Decrypted" >nul
    if %errorlevel% equ 0 goto DECRYPTION_DONE_FL
    
    manage-bde -status C: | findstr /C:"Percentage Encrypted:  0.0%" >nul
    if %errorlevel% equ 0 goto DECRYPTION_DONE_FL
    
    for /f "tokens=*" %%a in ('manage-bde -status C: ^| findstr /C:"Percentage Encrypted"') do echo [ПРОГРЕСС] %%a
    goto WAIT_LOOP_FL
)

:DECRYPTION_DONE_FL
echo [УСПЕХ] Диск готов.

:: --- ШАГ 2: Применение политик (Flexible) ---
echo [ИНФО] Настройка реестра (Разрешить PIN и SmartCard)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\BitLocker" /v "AllowBitLockerWithoutTPM" /t REG_DWORD /d 1 /f >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseAdvancedStartup" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "EnableBDEWithNoTPM" /t REG_DWORD /d 1 /f >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPM" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPMPIN" /t REG_DWORD /d 1 /f >nul 2>&1     :: Allow PIN
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseSmartCard" /t REG_DWORD /d 1 /f >nul 2>&1   :: Allow SmartCard
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPMKey" /t REG_DWORD /d 3 /f >nul 2>&1      :: No USB
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPMKeyPIN" /t REG_DWORD /d 3 /f >nul 2>&1   :: No USB+PIN

echo [УСПЕХ] Политики применены.

:: --- ШАГ 3: Включение шифрования ---
echo [ИНФО] Запуск мастера BitLocker...
echo [ИНФО] Выберите предпочтительный метод (PIN или SmartCard) в окне мастера.
manage-bde -on C: -tpmnone

if %errorlevel% equ 0 (
    echo [УСПЕХ] Процесс инициирован.
) else (
    echo [ОШИБКА] Ошибка запуска.
)

echo.
echo [ИТОГ] Перезагрузите систему.
pause