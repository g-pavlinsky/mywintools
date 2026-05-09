@echo off
chcp 65001 >nul

echo.
echo ============================================================
echo    AKUMEN Consulting (RESTORE)
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Включение Credential Guard (Восстановление защиты)
echo.
echo [ЧТО ЭТО] Возвращает стандартные настройки безопасности LSA и запускает службу изоляции.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Восстановление защиты от кражи хэшей и Pass-the-Hash атак.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Удалит ключи реестра, отключающие LsaCfgFlags.
echo   2. Вернет тип запуска службы LsaIso в значение по умолчанию.
echo   3. Запустит службу LsaIso.
echo.
echo [ВАЖНО] Требуется перезагрузка.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Сброс конфигурации LSA ---
echo [ИНФО] Удаление настроек отключения LSA...
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "LsaCfgFlags" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard" /v "LsaCfgFlags" /f >nul 2>&1
echo [УСПЕХ] Флаги LSA сброшены.

:: --- ШАГ 2: Восстановление службы LsaIso ---
echo [ИНФО] Восстановление автозапуска LsaIso...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LsaIso" /v "Start" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] Тип запуска восстановлен.

:: --- ШАГ 3: Запуск службы ---
echo [ИНФО] Запуск службы LsaIso...
net start LsaIso >nul 2>&1
if %errorlevel% equ 0 (
    echo [УСПЕХ] Служба запущена.
) else (
    echo [ИНФО] Служба требует перезагрузки для запуска.
)

echo.
echo [ИТОГ] Защита восстановлена. ПЕРЕЗАГРУЗИТЕ систему.
pause