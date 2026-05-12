@echo off
chcp 65001 >nul 2>&1
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - Office Connectivity Control
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
echo   3. Обеспечит полный сброс настроек.
echo.
echo [ВАЖНО] Требуется выбор действия в меню ниже.
echo [ВАЖНО] Изменения вступают в силу после перезапуска приложений Office.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || echo [ВНИМАНИЕ] Запущено без прав администратора (достаточно для HKCU).

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ЗАБЛОКИРОВАТЬ онлайн-контент (Режим офлайн/Безопасность)
echo [2] РАЗРЕШИТЬ онлайн-контент (Полный доступ)
echo [3] СБРОСИТЬ настройки (По умолчанию / Удалить политику)
echo [4] ВЫХОД
echo.
set /p choice="Введите номер (1-4) и нажмите Enter: "

if "%choice%"=="1" goto BLOCK
if "%choice%"=="2" goto ALLOW
if "%choice%"=="3" goto RESET
if "%choice%"=="4" exit /b 0
echo [ОШИБКА] Неверный выбор.
pause & exit /b 1

:BLOCK
echo.
echo [ИНФО] Закрытие приложений Office...
taskkill /F /IM WINWORD.EXE >nul 2>&1
taskkill /F /IM EXCEL.EXE >nul 2>&1
taskkill /F /IM POWERPNT.EXE >nul 2>&1
taskkill /F /IM OUTLOOK.EXE >nul 2>&1
taskkill /F /IM MSACCESS.EXE >nul 2>&1
echo [УСПЕХ] Процессы завершены.

echo [ИНФО] Блокировка онлайн-контента (Useonlinecontent=0)...
reg add "HKCU\Software\Policies\Microsoft\Office\16.0\Common\Internet" /v "Useonlinecontent" /t REG_DWORD /d 0 /f >nul 2>&1
echo [УСПЕХ] Онлайн-контент заблокирован.
goto END

:ALLOW
echo.
echo [ИНФО] Закрытие приложений Office...
taskkill /F /IM WINWORD.EXE >nul 2>&1
taskkill /F /IM EXCEL.EXE >nul 2>&1
taskkill /F /IM POWERPNT.EXE >nul 2>&1
taskkill /F /IM OUTLOOK.EXE >nul 2>&1
taskkill /F /IM MSACCESS.EXE >nul 2>&1
echo [УСПЕХ] Процессы завершены.

echo [ИНФО] Разрешение онлайн-контента (Useonlinecontent=1)...
reg add "HKCU\Software\Policies\Microsoft\Office\16.0\Common\Internet" /v "Useonlinecontent" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] Онлайн-контент разрешен.
goto END

:RESET
echo.
echo [ИНФО] Закрытие приложений Office...
taskkill /F /IM WINWORD.EXE >nul 2>&1
taskkill /F /IM EXCEL.EXE >nul 2>&1
taskkill /F /IM POWERPNT.EXE >nul 2>&1
taskkill /F /IM OUTLOOK.EXE >nul 2>&1
taskkill /F /IM MSACCESS.EXE >nul 2>&1
echo [УСПЕХ] Процессы завершены.

echo [ИНФО] Сброс политики (Удаление ключа Useonlinecontent)...
reg delete "HKCU\Software\Policies\Microsoft\Office\16.0\Common\Internet" /v "Useonlinecontent" /f >nul 2>&1
echo [УСПЕХ] Настройки сброшены до заводских.
goto END

:END
echo.
echo [ИТОГ] Операция завершена. Перезапустите приложения Office.
pause
exit /b 0