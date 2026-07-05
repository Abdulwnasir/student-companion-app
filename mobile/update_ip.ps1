# update_ip.ps1
$ip = "192.168.137.16"
$envFile = "C:\Users\fayek\AndroidStudioProjects\student-companion-full\mobile\.env"

Write-Host "Current IP: $ip" -ForegroundColor Green

# Update .env file
(Get-Content $envFile) -replace 'http://[\d\.]+:3000', "http://$ip`:3000" | Set-Content $envFile

# Update Flutter files
Get-ChildItem -Path "C:\Users\fayek\AndroidStudioProjects\student-companion-full\mobile\lib" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match '192\.168\.\d+\.\d+') {
        $content = $content -replace '192\.168\.\d+\.\d+', $ip
        $content | Set-Content $_.FullName -NoNewline
    }
}

Write-Host "✅ Updated to IP: $ip" -ForegroundColor Green
Write-Host "📱 Run 'flutter run' to test" -ForegroundColor Yellow