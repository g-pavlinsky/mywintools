
@echo off
chcp 65001 >nul 2>&1
cls

echo.
echo ============================================================
echo    AKUMEN Consulting - Spectre and Meltdown Control
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Отключение защит Spectre/Meltdown для максимальной производительности
echo.
echo [ЧТО ЭТО] Скрипт применяет низкоуровневые настройки реестра, отключающие исправления уязвимостей.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Возврат производительности CPU (особенно I/O) к уровню Windows 7. Прирост 5-30% на старых ядрах.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Установит FeatureSettingsOverride для отключения митигаций.
echo   2. Заблокирует автоматическое включение защит через обновления.
echo   3. Позволит вернуть стандартные настройки безопасности (Откат).
echo.
echo [ВАЖНО] СИСТЕМА СТАНОВИТСЯ УЯЗВИМОЙ К АТАКАМ ЧТЕНИЯ ПАМЯТИ!
echo [ВАЖНО] НЕ ИСПОЛЬЗОВАТЬ на ПК с доступом в Интернет или недоверенным ПО.
echo [ВАЖНО] Только для изолированных игровых/рабочих станций.
echo [ВАЖНО] Требуется перезагрузка.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора. Перезагрузите ПК после выполнения.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

echo.
echo ВЫБЕРИТЕ ДЕЙСТВИЕ:
echo [1] ОТКЛЮЧИТЬ защиты (Apply Performance Mode)
echo [2] ВКЛЮЧИТЬ защиты (Restore Security Mode)
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
echo [ИНФО] Отключение митигаций Spectre и Meltdown...

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d 3 /f >nul 2>&1

echo [ИНФО] Блокировка переопределения политик через GPO...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "DisableMitigations" /t REG_DWORD /d 1 /f >nul 2>&1

echo [УСПЕХ] Настройки производительности применены.
goto END

:RESTORE
echo.
echo [ИНФО] Включение стандартных защит Spectre и Meltdown...

reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /f >nul 2>&1

echo [ИНФО] Разблокировка политик системы...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "DisableMitigations" /f >nul 2>&1

echo [УСПЕХ] Настройки безопасности восстановлены.
goto END

:END
echo.
echo [ИТОГ] Операция завершена. ПЕРЕЗАГРУЗИТЕ систему для вступления в силу.
pause
exit /b 0