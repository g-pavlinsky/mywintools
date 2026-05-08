# Отключение задач планировщика (для усиленного варианта):
Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\" -TaskName "Microsoft Compatibility Appraiser"
Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\" -TaskName "ProgramDataUpdater"
Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\" -TaskName "AitAgent"

# Проверка потребления памяти службами:
Get-Process -Name AeLookupSvc, PcaSvc, WerSvc -ErrorAction SilentlyContinue | Select-Object Name, WorkingSet, CPU

# Принудительное обновление политик:
gpupdate /force