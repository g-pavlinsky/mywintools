@echo off
chcp 65001 >nul

echo.
echo ============================================================
echo    AKUMEN Consulting
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Ultimate-блокировка геолокации, датчиков и сетевого трекинга
echo.
echo [ЧТО ЭТО] Монолитный скрипт, отключающий службы, политики и блокирующий сетевые запросы к API геолокации (MS, Google, Apple, Intel).
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Максимальная приватность. Исключение возможности определения местоположения через Wi-Fi, GPS, IP и Bluetooth.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Отключит и заблокирует службы lfsvc, SensorService, SensrSvc.
echo   2. Применит жесткие политики GPO (запрет датчиков, скриптов, телеметрии).
echo   3. Добавит расширенный список блокировок в файл hosts.
echo   4. Очистит DNS-кэш для немедленного применения сетевых правил.
echo.
echo [ВАЖНО] Карты, Погода, "Найти устройство" и автоповорот экрана перестанут работать.
echo [ВАЖНО] Изменения в hosts требуют прав администратора.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора. Перезагрузка обязательна.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Остановка служб ---
echo [ИНФО] Остановка служб геолокации и датчиков...
net stop lfsvc /y >nul 2>&1
net stop SensorService /y >nul 2>&1
net stop SensrSvc /y >nul 2>&1
echo [УСПЕХ] Службы остановлены.

:: --- ШАГ 2: Блокировка автозапуска служб ---
echo [ИНФО] Отключение служб через реестр...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\lfsvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SensorService" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SensrSvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
echo [УСПЕХ] Службы отключены.

:: --- ШАГ 3: Политики LocationAndSensors ---
echo [ИНФО] Применение политик блокировки датчиков...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableSensors" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocationScripting" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableUsbBipCamera" /t REG_DWORD /d 1 /f >nul 2>&1
echo [УСПЕХ] Политики датчиков применены.

:: --- ШАГ 4: Телеметрия, Реклама и AppPrivacy ---
echo [ИНФО] Блокировка сбора геоданных и рекламы...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DisableLocationInTelemetry" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsAccessLocation" /t REG_DWORD /d 2 /f >nul 2>&1
echo [УСПЕХ] Трекинг отключен.

:: --- ШАГ 5: Модификация файла Hosts (Network Level Block) ---
echo [ИНФО] Блокировка серверов геолокации в hosts...
set "HOSTS_FILE=C:\Windows\System32\drivers\etc\hosts"

:: Проверка наличия маркера, чтобы не дублировать записи
findstr /C:"AKUMEN GeoBlock" "%HOSTS_FILE%" >nul
if %errorlevel% neq 0 (
    echo. >> "%HOSTS_FILE%"
    echo # AKUMEN GeoBlock Start >> "%HOSTS_FILE%"
    
    :: Microsoft
    echo 0.0.0.0 location.services.mozilla.com >> "%HOSTS_FILE%"
    echo 0.0.0.0 wifi-location.windows.com >> "%HOSTS_FILE%"
    echo 0.0.0.0 geo-prod.do.dsp.mp.microsoft.com >> "%HOSTS_FILE%"
    echo 0.0.0.0 v10.events.data.microsoft.com >> "%HOSTS_FILE%"
    echo 0.0.0.0 maps.windows.com >> "%HOSTS_FILE%"
    echo 0.0.0.0 loc.service.microsoft.com >> "%HOSTS_FILE%"
    echo 0.0.0.0 geover.prod.do.dsp.mp.microsoft.com >> "%HOSTS_FILE%"
    
    :: Google / Android
    echo 0.0.0.0 www.google.com >> "%HOSTS_FILE%"
    echo 0.0.0.0 location.google.com >> "%HOSTS_FILE%"
    echo 0.0.0.0 clientservices.googleapis.com >> "%HOSTS_FILE%"
    
    :: Apple / iOS
    echo 0.0.0.0 init.itunes.apple.com >> "%HOSTS_FILE%"
    echo 0.0.0.0 configuration.apple.com >> "%HOSTS_FILE%"
    echo 0.0.0.0 gs-loc.apple.com >> "%HOSTS_FILE%"
    
    :: Hardware Vendors (Intel/Qualcomm Telemetry)
    echo 0.0.0.0 intel.com >> "%HOSTS_FILE%"
    echo 0.0.0.0 qualcomm.com >> "%HOSTS_FILE%"

    echo # AKUMEN GeoBlock End >> "%HOSTS_FILE%"
    echo [УСПЕХ] Расширенный список добавлен в hosts.
) else (
    echo [ИНФО] Записи уже присутствуют в hosts. Пропуск.
)

:: Очистка DNS кэша
ipconfig /flushdns >nul 2>&1
echo [УСПЕХ] DNS кэш очищен.

echo.
echo [ИТОГ] Геолокация полностью заблокирована. ПЕРЕЗАГРУЗИТЕ систему.
pause