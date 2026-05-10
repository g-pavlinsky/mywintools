
@echo off
chcp 65001 >nul
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - RDP Credentials & Cache Wiper
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Полная очистка сохраненных паролей и кэша RDP-подключений
echo.
echo [ЧТО ЭТО] Скрипт удаляет все сохраненные учетные данные (cmdkey) и очищает кэш MSTSC.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Устранение ошибок аутентификации "Неверный пароль" при смене credentials на сервере или сбоях кэша Windows.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Выведет список всех сохраненных целей.
echo   2. Последовательно удалит все найденные сохраненные пароли.
echo   3. Очистит историю подключений Remote Desktop Client.
echo.
echo [ВАЖНО] Вам придется ВВЕСТИ ПАРОЛИ ЗАНОВО при следующем подключении ко всем серверам.
echo [ВАЖНО] Это действие необратимо для текущего пользователя.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора (рекомендуется) или от пользователя.
echo ============================================================
echo.

echo [ИНФО] Проверка прав...
net session >nul 2>&1 || echo [ВНИМАНИЕ] Запущено без прав администратора. Некоторые кэши могут остаться.

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ОЧИСТИТЬ кэш RDP и пароли (Apply)
echo [2] УДАЛИТЬ ТОЛЬКО имена серверов из истории (Clean History)
echo [3] ВЫХОД
echo.
set /p choice="Введите номер (1-3) и нажмите Enter: "

if "%choice%"=="1" goto APPLY
if "%choice%"=="2" goto CLEAN_HISTORY
if "%choice%"=="3" exit /b 0
echo [ОШИБКА] Неверный выбор.
pause & exit /b 1

:APPLY
echo.
echo [ИНФО] Начало полной очистки...

echo [ИНФО] Удаление сохраненных паролей (CmdKey)...
echo [ИНФО] Найденные цели будут удалены:
cmdkey /list | findstr Target
echo.

for /F "tokens=1,2 delims= " %%G in ('cmdkey /list ^| findstr Target') do (
    echo [УДАЛЕНИЕ] %%H
    cmdkey /delete:%%H >nul 2>&1
)
echo [УСПЕХ] Сохраненные учетные данные удалены.

echo [ИНФО] Очистка истории подключений Remote Desktop...
reg delete "HKCU\Software\Microsoft\Terminal Server Client\Default" /va /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Terminal Server Client\Servers" /f >nul 2>&1
mkdir "%userprofile%\Documents\Default.rdp" >nul 2>&1
attrib +h "%userprofile%\Documents\Default.rdp" >nul 2>&1
echo [УСПЕХ] История MSTSC и пароли очищены.

goto END

:CLEAN_HISTORY
echo.
echo [ИНФО] Удаление только имен серверов из истории...

reg delete "HKCU\Software\Microsoft\Terminal Server Client\Default" /va /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Terminal Server Client\Servers" /f >nul 2>&1
echo [УСПЕХ] Список серверов в клиенте RDP очищен. Пароли сохранены.

goto END

:END
echo.
echo [ИТОГ] Операция завершена.
pause
exit /b 0