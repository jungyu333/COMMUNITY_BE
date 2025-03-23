$port = 8000
$conn = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue | Select-Object -First 1

if ($conn -ne $null) {
    $targetPid = $conn.OwningProcess
    try {
        Stop-Process -Id $targetPid -Force -ErrorAction Stop
        Write-Host "Process on port $port (PID: $targetPid) killed."
    } catch {
        Write-Host "Failed to kill process (PID: $targetPid): $($_.Exception.Message)"
    }
} else {
    Write-Host "No process found on port $port."
}
