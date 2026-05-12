
@echo off
chcp 65001 >nul 2>&1
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - Password Expiry Notification Module
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Отключение всплывающих уведомлений об истечении срока действия пароля.
echo.
echo [ЧТО ЭТО] Скрипт устанавливает параметр PasswordExpiryDays в значение FFFFFFFF (4294967295).
echo Это отключает предварительное уведомление пользователя о необходимости смены пароля.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Для устранения назойливых сообщений в системах с локальными учетными записями
echo или там, где политика смены паролей управляется вручную.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Apply: Устанавливает PasswordExpiryDays равным FFFFFFFF (отключено).
echo   2. Restore: Удаляет параметр (возврат к стандартному поведению системы).
echo.
echo [ВАЖНО] Не отменяет саму политику истечения пароля, только убирает предупреждения.
echo [ВАЖНО] Применимо только к локальным учетным записям.
echo.
echo [АКТИВАЦИЯ] Перезагрузите компьютер или выйдите из системы.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ПРИМЕНИТЬ настройки (Disable Notifications)
echo [2] ОТКАТ / АЛЬТЕРНАТИВА (Restore Defaults)
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
echo [ИНФО] Отключение уведомлений об истечении пароля...

echo [ИНФО] Изменение параметра PasswordExpiryDays...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "PasswordExpiryDays" /t REG_DWORD /d 4294967295 /f >nul 2>&1
echo [УСПЕХ] Параметр установлен в FFFFFFFF.

goto END

:RESTORE
echo.
echo [ИНФО] Возврат стандартных настроек...

echo [ИНФО] Удаление параметра PasswordExpiryDays...
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "PasswordExpiryDays" /f >nul 2>&1
echo [УСПЕХ] Параметр удален. Система использует значения по умолчанию.

goto END

:END
echo.
echo [ИТОГ] Операция завершена. Перезагрузите компьютер.
pause
exit /b 0