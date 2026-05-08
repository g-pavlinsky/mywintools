Реестр не управляет Планировщиком задач. Выполните в PowerShell (Администратор):

Отключение задач: powershell

$tasks = @(
  "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance",
  "Microsoft\Windows\Windows Defender\Windows Defender Cleanup",
  "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan",
  "Microsoft\Windows\Windows Defender\Windows Defender Verification"
)
foreach ($t in $tasks) { Disable-ScheduledTask -TaskName $t -ErrorAction SilentlyContinue }

Включение задач (для отката): powershell

foreach ($t in $tasks) { Enable-ScheduledTask -TaskName $t -ErrorAction SilentlyContinue }