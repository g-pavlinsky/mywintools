@echo off
chcp 65001 >nul

echo.
echo ============================================================
echo    AKUMEN Consulting (RESTORE)
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Полный сброс политик Windows Update к заводским
echo.
echo [ЧТО ЭТО] Удаляет все пользовательские политики, возвращая управление системе.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Удаление ветки политик WU ---
echo [ИНФО] Удаление политик Windows Update...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /f >nul 2>&1
echo [УСПЕХ] Ветка WindowsUpdate удалена.

:: --- ШАГ 2: Сброс настроек драйверов ---
echo [ИНФО] Возврат стандартного поведения драйверов...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /f >nul 2>&1
echo [УСПЕХ] Настройки драйверов сброшены.

:: --- ШАГ 3: Перезапуск службы ---
echo [ИНФО] Перезапуск службы Windows Update...
net stop wuauserv >nul 2>&1
net start wuauserv >nul 2>&1
echo [УСПЕХ] Служба перезапущена.

echo.
echo [ИТОГ] Windows Update возвращен к стандартным настройкам.
pause