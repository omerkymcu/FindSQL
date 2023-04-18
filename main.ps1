$ipStart = "10.208.43.1"   # Başlangıç IP adresi
$ipEnd = "10.208.43.254"    # Bitiş IP adresi
$outputFile = "sql_servers.csv"   # Çıktı dosyası adı

$results = @()

# IP aralığındaki tüm IP adreslerini oluştur
$ips = [System.Net.IPAddress]::Parse($ipStart).GetAddressBytes()..[System.Net.IPAddress]::Parse($ipEnd).GetAddressBytes() | 
    % {[System.Net.IPAddress] $_}

# Tüm IP adreslerini tara ve SQL Server var mı kontrol et
foreach ($ip in $ips) {
    Write-Host "Taranan IP: $ip"
    $sqlInstances = $null
    try {
        # SQL Server'ları tarayarak sürüm bilgisini al
        $sqlInstances = [System.Data.Sql.SqlDataSourceEnumerator]::Instance.GetDataSources()
        foreach ($sqlInstance in $sqlInstances) {
            $server = $sqlInstance.ServerName
            $instance = $sqlInstance.InstanceName
            $version = $sqlInstance.VersionString
            $results += [PSCustomObject]@{
                IP = $ip.ToString()
                ServerName = $server
                InstanceName = $instance
                Version = $version
            }
        }
    } catch {
        Write-Host "Hata: $_"
    }
}

# Sonuçları CSV dosyasına yaz
$results | Export-Csv -Path $outputFile -NoTypeInformation
Write-Host "Tamamlandı. Sonuçlar $outputFile dosyasına kaydedildi."
