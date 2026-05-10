
@echo off
chcp 65001 >nul
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - Credential Guard Control
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Отключение Credential Guard для исправления проблем с RDP
echo.
echo [ЧТО ЭТО] Скрипт отключает изоляцию учетных данных (VBS/LsaIso), которая блокирует передачу кэшированных паролей по NTLM.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Устранение ошибки "Ваши учетные данные не сработали" при подключении через RDP.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Отключит службу LsaIso (Isolated User Mode).
echo   2. Сбросит флаги конфигурации LSA (LsaCfgFlags) в 0.
echo   3. Применит политику отключения Device Guard для LSA.
echo   4. Позволит вернуть настройки безопасности (Откат).
echo.
echo [ВАЖНО] СНИЖАЕТ ЗАЩИТУ ОТ АТАК PASS-THE-HASH!
echo [ВАЖНО] Не рекомендуется для рабочих станций в открытых сетях.
echo [ВАЖНО] Требуется ОБЯЗАТЕЛЬНАЯ перезагрузка.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора. Перезагрузите ПК после выполнения.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ОТКЛЮЧИТЬ Credential Guard (Apply for RDP)
echo [2] ВКЛЮЧИТЬ Credential Guard (Restore Security)
echo [3] ВЫХОД
echo.
set /p choice="Введите номер (1-3) и нажмите Enter: "

if "%choice%"=="1" goto APPLY
if "%choice%"=="2" goto RESTORE
if "%choice%"=="3" exit /b 0
echo [ОШИБКА] Неверный выбор.
pause & exit /b 1

:APPLY
echo.
echo [ИНФО] Остановка и отключение службы LsaIso...
net stop LsaIso /y >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LsaIso" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
echo [УСПЕХ] Служба LsaIso отключена.

echo [ИНФО] Отключение Credential Guard в реестре (LsaCfgFlags=0)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "LsaCfgFlags" /t REG_DWORD /d 0 /f >nul 2>&1
echo [УСПЕХ] Настройки LSA обновлены.

echo [ИНФО] Применение политики отключения через Device Guard...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "LsaCfgFlags" /t REG_DWORD /d 0 /f >nul 2>&1
echo [УСПЕХ] Политики применены.

goto END

:RESTORE
echo.
echo [ИНФО] Включение службы LsaIso (Manual/Boot)...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LsaIso" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
echo [УСПЕХ] Служба LsaIso восстановлена.

echo [ИНФО] Включение Credential Guard (LsaCfgFlags=1)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "LsaCfgFlags" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] Настройки LSA восстановлены.

echo [ИНФО] Сброс политики Device Guard...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "LsaCfgFlags" /f >nul 2>&1
echo [УСПЕХ] Политики безопасности восстановлены.

goto END

:END
echo.
echo [ИТОГ] Операция завершена. ПЕРЕЗАГРУЗИТЕ систему для вступления в силу.
pause
exit /b 0