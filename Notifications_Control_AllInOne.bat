
@echo off
chcp 65001 >nul 2>&1
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - Notifications Control Module
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Полное отключение Центра уведомлений и всплывающих сообщений (Toast).
echo.
echo [ЧТО ЭТО] Скрипт блокирует работу Центра уведомлений через политики и отключает отображение всплывающих сообщений.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Для устранения отвлекающих факторов, повышения производительности и конфиденциальности.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Apply: Отключает Центр уведомлений (DisableNotificationCenter) и всплывающие сообщения (TOASTS).
echo   2. Restore: Включает Центр уведомлений и возвращает стандартные настройки уведомлений.
echo.
echo [ВАЖНО] Требуется перезагрузка или перезапуск проводника (explorer.exe).
echo [ВАЖНО] Вы перестанете получать системные уведомления и уведомления от приложений.
echo.
echo [АКТИВАЦИЯ] Перезагрузите компьютер или перезапустите Проводник.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ПРИМЕНИТЬ настройки (Disable Notifications)
echo [2] ОТКАТ / АЛЬТЕРНАТИВА (Enable Notifications)
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
echo [ИНФО] Отключение Центра уведомлений...

echo [ИНФО] Блокировка Центра уведомлений через политики...
reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] DisableNotificationCenter установлен в 1.

echo [ИНФО] Отключение всплывающих сообщений (Toast)...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_TOASTS_ENABLED" /t REG_DWORD /d 0 /f >nul 2>&1
echo [УСПЕХ] TOASTS отключены.

echo [ИНФО] Перезапуск Проводника для применения...
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
echo [УСПЕХ] Проводник перезапущен.

goto END

:RESTORE
echo.
echo [ИНФО] Включение Центра уведомлений...

echo [ИНФО] Разблокировка Центра уведомлений...
reg delete "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /f >nul 2>&1
echo [УСПЕХ] Политика DisableNotificationCenter удалена.

echo [ИНФО] Включение всплывающих сообщений (Toast)...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_TOASTS_ENABLED" /f >nul 2>&1
echo [УСПЕХ] Настройки Toast сброшены.

echo [ИНФО] Перезапуск Проводника для применения...
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
echo [УСПЕХ] Проводник перезапущен.

goto END

:END
echo.
echo [ИТОГ] Операция завершена.
pause
exit /b 0