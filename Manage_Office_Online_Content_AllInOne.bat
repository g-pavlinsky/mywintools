@echo off
chcp 65001 >nul

echo.
echo ============================================================
echo    AKUMEN Consulting
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Управление доступом Office к онлайн-контенту (Шаблоны, Картинки)
echo.
echo [ЧТО ЭТО] Скрипт применяет политики Useonlinecontent для Office 2016/2019/2021/365.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] 
echo   - Блокировка: Для закрытых сетей, безопасности и ускорения работы.
echo   - Разрешение: Если функции "Картинки из сети" или шаблоны не работают.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Закроет активные приложения Office.
echo   2. Применит выбранную политику в реестр.
echo.
echo [ВАЖНО] Требуется выбор действия в меню ниже.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора (рекомендуется, но не обязательно для HKCU)...
net session >nul 2>&1
if %errorlevel% neq 0 echo [ВНИМАНИЕ] Запущено без прав администратора.

:: --- МЕНЮ ВЫБОРА ---
echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ЗАБЛОКИРОВАТЬ онлайн-контент (Режим офлайн/Безопасность)
echo [2] РАЗРЕШИТЬ онлайн-контент (Полный доступ)
echo [3] СБРОСИТЬ настройки (По умолчанию / Удалить политику)
echo.
set /p choice="Введите номер (1-3) и нажмите Enter: "

if "%choice%"=="1" goto BLOCK
if "%choice%"=="2" goto ALLOW
if "%choice%"=="3" goto RESET
echo [ОШИБКА] Неверный выбор.
pause & exit /b 1

:: --- ШАГ 0: Закрытие Office ---
:CLOSE_OFFICE
echo.
echo [ИНФО] Закрытие приложений Office для применения настроек...
taskkill /F /IM WINWORD.EXE >nul 2>&1
taskkill /F /IM EXCEL.EXE >nul 2>&1
taskkill /F /IM POWERPNT.EXE >nul 2>&1
taskkill /F /IM OUTLOOK.EXE >nul 2>&1
taskkill /F /IM MSACCESS.EXE >nul 2>&1
echo [УСПЕХ] Процессы завершены.
goto APPLY_%CHOICE%

:: --- ВАРИАНТ 1: БЛОКИРОВКА ---
:BLOCK
set "VAL=0"
set "DESC=Заблокировано"
goto APPLY_REG

:: --- ВАРИАНТ 2: РАЗРЕШЕНИЕ ---
:ALLOW
set "VAL=1"
set "DESC=Разрешено"
goto APPLY_REG

:: --- ВАРИАНТ 3: СБРОС ---
:RESET
set "VAL=-"
set "DESC=Сброшено (По умолчанию)"
goto APPLY_REG

:: --- ПРИМЕНЕНИЕ РЕЕСТРА ---
:APPLY_REG
echo [ИНФО] Применение настройки: %DESC%...

:: Проверка наличия ветки Office 16.0
reg query "HKCU\Software\Policies\Microsoft\Office\16.0\Common\Internet" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ИНФО] Ветка политик не найдена. Создаем...
    reg add "HKCU\Software\Policies\Microsoft\Office\16.0\Common\Internet" /f >nul 2>&1
)

if "%VAL%"=="-" (
    reg delete "HKCU\Software\Policies\Microsoft\Office\16.0\Common\Internet" /v "Useonlinecontent" /f >nul 2>&1
) else (
    reg add "HKCU\Software\Policies\Microsoft\Office\16.0\Common\Internet" /v "Useonlinecontent" /t REG_DWORD /d %VAL% /f >nul 2>&1
)

if %errorlevel% equ 0 (
    echo [УСПЕХ] Настройка успешно применена.
) else (
    echo [ОШИБКА] Не удалось изменить реестр.
)

echo.
echo [ИТОГ] Office настроен (%DESC%). Запустите приложения.
pause