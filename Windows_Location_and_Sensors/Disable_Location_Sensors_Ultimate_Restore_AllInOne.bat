@echo off
chcp 65001 >nul

echo.
echo ============================================================
echo    AKUMEN Consulting (RESTORE)
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Полное восстановление служб геолокации и очистка hosts
echo.
echo [ЧТО ЭТО] Возвращает стандартные настройки служб, удаляет политики и чистит файл hosts от блокировок.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Восстановление автозапуска служб ---
echo [ИНФО] Включение служб геолокации...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\lfsvc" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SensorService" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SensrSvc" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
echo [УСПЕХ] Тип запуска восстановлен.

:: --- ШАГ 2: Удаление политик ---
echo [ИНФО] Удаление политик блокировки...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableSensors" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocationScripting" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableUsbBipCamera" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DisableLocationInTelemetry" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessLocation" /f >nul 2>&1
echo [УСПЕХ] Политики удалены.

:: --- ШАГ 3: Очистка Hosts ---
echo [ИНФО] Удаление блокировок из файла hosts...
set "HOSTS_FILE=C:\Windows\System32\drivers\etc\hosts"
powershell -Command "$content = Get-Content '%HOSTS_FILE%'; $newContent = @(); $skip = $false; foreach ($line in $content) { if ($line -match '# AKUMEN GeoBlock Start') { $skip = $true; continue } if ($line -match '# AKUMEN GeoBlock End') { $skip = $false; continue } if (!$skip) { $newContent += $line } }; $newContent | Set-Content '%HOSTS_FILE%'"
echo [УСПЕХ] Hosts очищен от блокировок геолокации.

:: --- ШАГ 4: Запуск служб и очистка DNS ---
echo [ИНФО] Запуск служб и сброс DNS...
net start lfsvc >nul 2>&1
ipconfig /flushdns >nul 2>&1
echo [УСПЕХ] Службы запущены, DNS обновлен.

echo.
echo [ИТОГ] Геолокация восстановлена. Перезагрузите ПК.
pause