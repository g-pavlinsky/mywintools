
@echo off
chcp 65001 >nul 2>&1
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - BitLocker Manager
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Полный контроль над шифрованием BitLocker (No-TPM, PIN, SmartCard)
echo.
echo [ЧТО ЭТО] Универсальный скрипт для смены методов аутентификации и полного сброса.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Позволяет использовать BitLocker на старых ПК без TPM или сменить метод входа.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Расшифрует диск (если требуется) с ожиданием завершения.
echo   2. Применит выбранные политики реестра (PIN / SmartCard / Сброс).
echo   3. Инициирует повторное шифрование с новым методом.
echo.
echo [ВАЖНО] Процесс расшифровки может занять ЧАСЫ. Не выключайте ПК.
echo [ВАЖНО] При потере PIN/Карты данные будут утрачены без ключа восстановления.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора. Ноутбук к сети.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

echo.
echo ВЫБЕРИТЕ РЕЖИМ РАБОТЫ:
echo [1] ВКЛЮЧИТЬ No-TPM + PIN (Классический пароль)
echo [2] ВКЛЮЧИТЬ No-TPM + SmartCard (Аппаратный ключ)
echo [3] ГИБКИЙ РЕЖИМ (Выбор PIN или SmartCard в мастере)
echo [4] ПОЛНЫЙ СБРОС (Расшифровка и удаление политик)
echo [5] ВЫХОД
echo.
set /p choice="Введите номер (1-5) и нажмите Enter: "

if "%choice%"=="1" goto MODE_PIN
if "%choice%"=="2" goto MODE_SC
if "%choice%"=="3" goto MODE_FLEX
if "%choice%"=="4" goto MODE_RESET
if "%choice%"=="5" exit /b 0
echo [ОШИБКА] Неверный выбор.
pause & exit /b 1

:: --- ОБЩИЙ БЛОК РАСШИФРОВКИ ---
:PREPARE_DECRYPT
echo.
echo [ИНФО] Проверка статуса шифрования...
manage-bde -status C: | findstr /C:"Fully Decrypted" >nul
if %errorlevel% equ 0 (
    echo [ИНФО] Диск уже расшифрован.
    goto :EOF
)

echo [ВНИМАНИЕ] Диск зашифрован. Требуется полная расшифровка для смены метода.
echo [ВНИМАНИЕ] Это может занять много времени. Прогресс обновляется каждые 10 сек.
manage-bde -off C:

:WAIT_LOOP
timeout /t 10 /nobreak >nul
for /f "tokens=*" %%a in ('manage-bde -status C: ^| findstr /C:"Percentage Encrypted"') do echo [ПРОГРЕСС] %%a

manage-bde -status C: | findstr /C:"Fully Decrypted" >nul
if %errorlevel% equ 0 goto DECRYPT_DONE
manage-bde -status C: | findstr /C:"Percentage Encrypted:  0.0%" >nul
if %errorlevel% equ 0 goto DECRYPT_DONE
goto WAIT_LOOP

:DECRYPT_DONE
echo [УСПЕХ] Диск полностью расшифрован.
goto :EOF

:: --- РЕЖИМ 1: PIN ---
:MODE_PIN
call :PREPARE_DECRYPT

echo [ИНФО] Применение политик для No-TPM + PIN...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\BitLocker" /v "AllowBitLockerWithoutTPM" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseAdvancedStartup" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "EnableBDEWithNoTPM" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPM" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPMPIN" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPMKey" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseSmartCard" /t REG_DWORD /d 3 /f >nul 2>&1
echo [УСПЕХ] Политики применены.

echo [ИНФО] Запуск шифрования с PIN...
manage-bde -on C: -tpmnone -pin
goto END

:: --- РЕЖИМ 2: SMARTCARD ---
:MODE_SC
call :PREPARE_DECRYPT

echo [ИНФО] Применение политик для No-TPM + SmartCard...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\BitLocker" /v "AllowBitLockerWithoutTPM" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseAdvancedStartup" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "EnableBDEWithNoTPM" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPM" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPMPIN" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseSmartCard" /t REG_DWORD /d 2 /f >nul 2>&1
echo [УСПЕХ] Политики применены.

echo [ИНФО] Запуск шифрования со SmartCard...
manage-bde -on C: -tpmnone -sc
goto END

:: --- РЕЖИМ 3: FLEXIBLE ---
:MODE_FLEX
call :PREPARE_DECRYPT

echo [ИНФО] Применение гибких политик (PIN или SmartCard)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\BitLocker" /v "AllowBitLockerWithoutTPM" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseAdvancedStartup" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "EnableBDEWithNoTPM" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPM" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPMPIN" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseSmartCard" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\FVE" /v "UseTPMKey" /t REG_DWORD /d 3 /f >nul 2>&1
echo [УСПЕХ] Политики применены.

echo [ИНФО] Запуск мастера выбора метода...
manage-bde -on C: -tpmnone
goto END

:: --- РЕЖИМ 4: FULL RESET ---
:MODE_RESET
echo [ИНФО] Запуск полной расшифровки диска...
call :PREPARE_DECRYPT

echo [ИНФО] Удаление всех политик BitLocker...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\FVE" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\BitLocker" /v "AllowBitLockerWithoutTPM" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\BitLocker" /v "AllowBitLockerWithoutSecureBoot" /f >nul 2>&1
echo [УСПЕХ] Реестр очищен.

goto END

:END
echo.
echo [ИТОГ] Операция завершена. Перезагрузите систему.
pause
exit /b 0