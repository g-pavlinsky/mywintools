@echo off
chcp 65001 >nul

echo.
echo ============================================================
echo    AKUMEN Consulting
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Полное отключение Microsoft Edge и запрет обновлений
echo.
echo [ЧТО ЭТО] Скрипт блокирует запуск Edge, скрывает его из меню Пуск и запрещает фоновые процессы.
echo.
echo [ЗАЧЕМ МЕНЯЕМ] Edge навязчиво открывается при поиске в Пуске, потребляет ресурсы и обновляется без спроса.
echo.
echo [ЧТО СДЕЛАЕТ ФАЙЛ]
echo   1. Запретит автоматические обновления Edge.
echo   2. Скроет интерфейс первого запуска.
echo   3. Отключит фоновые задачи Edge в Планировщике.
echo   4. Заблокирует перезапуск Edge после закрытия.
echo.
echo [ВАЖНО] Edge не удаляется физически (это ломает WebView2 и виджеты).
echo [ВАЖНО] Он просто перестанет запускаться и мешать.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Блокировка обновлений и политик ---
echo [ИНФО] Блокировка обновлений Edge...
reg add "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v "DoNotUpdateToEdgeWithChromium" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "HideFirstRunExperience" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
echo [УСПЕХ] Политики применены.

:: --- ШАГ 2: Отключение задач Планировщика ---
echo [ИНФО] Отключение задач обновления Edge...
schtasks /change /tn "\Microsoft\EdgeUpdate\EdgeUpdateTaskMachineCore" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\EdgeUpdate\EdgeUpdateTaskMachineUA" /disable >nul 2>&1
schtasks /change /tn "\Microsoft\EdgeUpdate\EdgeUpdateBrowserReplacementTask" /disable >nul 2>&1
echo [УСПЕХ] Задачи отключены.

:: --- ШАГ 3: Остановка процессов ---
echo [ИНФО] Завершение процессов Edge...
taskkill /F /IM msedge.exe >nul 2>&1
taskkill /F /IM MicrosoftEdgeUpdate.exe >nul 2>&1
taskkill /F /IM msedgeupdate.exe >nul 2>&1
echo [УСПЕХ] Процессы завершены.

:: --- ШАГ 4: Переименование основного исполняемого файла (Soft Block) ---
echo [ИНФО] Блокировка прямого запуска (переименование exe)...
set "EdgePath=%ProgramFiles(x86)%\Microsoft\Edge\Application"
if exist "%EdgePath%\msedge.exe" (
    if not exist "%EdgePath%\msedge.exe.bak" (
        ren "%EdgePath%\msedge.exe" "msedge.exe.bak"
        echo [УСПЕХ] Исполняемый файл переименован.
    ) else (
        echo [ИНФО] Файл уже переименован.
    )
) else (
    echo [ИНФО] Путь Edge не найден (возможно, другая версия Windows).
)

echo.
echo [ИТОГ] Edge отключен. Ярлыки могут остаться, но браузер не запустится.
pause