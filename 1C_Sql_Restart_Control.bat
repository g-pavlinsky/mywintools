
@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion
cls

:: ==============================================================================
:: АВТОМАТИЧЕСКИЙ ПОИСК ВСЕХ УСТАНОВЛЕННЫХ ВЕРСИЙ 1С
:: ==============================================================================
set "IDX=0"
for /f "tokens=2 delims==" %%S in ('sc query state^= all ^| findstr /i "srv1cv8.*_rmngr"') do (
    set /a IDX+=1
    set "RMNGR_!IDX!=%%S"
    set "AGENT_NAME=%%S"
    set "AGENT_NAME=!AGENT_NAME:_rmngr=!"
    set "AGENT_!IDX!=!AGENT_NAME!"
)

set "TOTAL_1C=%IDX%"

if "%TOTAL_1C%"=="0" (
    set /a TOTAL_1C=1
    set "AGENT_1=srv1cv83"
    set "RMNGR_1=srv1cv83_rmngr"
)

:: SQL Server
set "SVC_SQL=MSSQLSERVER"
set "SVC_SQL_AGENT=SQLSERVERAGENT"

:: Логи
set "LOG_DIR=C:\Logs"
set "LOG_FILE=%LOG_DIR%\Control_1C_SQL.log"
set "TASK_NAME=AKUMEN_Restart_1C_SQL_Weekly"

:: ==============================================================================
:: ПРОВЕРКА ПРАВ
:: ==============================================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ОШИБКА] Запустите от имени Администратора!
    pause
    exit /b 1
)
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

:: ==============================================================================
:: МЕНЮ И ОПИСАНИЕ
:: ==============================================================================
cls
echo.
echo ============================================================
echo    AKUMEN Consulting - 1C and SQL Service Control Manager
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ]
echo Универсальный инструмент для управления службами 1С Предприятия
echo и MS SQL Server. Обеспечивает безопасную последовательность
echo операций для предотвращения блокировок и повреждений баз данных. Рекомендуется через консоль администрирования кластера 1С завершить принудительно все сеансы, прежде чем отключать службы. Этот скрипт сам пока не умеет.
echo.
echo [ФУНКЦИИ]
echo 1. Автопоиск всех установленных версий 1С (8.3, 8.5 и др.).
echo 2. Умный запуск: пропускает службы со статусом "Отключена" (Disabled).
echo 3. Корректная очередь: SQL -- 1C Agent -- 1C Server (и наоборот).
echo 4. Ведение журнала операций в файле C:\Logs\Control_1C_SQL.log.
echo.
echo [НАЙДЕННЫЕ КЛАСТЕРЫ 1С]
for /L %%i in (1,1,%TOTAL_1C%) do (
    echo   -- Версия %%i: Агент=!AGENT_%%i!, Сервер=!RMNGR_%%i!
)
echo.
echo [МЕНЮ ДЕЙСТВИЙ]
echo [1] ПОЛНАЯ ПЕРЕЗАГРУЗКА (Stop then Start)
echo [2] ТОЛЬКО ВЫКЛЮЧИТЬ СЛУЖБЫ (Stop)
echo [3] ТОЛЬКО ВКЛЮЧИТЬ СЛУЖБЫ (Start)
echo [4] УСТАНОВИТЬ АВТОЗАДАЧУ (Каждое ВС в 04:00)
echo [5] УДАЛИТЬ АВТОЗАДАЧУ ИЗ ПЛАНИРОВЩИКА
echo [6] ВЫХОД
echo.
set /p choice="Ваш выбор (1-6): "

if "%choice%"=="1" goto DO_RESTART
if "%choice%"=="2" goto DO_STOP
if "%choice%"=="3" goto DO_START
if "%choice%"=="4" goto INSTALL_TASK
if "%choice%"=="5" goto REMOVE_TASK
if "%choice%"=="6" exit /b 0
echo [ОШИБКА] Неверный выбор.
pause & exit /b 1

:: ==============================================================================
:: УПРАВЛЕНИЕ ЗАДАЧАМИ
:: ==============================================================================
:INSTALL_TASK
echo.
echo [ИНФО] Установка задачи '%TASK_NAME%'...
schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1
schtasks /create /tn "%TASK_NAME%" /tr "\"%~f0\" RUN_SILENT RESTART" /sc WEEKLY /D SUN /ST 04:00 /ru SYSTEM /rl HIGHEST /f
if %errorlevel% equ 0 (echo [УСПЕХ] Задача создана.) else (echo [ОШИБКА] Ошибка создания задачи.)
pause & exit /b 0

:REMOVE_TASK
echo.
echo [ИНФО] Удаление задачи '%TASK_NAME%'...
schtasks /delete /tn "%TASK_NAME%" /f
if %errorlevel% equ 0 (echo [УСПЕХ] Задача удалена.) else (echo [ОШИБКА] Задача не найдена.)
pause & exit /b 0

:: ==============================================================================
:: ОСНОВНАЯ ЛОГИКА
:: ==============================================================================
:DO_RESTART
call :LOG "=== НАЧАЛО ПОЛНОЙ ПЕРЕЗАГРУЗКИ ==="
call :STOP_ALL
call :LOG "Пауза 10 секунд..."
timeout /t 10 /nobreak >nul
call :START_ALL
call :LOG "=== ПРОЦЕДУРА ЗАВЕРШЕНА ==="
goto END_SCRIPT

:DO_STOP
call :LOG "=== НАЧАЛО ОСТАНОВКИ ==="
call :STOP_ALL
call :LOG "=== ОСТАНОВКА ЗАВЕРШЕНА ==="
goto END_SCRIPT

:DO_START
call :LOG "=== НАЧАЛО ЗАПУСКА ==="
call :START_ALL
call :LOG "=== ЗАПУСК ЗАВЕРШЕН ==="
goto END_SCRIPT

:: ==============================================================================
:: ФУНКЦИИ ОСТАНОВКИ И ЗАПУСКА
:: ==============================================================================

:STOP_ALL
:: 1. Остановка всех работающих серверов 1С
for /L %%i in (1,1,%TOTAL_1C%) do (
    call :CHECK_AND_STOP "!RMNGR_%%i!" "Этап 1.%%i"
)
:: 2. Остановка всех работающих агентов 1С
for /L %%i in (1,1,%TOTAL_1C%) do (
    call :CHECK_AND_STOP "!AGENT_%%i!" "Этап 2.%%i"
)
:: 3. SQL
call :CHECK_AND_STOP "%SVC_SQL_AGENT%" "Этап 3"
call :CHECK_AND_STOP "%SVC_SQL%" "Этап 4"
goto :eof

:START_ALL
:: 1. SQL
call :CHECK_AND_START "%SVC_SQL%" "Этап 5"
call :CHECK_AND_START "%SVC_SQL_AGENT%" "Этап 6"

:: 2. Агенты 1С
for /L %%i in (1,1,%TOTAL_1C%) do (
    call :CHECK_AND_START "!AGENT_%%i!" "Этап 7.%%i"
)
:: 3. Серверы 1С
for /L %%i in (1,1,%TOTAL_1C%) do (
    call :CHECK_AND_START "!RMNGR_%%i!" "Этап 8.%%i"
)
goto :eof

:: ==============================================================================
:: ПРОВЕРКА СТАТУСА ПЕРЕД ДЕЙСТВИЕМ
:: ==============================================================================

:CHECK_AND_STOP
set "SVC=%~1"
set "STEP=%~2"
for /f "tokens=4" %%A in ('sc query "%SVC%" ^| findstr "STATE"') do set "CUR_STATE=%%A"
if "%CUR_STATE%"=="RUNNING" (
    call :LOG "%STEP%: Остановка %SVC%..."
    sc stop "%SVC%" >nul 2>&1
    call :WAIT_FOR_STATUS "%SVC%" "STOPPED" 60
) else (
    call :LOG "%STEP%: %SVC% не работает. Пропуск."
)
goto :eof

:CHECK_AND_START
set "SVC=%~1"
set "STEP=%~2"
for /f "tokens=4" %%A in ('sc qc "%SVC%" ^| findstr "START_TYPE"') do set "START_TYPE=%%A"
for /f "tokens=4" %%A in ('sc query "%SVC%" ^| findstr "STATE"') do set "CUR_STATE=%%A"

if "%START_TYPE%"=="DISABLED" (
    call :LOG "%STEP%: %SVC% отключена (Disabled). Пропуск запуска."
    goto :eof
)

if "%CUR_STATE%"=="RUNNING" (
    call :LOG "%STEP%: %SVC% уже работает. Пропуск."
    goto :eof
)

call :LOG "%STEP%: Запуск %SVC%..."
sc start "%SVC%" >nul 2>&1
call :WAIT_FOR_STATUS "%SVC%" "RUNNING" 60
goto :eof

:END_SCRIPT
if "%1" NEQ "RUN_SILENT" pause
exit /b 0

:: ==============================================================================
:: ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
:: ==============================================================================

:LOG
echo [%date% %time%] %~1 >> "%LOG_FILE%"
echo [%date% %time%] %~1
goto :eof

:WAIT_FOR_STATUS
set "SVC_NAME=%~1"
set "TARGET_STATUS=%~2"
set "TIMEOUT=%~3"
set "COUNT=0"

:WAIT_LOOP
for /f "tokens=4" %%A in ('sc query "%SVC_NAME%" ^| findstr "STATE"') do set "CURRENT_STATUS=%%A"
if "%CURRENT_STATUS%"=="%TARGET_STATUS%" goto :eof
timeout /t 1 /nobreak >nul
set /a COUNT=%COUNT%+1
if %COUNT% GEQ %TIMEOUT% (
    call :LOG "[WARN] Таймаут ожидания %TARGET_STATUS% для %SVC_NAME%"
    goto :eof
)
goto :WAIT_LOOP