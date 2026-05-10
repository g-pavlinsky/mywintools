
@echo off
chcp 65001 >nul
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - Network Reset & Scheduler
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Управление сетевыми адаптерами и автоматизация
echo.
echo [ЧТО ЭТО] Скрипт для ручного сброса сети или настройки авто-перезагрузки по расписанию.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Устранение зависаний сети, проблем с DHCP/DNS и профилактика драйверов.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Мгновенно перезагрузит активные адаптеры.
echo   2. Глубоко сбросит стек TCP/IP (Winsock).
echo   3. Настроит ежедневную перезагрузку сети в 03:00 (Планировщик).
echo.
echo [ВАЖНО] При выполнении сеть отключится на 10-30 секунд.
echo [ВАЖНО] RDP-сессии будут разорваны.
echo.
echo [АКТИВАЦИЯ] Проверьте доступность сети после завершения.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ПЕРЕЗАГРУЗИТЬ адаптеры сейчас (Instant Reset)
echo [2] ГЛУБОКИЙ СБРОС стека TCP/IP (Winsock/DNS Clean)
echo [3] ВКЛЮЧИТЬ авто-перезагрузку в 03:00 (Scheduler ON)
echo [4] ОТКЛЮЧИТЬ авто-перезагрузку (Scheduler OFF)
echo [5] ВЫХОД
echo.
set /p choice="Введите номер (1-5) и нажмите Enter: "

if "%choice%"=="1" goto INSTANT_RESET
if "%choice%"=="2" goto DEEP_CLEAN
if "%choice%"=="3" goto SCHEDULER_ON
if "%choice%"=="4" goto SCHEDULER_OFF
if "%choice%"=="5" exit /b 0
echo [ОШИБКА] Неверный выбор.
pause & exit /b 1

:INSTANT_RESET
echo.
echo [ИНФО] Поиск активных адаптеров...
powershell.exe -Command "Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Select-Object Name"
echo.
echo [ИНФО] Начало перезагрузки адаптеров...
echo [ВНИМАНИЕ] Сеть может временно отключиться.
powershell.exe -Command "& {Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Restart-NetAdapter}"
echo [УСПЕХ] Команда на перезагрузку отправлена.
goto END

:DEEP_CLEAN
echo.
echo [ИНФО] Глубокий сброс сетевого стека...

netsh winsock reset >nul 2>&1
echo [УСПЕХ] Каталог Winsock сброшен.

netsh int ip reset >nul 2>&1
echo [УСПЕХ] Стек IP сброшен.

ipconfig /flushdns >nul 2>&1
echo [УСПЕХ] Кэш DNS очищен.

echo [ВНИМАНИЕ] Для полного применения рекомендуется перезагрузка ПК.
goto END

:SCHEDULER_ON
echo.
echo [ИНФО] Создание задачи в Планировщике (Daily 03:00)...

schtasks /delete /tn "Nightly_Network_Reset" /f >nul 2>&1

schtasks /create /tn "Nightly_Network_Reset" /tr "powershell.exe -ExecutionPolicy Bypass -Command \"Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Restart-NetAdapter\"" /sc daily /st 03:00 /rl highest /f

if %errorlevel% equ 0 (
    echo [УСПЕХ] Задача создана. Сеть будет перезагружаться каждый день в 03:00.
) else (
    echo [ОШИБКА] Не удалось создать задачу.
)
goto END

:SCHEDULER_OFF
echo.
echo [ИНФО] Удаление задачи из Планировщика...

schtasks /delete /tn "Nightly_Network_Reset" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo [УСПЕХ] Задача удалена. Авто-перезагрузка отключена.
) else (
    echo [ВНИМАНИЕ] Задача не найдена или уже удалена.
)
goto END

:END
echo.
echo [ИТОГ] Операция завершена.
pause
exit /b 0