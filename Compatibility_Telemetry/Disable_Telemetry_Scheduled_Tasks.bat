@echo off
chcp 65001 >nul
:: ==========================================================
:: ФАЙЛ: Disable_Telemetry_Scheduled_Tasks.bat
:: НАЗНАЧЕНИЕ: Отключение задач планировщика для сбора телеметрии и инвентаризации
:: ==========================================================
:: ЧТО ЭТО: Скрипт принудительного отключения задач в папке
:: \Microsoft\Windows\Application Experience и связанных с телеметрией.
::
:: ЗАЧЕМ МЕНЯЕМ: Реестр отключает службы, но задачи планировщика
:: остаются "Включены". При попытке запуска они создают ошибки
:: в журнале событий и могут препятствовать переходу диска в сон.
::
:: ЧТО СДЕЛАЕТ ФАЙЛ:
:: 1. Отключит задачу "Microsoft Compatibility Appraiser" (сбор данных о ПО).
:: 2. Отключит задачу "ProgramDataUpdater" (обновление данных совместимости).
:: 3. Отключит задачу "AitAgent" (агент влияния приложений).
:: 4. Отключит задачу "Consolidator" (сбор данных CEIP).
::
:: ВАЖНО:
:: - Требуются права Администратора.
:: - Не удаляет задачи, а меняет их статус на "Отключено" (безопасно для обновлений Windows).
:: - Изменения вступают в силу немедленно, перезагрузка не обязательна, но желательна.
:: АКТИВАЦИЯ:
:: 1. Запустите файл от имени Администратора.
:: 2. Проверьте результат в "Планировщике заданий".
:: ==========================================================
:: AKUMEN Consulting
:: ==========================================================

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Отключение Microsoft Compatibility Appraiser ---
:: Назначение: Основной сборщик данных об установленных приложениях и их использовании.
echo [ИНФО] Отключение задачи: Microsoft Compatibility Appraiser...
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable >nul 2>&1
if %errorlevel% equ 0 (
    echo [УСПЕХ] Задача Microsoft Compatibility Appraiser отключена.
) else (
    echo [ОШИБКА] Не удалось отключить задачу. Возможно, она уже отключена или отсутствует. Код: %errorlevel%
)

:: --- ШАГ 2: Отключение ProgramDataUpdater ---
:: Назначение: Обновление данных программы улучшения качества (CEIP).
echo [ИНФО] Отключение задачи: ProgramDataUpdater...
schtasks /Change /TN "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /Disable >nul 2>&1
if %errorlevel% equ 0 (
    echo [УСПЕХ] Задача ProgramDataUpdater отключена.
) else (
    echo [ОШИБКА] Не удалось отключить задачу. Код: %errorlevel%
)

:: --- ШАГ 3: Отключение AitAgent ---
:: Назначение: Агент сбора данных о влиянии приложений (Application Impact Telemetry).
echo [ИНФО] Отключение задачи: AitAgent...
schtasks /Change /TN "\Microsoft\Windows\Application Experience\AitAgent" /Disable >nul 2>&1
if %errorlevel% equ 0 (
    echo [УСПЕХ] Задача AitAgent отключена.
) else (
    echo [ОШИБКА] Не удалось отключить задачу. Код: %errorlevel%
)

:: --- ШАГ 4: Отключение Consolidator ---
:: Назначение: Консолидация данных CEIP для отправки в Microsoft.
echo [ИНФО] Отключение задачи: Consolidator...
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable >nul 2>&1
if %errorlevel% equ 0 (
    echo [УСПЕХ] Задача Consolidator отключена.
) else (
    echo [ОШИБКА] Не удалось отключить задачу. Код: %errorlevel%
)

echo.
echo [ИТОГ] Задачи планировщика отключены. Рекомендуется перезагрузка для сброса активных хендлов.
pause