@echo off
chcp 65001 >nul

echo.
echo ============================================================
echo    AKUMEN Consulting (FULL RESTORE)
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Полная расшифровка диска и сброс политик BitLocker
echo.
echo [ЧТО ЭТО] Скрипт принудительно расшифровывает диск C: и удаляет все настройки No-TPM.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Полный откат к заводскому состоянию без шифрования.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Запустит расшифровку диска C: (если зашифрован).
echo   2. Будет ожидать 100% расшифровки (это долго!).
echo   3. Удалит все политики FVE (PIN, SmartCard, USB запреты).
echo   4. Сбросит системные разрешения на работу без TPM.
echo.
echo [ВАЖНО] ПРОЦЕСС РАСШИФРОВКИ МОЖЕТ ЗАНЯТЬ ЧАСЫ.
echo [ВАЖНО] Не выключайте питание и не прерывайте работу скрипта.
echo [ВАЖНО] После выполнения диск будет НЕЗАЩИЩЕННЫМ.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора. Подключите ноутбук к сети.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Принудительная расшифровка ---
echo [ИНФО] Проверка статуса шифрования...
manage-bde -status C: | findstr /C:"Fully Decrypted" >nul
if %errorlevel% equ 0 (
    echo [ИНФО] Диск уже расшифрован. Переход к очистке реестра.
    goto CLEAN_REGISTRY
)

echo [ВНИМАНИЕ] Диск зашифрован. Запуск процесса полной расшифровки...
manage-bde -off C:
if %errorlevel% neq 0 (
    echo [ОШИБКА] Не удалось запустить расшифровку. Возможно, диск поврежден или занят.
    pause & exit /b 1
)

echo [ИНФО] Ожидание полного завершения расшифровки...
echo [ИНФО] Это может занять много времени. Прогресс обновляется каждые 10 секунд.
:WAIT_DECRYPT
timeout /t 10 /nobreak >nul

:: Получаем текущий статус
for /f "tokens=*" %%a in ('manage-bde -status C: ^| findstr /C:"Percentage Encrypted"') do set "PERCENT_LINE=%%a"
echo [ПРОГРЕСС] %PERCENT_LINE%

:: Проверяем условие выхода
manage-bde -status C: | findstr /C:"Fully Decrypted" >nul
if %errorlevel% equ 0 goto DECRYPT_FINISHED

manage-bde -status C: | findstr /C:"Percentage Encrypted:  0.0%" >nul
if %errorlevel% equ 0 goto DECRYPT_FINISHED

goto WAIT_DECRYPT

:DECRYPT_FINISHED
echo [УСПЕХ] Диск полностью расшифрован.

:: --- ШАГ 2: Очистка реестра (Полный сброс) ---
:CLEAN_REGISTRY
echo [ИНФО] Сброс политик BitLocker (FVE)...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseAdvancedStartup" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "EnableBDEWithNoTPM" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "EnableNonTPM" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPM" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPMPIN" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPMKey" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPMKeyPIN" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseSmartCard" /f >nul 2>&1
echo [УСПЕХ] Политики FVE удалены.

echo [ИНФО] Сброс системных флагов BitLocker...
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\BitLocker" /v "AllowBitLockerWithoutTPM" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\BitLocker" /v "AllowBitLockerWithoutSecureBoot" /f >nul 2>&1
echo [УСПЕХ] Системные флаги сброшены.

echo.
echo [ИТОГ] Система возвращена в исходное состояние. Шифрование отключено.
pause