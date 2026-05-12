
@echo off
chcp 65001 >nul 2>&1
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - Inactivity Timeout Module
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Управление временем бездействия перед автоматической блокировкой экрана.
echo.
echo [ЧТО ЭТО] Скрипт устанавливает параметр InactivityTimeoutSecs в реестре.
echo Значение задается в секундах.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Для обеспечения безопасности: автоматическая блокировка ПК, если вы отошли.
echo Или для отключения этой функции, если она мешает.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Apply: Предлагает выбрать время (1 мин, 3 мин, 5 мин, 10 мин) или отключить.
echo   2. Restore: Удаляет параметр (система использует настройки электропитания по умолчанию).
echo.
echo [ВАЖНО] Изменение вступает в силу немедленно или после перезагрузки.
echo [ВАЖНО] Эта настройка работает в дополнение к планам электропитания.
echo.
echo [АКТИВАЦИЯ] Отойдите от компьютера на выбранное время для проверки.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] Установить таймаут 1 минута (90 сек)
echo [2] Установить таймаут 3 минуты (180 сек)
echo [3] Установить таймаут 5 минут (300 сек)
echo [4] Установить таймаут 10 минут (600 сек)
echo [5] ОТКЛЮЧИТЬ таймаут (Удалить параметр)
echo [6] ВЫХОД
echo.
set /p choice="Введите номер (1-6) и нажмите Enter: "

if "%choice%"=="1" goto SET_1MIN
if "%choice%"=="2" goto SET_3MIN
if "%choice%"=="3" goto SET_5MIN
if "%choice%"=="4" goto SET_10MIN
if "%choice%"=="5" goto RESTORE
if "%choice%"=="6" exit /b 0
echo [ОШИБКА] Неверный выбор.
pause & exit /b 1

:SET_1MIN
echo.
echo [ИНФО] Установка таймаута 1 минута...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "InactivityTimeoutSecs" /t REG_DWORD /d 90 /f >nul 2>&1
echo [УСПЕХ] Таймаут установлен на 90 секунд.
goto END

:SET_3MIN
echo.
echo [ИНФО] Установка таймаута 3 минуты...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "InactivityTimeoutSecs" /t REG_DWORD /d 180 /f >nul 2>&1
echo [УСПЕХ] Таймаут установлен на 180 секунд.
goto END

:SET_5MIN
echo.
echo [ИНФО] Установка таймаута 5 минут...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "InactivityTimeoutSecs" /t REG_DWORD /d 300 /f >nul 2>&1
echo [УСПЕХ] Таймаут установлен на 300 секунд.
goto END

:SET_10MIN
echo.
echo [ИНФО] Установка таймаута 10 минут...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "InactivityTimeoutSecs" /t REG_DWORD /d 600 /f >nul 2>&1
echo [УСПЕХ] Таймаут установлен на 600 секунд.
goto END

:RESTORE
echo.
echo [ИНФО] Отключение специального таймаута бездействия...
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "InactivityTimeoutSecs" /f >nul 2>&1
echo [УСПЕХ] Параметр удален. Используются стандартные настройки питания.
goto END

:END
echo.
echo [ИТОГ] Операция завершена.
pause
exit /b 0