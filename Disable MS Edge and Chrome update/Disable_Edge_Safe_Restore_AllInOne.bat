@echo off
chcp 65001 >nul

echo.
echo ============================================================
echo    AKUMEN Consulting (RESTORE)
echo ============================================================
echo.
echo [НАЗНАЧЕНИЕ] Восстановление работы Microsoft Edge
echo.
echo [ЧТО ЭТО] Возвращает возможность запуска и обновлений Edge.
echo.
echo [АКТИВАЦИЯ] Запуск от имени Администратора.
echo ============================================================
echo.

echo [ИНФО] Проверка прав администратора...
net session >nul 2>&1 || (echo [ОШИБКА] Запустите от имени Администратора! & pause & exit /b 1)
echo [УСПЕХ] Права подтверждены.

:: --- ШАГ 1: Возврат исполняемого файла ---
echo [ИНФО] Восстановление имени файла msedge.exe...
set "EdgePath=%ProgramFiles(x86)%\Microsoft\Edge\Application"
if exist "%EdgePath%\msedge.exe.bak" (
    ren "%EdgePath%\msedge.exe.bak" "msedge.exe"
    echo [УСПЕХ] Имя файла восстановлено.
)

:: --- ШАГ 2: Включение задач Планировщика ---
echo [ИНФО] Включение задач обновления...
schtasks /change /tn "\Microsoft\EdgeUpdate\EdgeUpdateTaskMachineCore" /enable >nul 2>&1
schtasks /change /tn "\Microsoft\EdgeUpdate\EdgeUpdateTaskMachineUA" /enable >nul 2>&1
schtasks /change /tn "\Microsoft\EdgeUpdate\EdgeUpdateBrowserReplacementTask" /enable >nul 2>&1

:: --- ШАГ 3: Удаление политик блокировки ---
echo [ИНФО] Удаление политик...
reg delete "HKLM\SOFTWARE\Microsoft\EdgeUpdate" /v "DoNotUpdateToEdgeWithChromium" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "HideFirstRunExperience" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" /f >nul 2>&1

echo.
echo [ИТОГ] Edge восстановлен.
pause