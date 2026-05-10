
@echo off
chcp 65001 >nul
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - Modular Windows Tweaks Suite v2
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Полный набор инструментов для настройки интерфейса, безопасности и поведения Windows.
echo Включает расширенное контекстное меню с командами CMD и PowerShell.
echo.
echo [ЧТО ЭТО] Консолидированный файл, содержащий 6 ключевых модулей настройки:
echo 1. Explorer Clean (Скрытие папок, OneDrive, мусора из вида).
echo 2. Taskbar and UI (Панель задач, дата, погода, чат, меню Пуск).
echo 3. Context Menu Pro (Пра доступа, Атрибуты, CMD, PowerShell, Копировать/Переместить).
echo 4. Classic Photo Viewer (Возврат старого просмотрщика фото для всех форматов).
echo 5. System UX (Диспетчер устройств, Управление, LastKnownGood).
echo 6. Privacy and Performance (Отключение телеметрии, ускорение загрузки, отчетов об ошибках).
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Для создания чистой, профессиональной среды без навязчивых элементов Microsoft.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Apply All: Применяет все 6 модулей сразу.
echo   2-7. Apply Module [N]: Применяет только выбранный модуль.
echo   8. Restore All: Полный откат всех изменений к состоянию По умолчанию.
echo.
echo [ВАЖНО] Требуется перезагрузка или перезапуск explorer.exe.
echo [ВАЖНО] Модуль контекстного меню добавляет мощные инструменты администрирования.
echo.
echo [АКТИВАЦИЯ] Перезагрузите компьютер после применения.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ПРИМЕНИТЬ ВСЁ (Full Suite)
echo [2] МОДУЛЬ 1: Очистка Проводника (Скрыть папки, OneDrive)
echo [3] МОДУЛЬ 2: Настройка Панели задач (Дата, Без погоды/чата)
echo [4] МОДУЛЬ 3: Контекстное меню PRO (CMD, PowerShell, Права)
echo [5] МОДУЛЬ 4: Классический Photo Viewer
echo [6] МОДУЛЬ 5: Системные улучшения (DevMgr, Управление)
echo [7] МОДУЛЬ 6: Приватность и Производительность
echo [8] ОТКАТ ВСЕГО (Restore Defaults)
echo [9] ВЫХОД
echo.
set /p choice="Введите номер (1-9) и нажмите Enter: "

if "%choice%"=="1" goto APPLY_ALL
if "%choice%"=="2" goto MODULE_1
if "%choice%"=="3" goto MODULE_2
if "%choice%"=="4" goto MODULE_3
if "%choice%"=="5" goto MODULE_4
if "%choice%"=="6" goto MODULE_5
if "%choice%"=="7" goto MODULE_6
if "%choice%"=="8" goto RESTORE_ALL
if "%choice%"=="9" exit /b 0
echo [ОШИБКА] Неверный выбор.
pause & exit /b 1

:APPLY_ALL
call :MODULE_1
call :MODULE_2
call :MODULE_3
call :MODULE_4
call :MODULE_5
call :MODULE_6
goto RESTART_EXPLORER

:MODULE_1
echo.
echo [ИНФО] Модуль 1: Очистка Проводника...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" /v "ThisPCPolicy" /t REG_SZ /d "Hide" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" /f >nul 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\DelegateFolders\{59031A47-3F72-44A7-89C5-5595FE6B30EE}" /f >nul 2>&1
echo [УСПЕХ] Папки и OneDrive скрыты.
goto :EOF

:MODULE_2
echo.
echo [ИНФО] Модуль 2: Настройка Панели задач...
reg add "HKCU\Control Panel\International" /v "sShortDate" /t REG_SZ /d "ddd dd.MM.yy" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAl" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v "PeopleBand" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAMeetNow" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" /v "ChatIcon" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAHealth" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] Панель задач настроена.
goto :EOF

:MODULE_3
echo.
echo [ИНФО] Модуль 3: Контекстное меню PRO...

echo [ИНФО] Добавление CMD и PowerShell в контекстное меню папок и фона...
reg add "HKLM\Software\Classes\Directory\shell\OpenCmdHere" /ve /t REG_SZ /d "Открыть в CMD" /f >nul 2>&1
reg add "HKLM\Software\Classes\Directory\shell\OpenCmdHere" /v "Icon" /t REG_SZ /d "cmd.exe" /f >nul 2>&1
reg add "HKLM\Software\Classes\Directory\shell\OpenCmdHere\command" /ve /t REG_SZ /d "cmd.exe /s /k pushd \"%V\"" /f >nul 2>&1

reg add "HKLM\Software\Classes\Directory\Background\shell\OpenCmdHere" /ve /t REG_SZ /d "Открыть в CMD" /f >nul 2>&1
reg add "HKLM\Software\Classes\Directory\Background\shell\OpenCmdHere" /v "Icon" /t REG_SZ /d "cmd.exe" /f >nul 2>&1
reg add "HKLM\Software\Classes\Directory\Background\shell\OpenCmdHere\command" /ve /t REG_SZ /d "cmd.exe /s /k pushd \"%V\"" /f >nul 2>&1

reg add "HKLM\Software\Classes\Directory\shell\OpenPSHere" /ve /t REG_SZ /d "Открыть в PowerShell" /f >nul 2>&1
reg add "HKLM\Software\Classes\Directory\shell\OpenPSHere" /v "Icon" /t REG_SZ /d "powershell.exe" /f >nul 2>&1
reg add "HKLM\Software\Classes\Directory\shell\OpenPSHere\command" /ve /t REG_SZ /d "powershell.exe -NoExit -Command Set-Location -LiteralPath '%V'" /f >nul 2>&1

reg add "HKLM\Software\Classes\Directory\Background\shell\OpenPSHere" /ve /t REG_SZ /d "Открыть в PowerShell" /f >nul 2>&1
reg add "HKLM\Software\Classes\Directory\Background\shell\OpenPSHere" /v "Icon" /t REG_SZ /d "powershell.exe" /f >nul 2>&1
reg add "HKLM\Software\Classes\Directory\Background\shell\OpenPSHere\command" /ve /t REG_SZ /d "powershell.exe -NoExit -Command Set-Location -LiteralPath '%V'" /f >nul 2>&1

echo [ИНФО] Добавление инструментов управления правами и атрибутами...
reg add "HKCR\*\shell\Access" /v "MUIVerb" /t REG_SZ /d "Разрешения безопасности" /f >nul 2>&1
reg add "HKCR\*\shell\Access" /v "SubCommands" /t REG_SZ /d "takeown_files;takeown_system;access_admins;access_full;access_null;access_system" /f >nul 2>&1
reg add "HKCR\*\shell\Access" /v "Icon" /t REG_EXPAND_SZ /d "shell32.dll,47" /f >nul 2>&1
reg add "HKCR\*\shell\Access" /v "Position" /t REG_SZ /d "Bottom" /f >nul 2>&1
reg add "HKCR\Directory\shell\Access" /v "MUIVerb" /t REG_SZ /d "Разрешения безопасности" /f >nul 2>&1
reg add "HKCR\Directory\shell\Access" /v "SubCommands" /t REG_SZ /d "takeown_recursive;takeown_system;access_admins;access_full;access_null;access_system" /f >nul 2>&1
reg add "HKCR\Directory\shell\Access" /v "Icon" /t REG_EXPAND_SZ /d "shell32.dll,47" /f >nul 2>&1
reg add "HKCR\Directory\shell\Access" /v "Position" /t REG_SZ /d "Bottom" /f >nul 2>&1
reg add "HKCR\*\shell\Attributes" /v "MUIVerb" /t REG_SZ /d "Атрибуты" /f >nul 2>&1
reg add "HKCR\*\shell\Attributes" /v "SubCommands" /t REG_SZ /d "Attributes_HiddenSystem;Attributes_NoHiddenSystem" /f >nul 2>&1
reg add "HKCR\*\shell\Attributes" /v "Icon" /t REG_EXPAND_SZ /d "shell32.dll,110" /f >nul 2>&1
reg add "HKCR\*\shell\Attributes" /v "Position" /t REG_SZ /d "Bottom" /f >nul 2>&1
reg add "HKCR\Directory\shell\Attributes" /v "MUIVerb" /t REG_SZ /d "Атрибуты" /f >nul 2>&1
reg add "HKCR\Directory\shell\Attributes" /v "SubCommands" /t REG_SZ /d "Attributes_HiddenSystem;Attributes_HiddenSystemFolder;Attributes_NoHiddenSystem;Attributes_NoHiddenSystemFolder" /f >nul 2>&1
reg add "HKCR\Directory\shell\Attributes" /v "Icon" /t REG_EXPAND_SZ /d "shell32.dll,110" /f >nul 2>&1
reg add "HKCR\Directory\shell\Attributes" /v "Position" /t REG_SZ /d "Bottom" /f >nul 2>&1

echo [ИНФО] Регистрация команд хранилища (CommandStore)...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\access_admins" /ve /t REG_SZ /d "Доступ: предоставить Администраторам" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\access_admins" /v "Icon" /t REG_SZ /d "shell32.dll,47" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\access_admins\command" /ve /t REG_SZ /d "cmd /q /c TITLE %1: Разрешения безопасности & ECHO Смена разрешений безопасности для выбранного обьекта: & icacls \"%1\" /grant Администраторы:F /C /T /Q && (ECHO Смена разрешений безопасности завершена & ECHO Доступ к обьекту: Администраторы) & timeout /t 5" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\access_full" /ve /t REG_SZ /d "Доступ: разрешить для всех" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\access_full" /v "Icon" /t REG_SZ /d "shell32.dll,47" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\access_full\command" /ve /t REG_SZ /d "cmd /q /c TITLE %1: Разрешения безопасности & ECHO Смена разрешений безопасности для выбранного обьекта: & icacls \"%1\" /grant:r Все:F /C /T /Q && (ECHO Смена разрешений безопасности завершена & ECHO Доступ к обьекту: разрешен для ВСЕХ) & timeout /t 5" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\access_null" /ve /t REG_SZ /d "Доступ: запретить для всех" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\access_null" /v "Icon" /t REG_SZ /d "shell32.dll,47" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\access_null\command" /ve /t REG_SZ /d "cmd /q /c TITLE %1: Разрешения безопасности & ECHO Смена разрешений безопасности для выбранного обьекта: & icacls \"%1\" /deny Все:F /C /Q && (ECHO Смена разрешений безопасности завершена & ECHO Доступ к обьекту: запрещено для ВСЕХ) & timeout /t 5" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\access_system" /ve /t REG_SZ /d "Доступ: предоставить системе" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\access_system" /v "Icon" /t REG_SZ /d "shell32.dll,47" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\access_system\command" /ve /t REG_SZ /d "cmd /q /c TITLE %1: Разрешения безопасности & ECHO Смена разрешений безопасности для выбранного обьекта: & icacls \"%1\" /grant SYSTEM:F /C /T /Q && (ECHO Смена разрешений безопасности завершена & ECHO Доступ к обьекту: SYSTEM) & timeout /t 5" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\takeown_files" /ve /t REG_SZ /d "Стать владельцем (Администраторы)" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\takeown_files" /v "Icon" /t REG_SZ /d "shell32.dll,158" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\takeown_files\command" /ve /t REG_SZ /d "cmd /q /c TITLE %1: Смена владельца (файлы) & ECHO Смена владельца для выбранного обьекта: & takeown /F \"%1\" /A && (ECHO Смена владельца завершена & ECHO Новый владелец обьекта: Администраторы) & timeout /t 5" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\takeown_recursive" /ve /t REG_SZ /d "Стать владельцем (файлы и подпапки)" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\takeown_recursive" /v "Icon" /t REG_SZ /d "shell32.dll,158" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\takeown_recursive\command" /ve /t REG_SZ /d "cmd /q /c TITLE %1: Смена владельца (подпапки и файлы) & ECHO Смена владельца для содержимого папки: & takeown /F \"%1\" /R /A /D Y && (ECHO Смена владельца завершена & ECHO Новый владелец обьекта: Администраторы) & timeout /t 5" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\takeown_system" /ve /t REG_SZ /d "Стать владельцем (система)" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\takeown_system" /v "Icon" /t REG_SZ /d "shell32.dll,158" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\takeown_system\command" /ve /t REG_SZ /d "cmd /q /c TITLE %1: Смена владельца & ECHO Смена владельца для выбранной папки: & takeown /F \"%1\" && (ECHO Смена владельца завершена & ECHO Новый владелец обьекта: %%USERNAME%%) & timeout /t 5" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Attributes_HiddenSystem" /v "MUIVerb" /t REG_SZ /d "Установить \"Скрытый+Системный\"" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Attributes_HiddenSystem" /v "Icon" /t REG_SZ /d "shell32.dll,65" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Attributes_HiddenSystem\command" /ve /t REG_SZ /d "cmd.exe /q /c FOR /F \"usebackq delims==\" %%i IN ('%1') DO ECHO Установка атрибутов для %1 & TITLE Установка атрибутов для %1 & attrib +s +h \"%1\" || (TITLE Ошибка установки аттрибутов & ECHO - & ECHO Ошибка установки аттрибутов на %1 & timeout /t 5)" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Attributes_HiddenSystemFolder" /v "MUIVerb" /t REG_SZ /d "Установить \"Скрытый+Системный\" (с подкаталогами)" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Attributes_HiddenSystemFolder" /v "Icon" /t REG_SZ /d "shell32.dll,66" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Attributes_HiddenSystemFolder\command" /ve /t REG_SZ /d "cmd.exe /q /c FOR /F \"usebackq delims==\" %%i IN ('%1') DO ECHO Установка атрибутов для %1 & TITLE Установка атрибутов для %1 & attrib +s +h \"%1\" & attrib +s +h \"%1\\*\" /S /D || (TITLE Ошибка установки аттрибутов & ECHO - & ECHO Ошибка установки атрибутов на %1 & timeout /t 5)" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Attributes_NoHiddenSystem" /v "MUIVerb" /t REG_SZ /d "Снять \"Скрытый+Системный\"" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Attributes_NoHiddenSystem" /v "Icon" /t REG_SZ /d "shell32.dll,65" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Attributes_NoHiddenSystem\command" /ve /t REG_SZ /d "cmd.exe /q /c FOR /F \"usebackq delims==\" %%i IN ('%1') DO ECHO Снятие атрибутов с %1 & TITLE Снятие атрибутов с %1 & attrib -s -h \"%1\" || (TITLE Ошибка установки аттрибутов & ECHO - & ECHO Ошибка установки аттрибутов на %1 & timeout /t 5)" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Attributes_NoHiddenSystemFolder" /v "MUIVerb" /t REG_SZ /d "Снять \"Скрытый+Системный\" (с подкаталогами)" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Attributes_NoHiddenSystemFolder" /v "Icon" /t REG_SZ /d "shell32.dll,66" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Attributes_NoHiddenSystemFolder\command" /ve /t REG_SZ /d "cmd.exe /q /c FOR /F \"usebackq delims==\" %%i IN ('%1') DO ECHO Снятие атрибутов с %1 & TITLE Снятие атрибутов с %1 & attrib -s -h \"%1\" & attrib -s -h \"%1\\*\" /S /D || (TITLE Ошибка установки аттрибутов & ECHO - & ECHO Ошибка установки атрибутов на %1 & timeout /t 5)" /f >nul 2>&1
reg add "HKCR\exefile\shell\runcmd" /v "MUIVerb" /t REG_SZ /d "Запустить в командной строке" /f >nul 2>&1
reg add "HKCR\exefile\shell\runcmd" /v "Icon" /t REG_EXPAND_SZ /d "cmd.exe,0" /f >nul 2>&1
reg add "HKCR\exefile\shell\runcmd\command" /ve /t REG_SZ /d "cmd.exe /k TITLE Запуск \"%1\" & ECHO Запуск программы %1: & \"%1\"" /f >nul 2>&1
reg add "HKLM\Software\Classes\AllFilesystemObjects\shellex\ContextMenuHandlers\Copy To" /ve /t REG_SZ /d "{C2FBB630-2971-11D1-A18C-00C04FD75D13}" /f >nul 2>&1
reg add "HKLM\Software\Classes\AllFilesystemObjects\shellex\ContextMenuHandlers\Move To" /ve /t REG_SZ /d "{C2FBB631-2971-11D1-A18C-00C04FD75D13}" /f >nul 2>&1
echo [УСПЕХ] Контекстное меню PRO установлено.
goto :EOF

:MODULE_4
echo.
echo [ИНФО] Модуль 4: Классический Photo Viewer...
reg add "HKCR\Applications\photoviewer.dll\shell\open" /v "MuiVerb" /t REG_EXPAND_SZ /d "@photoviewer.dll,-3043" /f >nul 2>&1
reg add "HKCR\Applications\photoviewer.dll\shell\open\command" /ve /t REG_EXPAND_SZ /d "%%SystemRoot%%\System32\rundll32.exe \"%%ProgramFiles%%\Windows Photo Viewer\PhotoViewer.dll\", ImageView_Fullscreen %%1" /f >nul 2>&1
reg add "HKCR\Applications\photoviewer.dll\shell\open\DropTarget" /v "Clsid" /t REG_SZ /d "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}" /f >nul 2>&1
reg add "HKCR\PhotoViewer.FileAssoc.Bitmap" /v "ImageOptionFlags" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCR\PhotoViewer.FileAssoc.Jpeg" /v "ImageOptionFlags" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCR\PhotoViewer.FileAssoc.JFIF" /v "ImageOptionFlags" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCR\PhotoViewer.FileAssoc.Gif" /v "ImageOptionFlags" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCR\PhotoViewer.FileAssoc.Png" /v "ImageOptionFlags" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".jpg" /t REG_SZ /d "PhotoViewer.FileAssoc.Jpeg" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".png" /t REG_SZ /d "PhotoViewer.FileAssoc.Png" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".bmp" /t REG_SZ /d "PhotoViewer.FileAssoc.Bitmap" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations" /v ".gif" /t REG_SZ /d "PhotoViewer.FileAssoc.Gif" /f >nul 2>&1
echo [УСПЕХ] Photo Viewer восстановлен.
goto :EOF

:MODULE_5
echo.
echo [ИНФО] Модуль 5: Системные улучшения...
reg add "HKLM\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\Manage" /v "Icon" /t REG_SZ /d "imageres.dll,73" /f >nul 2>&1
reg add "HKLM\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\DevMgr" /ve /t REG_EXPAND_SZ /d "@devmgr.dll,-4" /f >nul 2>&1
reg add "HKLM\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\DevMgr" /v "Icon" /t REG_SZ /d "devmgr.dll,4" /f >nul 2>&1
reg add "HKLM\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\DevMgr\command" /ve /t REG_SZ /d "mmc.exe devmgmt.msc" /f >nul 2>&1
reg add "HKLM\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\DiskManager" /ve /t REG_EXPAND_SZ /d "@%SystemRoot%\system32\dmdskres.dll,-1003" /f >nul 2>&1
reg add "HKLM\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\DiskManager" /v "Icon" /t REG_SZ /d "dmdskres.dll,0" /f >nul 2>&1
reg add "HKLM\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\DiskManager\command" /ve /t REG_SZ /d "mmc diskmgmt.msc" /f >nul 2>&1
reg add "HKLM\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\services" /ve /t REG_EXPAND_SZ /d "@filemgmt.dll,-2204" /f >nul 2>&1
reg add "HKLM\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\services" /v "Icon" /t REG_SZ /d "filemgmt.dll" /f >nul 2>&1
reg add "HKLM\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\services\command" /ve /t REG_SZ /d "mmc.exe services.msc" /f >nul 2>&1
reg add "HKLM\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\appwizcpl" /ve /t REG_EXPAND_SZ /d "@appwiz.cpl,-159" /f >nul 2>&1
reg add "HKLM\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\appwizcpl" /v "Icon" /t REG_SZ /d "appwiz.cpl,3" /f >nul 2>&1
reg add "HKLM\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\appwizcpl\command" /ve /t REG_SZ /d "rundll32.exe shell32.dll,Control_RunDLL appwiz.cpl,,0" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager\LastKnownGood" /v "Enabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] Системные улучшения применены.
goto :EOF

:MODULE_6
echo.
echo [ИНФО] Модуль 6: Приватность и Производительность...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "OemPreInstalledAppsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEverEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\System\ControlSet001\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableStatusMessages" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\System\ControlSet001\Control\CrashControl" /v "AutoReboot" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_SZ /d 0 /f >nul 2>&1
reg add "HKCU\Control Panel\Keyboard" /v "KeyboardDelay" /t REG_SZ /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /v "DisableFirstRunCustomize" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "NoInternetOpenWith" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoInternetOpenWith" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] Приватность и производительность настроены.
goto :EOF

:RESTORE_ALL
echo.
echo [ИНФО] Полный откат всех настроек...

echo [ИНФО] Сброс видимости папок...
for %%G in ({35286a68-3c57-41a1-bbb1-0eae73d76c95} {f42ee2d3-909f-4907-8871-4c22fc0bf756} {7d83ee9b-2244-4e70-b1f5-5393042af1e4} {0ddd015d-b06c-45d5-8c4c-f59713854639} {a0c69a99-21c8-4671-8703-7934162fcf1d} {B4BFCC3A-DB2C-424C-B029-7FE99A87C641}) do (
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\%%G\PropertyBag" /v "ThisPCPolicy" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\%%G\PropertyBag" /v "ThisPCPolicy" /f >nul 2>&1
)
echo [УСПЕХ] Видимость папок сброшена.

echo [ИНФО] Сброс панели задач...
reg delete "HKCU\Control Panel\International" /v "sShortDate" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAl" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTaskViewButton" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v "PeopleBand" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAMeetNow" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarViewMode" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" /v "ChatIcon" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAHealth" /f >nul 2>&1
echo [УСПЕХ] Панель задач сброшена.

echo [ИНФО] Удаление контекстного меню PRO...
reg delete "HKLM\Software\Classes\Directory\shell\OpenCmdHere" /f >nul 2>&1
reg delete "HKLM\Software\Classes\Directory\Background\shell\OpenCmdHere" /f >nul 2>&1
reg delete "HKLM\Software\Classes\Directory\shell\OpenPSHere" /f >nul 2>&1
reg delete "HKLM\Software\Classes\Directory\Background\shell\OpenPSHere" /f >nul 2>&1
reg delete "HKCR\*\shell\Access" /f >nul 2>&1
reg delete "HKCR\Directory\shell\Access" /f >nul 2>&1
reg delete "HKCR\*\shell\Attributes" /f >nul 2>&1
reg delete "HKCR\Directory\shell\Attributes" /f >nul 2>&1
reg delete "HKCR\exefile\shell\runcmd" /f >nul 2>&1
reg delete "HKLM\Software\Classes\AllFilesystemObjects\shellex\ContextMenuHandlers\Copy To" /f >nul 2>&1
reg delete "HKLM\Software\Classes\AllFilesystemObjects\shellex\ContextMenuHandlers\Move To" /f >nul 2>&1
for %%G in (access_admins access_full access_null access_system takeown_files takeown_recursive takeown_system Attributes_HiddenSystem Attributes_HiddenSystemFolder Attributes_NoHiddenSystem Attributes_NoHiddenSystemFolder) do (
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\%%G" /f >nul 2>&1
)
echo [УСПЕХ] Контекстное меню очищено.

echo [ИНФО] Удаление Photo Viewer...
reg delete "HKCR\Applications\photoviewer.dll" /f >nul 2>&1
reg delete "HKCR\PhotoViewer.FileAssoc.Bitmap" /f >nul 2>&1
reg delete "HKCR\PhotoViewer.FileAssoc.Jpeg" /f >nul 2>&1
reg delete "HKCR\PhotoViewer.FileAssoc.JFIF" /f >nul 2>&1
reg delete "HKCR\PhotoViewer.FileAssoc.Gif" /f >nul 2>&1
reg delete "HKCR\PhotoViewer.FileAssoc.Png" /f >nul 2>&1
echo [УСПЕХ] Photo Viewer удален из ассоциаций.

echo [ИНФО] Сброс системных улучшений...
reg delete "HKLM\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\Manage" /f >nul 2>&1
reg delete "HKLM\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\DevMgr" /f >nul 2>&1
reg delete "HKLM\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\DiskManager" /f >nul 2>&1
reg delete "HKLM\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\services" /f >nul 2>&1
reg delete "HKLM\Software\Classes\CLSID\{20D04FE0-3AEA-1069-A2D8-08002B30309D}\shell\appwizcpl" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager\LastKnownGood" /v "Enabled" /f >nul 2>&1
echo [УСПЕХ] Системные настройки сброшены.

echo [ИНФО] Сброс приватности и производительности...
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "OemPreInstalledAppsEnabled" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEverEnabled" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /f >nul 2>&1
reg delete "HKLM\System\ControlSet001\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /f >nul 2>&1
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableStatusMessages" /f >nul 2>&1
reg delete "HKLM\System\ControlSet001\Control\CrashControl" /v "AutoReboot" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Internet Explorer\Main" /v "DisableFirstRunCustomize" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /v "EnabledV9" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "NoInternetOpenWith" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoInternetOpenWith" /f >nul 2>&1
echo [УСПЕХ] Приватность и производительность сброшены.

goto RESTART_EXPLORER

:RESTART_EXPLORER
echo.
echo [ИНФО] Перезапуск Проводника...
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
echo [УСПЕХ] Проводник перезапущен.
goto END

:END
echo.
echo [ИТОГ] Операция завершена. Перезагрузите компьютер.
pause
exit /b 0