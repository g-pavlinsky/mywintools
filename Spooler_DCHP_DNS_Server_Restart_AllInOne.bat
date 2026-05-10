
@echo off
chcp 65001 >nul
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - Service and Scheduler Control Module
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Управление перезапуском критических системных служб и настройка их автоматического обслуживания.
echo.
echo [ЧТО ЭТО] Скрипт предоставляет раздельный контроль над службами Spooler (печать), Dhcp (сеть) и Dnscache (DNS).
echo Позволяет выполнить немедленный перезапуск для сброса ошибок или настроить автоматическое обслуживание через Планировщик заданий.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Службы Windows имеют свойство накапливать ошибки, зависать или потреблять много памяти при длительной работе.
echo Регулярный перезапуск предотвращает проблемы с печатью документов и подключением к сети.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. ВЫПОЛНИТЬ СЕЙЧАС: Немедленно остановит и запустит службы Spooler, Dhcp, Dnscache.
echo   2. НАСТРОИТЬ ШЕДУЛЕР: Создаст две задачи в Планировщике Windows для автоперезапуска в 07:50 и 12:50.
echo   3. ОТКАТ: Полностью удалит созданные задачи из Планировщика, отменив автоматизацию.
echo.
echo [ВАЖНО] Требуется запуск от имени Администратора.
echo [ВАЖНО] Во время выполнения пункта 1 сеть и принтер могут быть недоступны 5-10 секунд.
echo.
echo [АКТИВАЦИЯ] После настройки шедулера проверьте наличие задач в Task Scheduler.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ВЫПОЛНИТЬ СЕЙЧАС (Перезапуск служб)
echo [2] НАСТРОИТЬ ШЕДУЛЕР (Автозапуск в 07:50 и 12:50)
echo [3] ОТКАТ (Удалить шедулер)
echo [4] ВЫХОД
echo.
set /p choice="Введите номер (1-4) и нажмите Enter: "

if "%choice%"=="1" goto RUN_NOW
if "%choice%"=="2" goto SET_SCHEDULER
if "%choice%"=="3" goto RESTORE
if "%choice%"=="4" exit /b 0
echo [ОШИБКА] Неверный выбор.
pause & exit /b 1

:RUN_NOW
echo.
echo [ИНФО] Немедленный перезапуск служб...

echo [ИНФО] Перезапуск Spooler (Диспетчер печати)...
net stop "Spooler" >nul 2>&1
timeout /t 2 /nobreak >nul
net start "Spooler" >nul 2>&1
echo [УСПЕХ] Spooler перезапущен.

echo [ИНФО] Перезапуск Dhcp (Клиент DHCP)...
net stop "Dhcp" >nul 2>&1
timeout /t 2 /nobreak >nul
net start "Dhcp" >nul 2>&1
echo [УСПЕХ] Dhcp перезапущен.

echo [ИНФО] Перезапуск Dnscache (DNS-клиент)...
net stop "Dnscache" >nul 2>&1
timeout /t 2 /nobreak >nul
net start "Dnscache" >nul 2>&1
echo [УСПЕХ] Dnscache перезапущен.

goto END

:SET_SCHEDULER
echo.
echo [ИНФО] Настройка автоматического перезапуска...

schtasks /delete /tn "AKUMEN_ServiceRestart_1" /f >nul 2>&1
schtasks /delete /tn "AKUMEN_ServiceRestart_2" /f >nul 2>&1

schtasks /create /tn "AKUMEN_ServiceRestart_1" /tr "powershell.exe -Command \"Restart-Service Spooler; Restart-Service Dhcp; Restart-Service Dnscache\"" /sc daily /st 07:50 /ru "SYSTEM" /rl HIGHEST /f >nul 2>&1
echo [УСПЕХ] Задача на 07:50 создана.

schtasks /create /tn "AKUMEN_ServiceRestart_2" /tr "powershell.exe -Command \"Restart-Service Spooler; Restart-Service Dhcp; Restart-Service Dnscache\"" /sc daily /st 12:50 /ru "SYSTEM" /rl HIGHEST /f >nul 2>&1
echo [УСПЕХ] Задача на 12:50 создана.

goto END

:RESTORE
echo.
echo [ИНФО] Удаление задач из планировщика...

schtasks /delete /tn "AKUMEN_ServiceRestart_1" /f >nul 2>&1
schtasks /delete /tn "AKUMEN_ServiceRestart_2" /f >nul 2>&1

echo [УСПЕХ] Автоматический перезапуск отключен.

goto END

:END
echo.
echo [ИТОГ] Операция завершена.
pause
exit /b 0