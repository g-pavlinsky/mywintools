
@echo off
chcp 65001 >nul
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - OneDrive Complete Disable Module
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Полное отключение OneDrive: синхронизация, автозагрузка и интеграция в Проводник.
echo.
echo [ЧТО ЭТО] Скрипт блокирует политику синхронизации, скрывает папку OneDrive из боковой панели
echo Проводника и очищает записи автозагрузки.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Для освобождения ресурсов системы, устранения навязчивой синхронизации
echo и удаления лишнего элемента из интерфейса Проводника.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Apply: БлокируетFileSyncNGSC, скрывает CLSID OneDrive, чистит StartupApproved.
echo   2. Restore: Возвращает стандартные настройки (включает синхронизацию и отображение).
echo.
echo [ВАЖНО] Требуется перезагрузка или перезапуск проводника.
echo [ВАЖНО] Файлы на компьютере останутся, но синхронизация с облаком прекратится.
echo.
echo [АКТИВАЦИЯ] Перезагрузите компьютер. Проверьте отсутствие OneDrive в Проводнике.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ПРИМЕНИТЬ настройки (Disable OneDrive)
echo [2] ОТКАТ / АЛЬТЕРНАТИВА (Enable OneDrive)
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
echo [ИНФО] Начало полного отключения OneDrive...

echo [ИНФО] Блокировка синхронизации через политики...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] Политика DisableFileSyncNGSC установлена.

echo [ИНФО] Скрытие OneDrive из Проводника (x64)...
reg add "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0 /f >nul 2>&1
echo [УСПЕХ] CLSID скрыт.

echo [ИНФО] Скрытие OneDrive из Проводника (x86/WOW64)...
reg add "HKCR\WOW6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 0 /f >nul 2>&1
echo [УСПЕХ] WOW64 CLSID скрыт.

echo [ИНФО] Отключение автозагрузки OneDrive...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "OneDrive" /t REG_BINARY /d 03000000B5E73D230DECD301 /f >nul 2>&1
echo [УСПЕХ] OneDrive удален из автозагрузки.

echo [ИНФО] Отключение автозагрузки OneDriveSetup...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "OneDriveSetup" /t REG_BINARY /d 03000000E7BCAF9F2BECD301 /f >nul 2>&1
echo [УСПЕХ] OneDriveSetup удален из автозагрузки.

echo [ИНФО] Остановка процессов OneDrive...
taskkill /f /im OneDrive.exe >nul 2>&1
echo [УСПЕХ] Процессы остановлены.

goto END

:RESTORE
echo.
echo [ИНФО] Восстановление настроек OneDrive...

echo [ИНФО] Разрешение синхронизации...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /f >nul 2>&1
echo [УСПЕХ] Политика удалена.

echo [ИНФО] Отображение OneDrive в Проводнике (x64)...
reg add "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] CLSID отображается.

echo [ИНФО] Отображение OneDrive в Проводнике (x86/WOW64)...
reg add "HKCR\WOW6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] WOW64 CLSID отображается.

echo [ИНФО] Удаление запретов автозагрузки...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "OneDrive" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "OneDriveSetup" /f >nul 2>&1
echo [УСПЕХ] Автозагрузка восстановлена.

goto END

:END
echo.
echo [ИТОГ] Операция завершена. Перезагрузите компьютер.
pause
exit /b 0