
@echo off
chcp 65001 >nul 2>&1
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - UAC Full Control Center
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Полный контроль над UAC и уведомлениями безопасности Windows
echo.
echo [ЧТО ЭТО] Универсальный инструмент для настройки уровня запросов UAC и блокировки всплывающих уведомлений.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Устранение затемнения экрана, назойливых запросов и уведомлений Центра безопасности.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Настроит уровень UAC: Тихий, Без затемнения, Заводской или Полное отключение.
echo   2. Включит или отключит уведомления SecurityAndMaintenance.
echo   3. Обеспечит полный откат к заводским настройкам.
echo.
echo [ВАЖНО] Режим "Полное отключение" ломает приложения Store (Калькулятор, Фото).
echo [ВАЖНО] Для применения всех настроек требуется ПЕРЕЗАГРУЗКА.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

echo.
echo ВЫБЕРИТЕ РЕЖИМ РАБОТЫ:
echo [1] ТИХИЙ РЕЖИМ (Silent Admin)
echo     - UAC включен, но НЕ СПРАШИВАЕТ и НЕ ЗАТЕМНЯЕТ экран.
echo     - Уведомления Центра безопасности ОТКЛЮЧЕНЫ.
echo     - Store и виджеты РАБОТАЮТ корректно.
echo.
echo [2] ЗАПРОС БЕЗ ЗАТЕМНЕНИЯ (No Dimming)
echo     - UAC СПРАШИВАЕТ подтверждение, но НЕ ЗАТЕМНЯЕТ экран.
echo     - Удобно для частых действий админа.
echo     - Уведомления Центра безопасности ОТКЛЮЧЕНЫ.
echo.
echo [3] ЗАВОДСКИЕ НАСТРОЙКИ (Restore Defaults)
echo     - Вернуть стандартные запросы UAC с затемнением.
echo     - Включить уведомления Windows.
echo.
echo [4] ПОЛНОЕ ОТКЛЮЧЕНИЕ (Hard Disable)
echo     - UAC вырезан из ядра (EnableLUA=0).
echo     - НИКАКИХ запросов вообще.
echo     - ВНИМАНИЕ: Store и UWP приложения ПЕРЕСТАНУТ работать!
echo.
echo [5] ВЫХОД
echo.
set /p choice="Введите номер (1-5) и нажмите Enter: "

if "%choice%"=="1" goto MODE_SILENT
if "%choice%"=="2" goto MODE_NO_DIM
if "%choice%"=="3" goto MODE_RESTORE
if "%choice%"=="4" goto MODE_HARD
if "%choice%"=="5" exit /b 0
echo [ОШИБКА] Неверный выбор.
pause & exit /b 1

:MODE_SILENT
echo.
echo [ИНФО] Применение тихого режима...

echo [ИНФО] Включение базового механизма UAC (EnableLUA=1)...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d 1 /f >nul 2>&1

echo [ИНФО] Отключение запросов для админа (ConsentPromptBehaviorAdmin=0)...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 0 /f >nul 2>&1

echo [ИНФО] Отключение затемнения (PromptOnSecureDesktop=0)...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 0 /f >nul 2>&1

echo [ИНФО] Блокировка уведомлений безопасности (HKCU/HKLM)...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1

echo [УСПЕХ] Тихий режим применен.
goto END

:MODE_NO_DIM
echo.
echo [ИНФО] Применение режима "Запрос без затемнения"...

echo [ИНФО] Включение базового механизма UAC (EnableLUA=1)...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d 1 /f >nul 2>&1

echo [ИНФО] Включение запросов для админа (ConsentPromptBehaviorAdmin=5)...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 5 /f >nul 2>&1

echo [ИНФО] Отключение затемнения (PromptOnSecureDesktop=0)...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 0 /f >nul 2>&1

echo [ИНФО] Блокировка уведомлений безопасности (HKCU/HKLM)...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1

echo [УСПЕХ] Режим "Без затемнения" применен.
goto END

:MODE_RESTORE
echo.
echo [ИНФО] Возврат заводских настроек...

echo [ИНФО] Включение UAC (EnableLUA=1)...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d 1 /f >nul 2>&1

echo [ИНФО] Включение запросов (ConsentPromptBehaviorAdmin=5)...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 5 /f >nul 2>&1

echo [ИНФО] Включение затемнения (PromptOnSecureDesktop=1)...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 1 /f >nul 2>&1

echo [ИНФО] Восстановление уведомлений безопасности...
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /f >nul 2>&1

echo [УСПЕХ] Заводские настройки восстановлены.
goto END

:MODE_HARD
echo.
echo [ВНИМАНИЕ] Вы выбрали полное отключение UAC.
echo [ВНИМАНИЕ] Современные приложения (Store, Calculator) перестанут открываться.
choice /C YN /M "Вы уверены? Продолжить (Y/N)?"
if errorlevel 2 exit /b 0

echo [ИНФО] Полное отключение ядра UAC (EnableLUA=0)...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d 0 /f >nul 2>&1

echo [ИНФО] Сброс фильтра токена...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "FilterAdministratorToken" /t REG_DWORD /d 0 /f >nul 2>&1

echo [ИНФО] Блокировка уведомлений безопасности...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1

echo [УСПЕХ] Полное отключение применено.
goto END

:END
echo.
echo [ИТОГ] Операция завершена. ПЕРЕЗАГРУЗИТЕ систему.
pause
exit /b 0