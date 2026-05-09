@echo off
chcp 65001 >nul

echo.
echo ============================================================
echo    AKUMEN Consulting
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

:: --- ШАГ 1: Отключение службы LsaIso ---
echo [ИНФО] Остановка и отключение службы LsaIso...
net stop LsaIso /y >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LsaIso" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
echo [УСПЕХ] Служба LsaIso отключена.

:: --- ШАГ 2: Изменение конфигурации LSA ---
echo [ИНФО] Отключение Credential Guard в реестре (LsaCfgFlags)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "LsaCfgFlags" /t REG_DWORD /d 0 /f >nul 2>&1
echo [УСПЕХ] Настройки LSA обновлены.

:: --- ШАГ 3: Политики Device Guard ---
echo [ИНФО] Применение политики отключения через Device Guard...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "LsaCfgFlags" /t REG_DWORD /d 0 /f >nul 2>&1
echo [УСПЕХ] Политики применены.

echo.
echo [ИТОГ] Решение применено. ПЕРЕЗАГРУЗИТЕ систему для вступления в силу.
pause