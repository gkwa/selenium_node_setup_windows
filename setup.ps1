# http://selenium-release.storage.googleapis.com/index.html

$ErrorActionPreference = 'stop'
$WarningPreference = 'stop'

$relFile='CHROME_LATEST_RELEASE'
$cdir = (Get-Location).Path
$relFileAbsPath = $cdir + "\" + "$relFile"
$systemdrive="${env:systemdrive}"

$driverZip = "chromedriver_win32.zip"

if(!(test-path "$cdir\7za.exe"))
{
    (new-object System.Net.WebClient).DownloadFile("http://installer-bin.streambox.com/7za.exe", "7za.exe")
}

if(!(test-path "$relFileAbsPath"))
{
    (new-object System.Net.WebClient).DownloadFile('http://chromedriver.storage.googleapis.com/LATEST_RELEASE','CHROME_LATEST_RELEASE')
}

$chromeDriverVersion = gc $relFile

$zipURL = "http://chromedriver.storage.googleapis.com/$chromeDriverVersion/$driverZip"

if(!(test-path "$cdir\$driverZip"))
{
    Write-Host "Fetching $zipURL..."
    (new-object System.Net.WebClient).DownloadFile($zipURL,$driverZip)
}

& '.\7za.exe' x -y $driverZip >7za_out.txt
Remove-Item 7za_out.txt

$installDir = "$systemdrive\Selenium\ChromeDriver"

if(!(test-path "$installDir"))
{
    $result = new-item -Path "$installDir" -ItemType Directory
}

Copy "$cdir\chromedriver.exe" "$installDir"

if(test-path "$installDir\chromedriver.exe")
{
    Write-Host "Deployed $installDir\chromedriver.exe"
}else{
    Write-Error "Failed to deploy to $installDir\chromedriver.exe"
}

# ----------------------------------------------------------------------------------------------------
# IE 32bit
# ----------------------------------------------------------------------------------------------------

# IEDriverServer_Win32_2.42.0.zip
$ieVersion='2.42.0'
$ieVersionDir='2.42'
$ieDriverZipBasename="IEDriverServer_Win32_${ieVersion}"
$ieDriverZip="$ieDriverZipBasename.zip"

$zipUrl = "http://selenium-release.storage.googleapis.com/$ieVersionDir/$ieDriverZip"

if(!(test-path "$cdir\$ieDriverZip"))
{
    Write-Host "Fetching $zipUrl"
    (new-object System.Net.WebClient).DownloadFile("$zipUrl", "$ieDriverZip")
}

& '.\7za.exe' x -y $ieDriverZip >"$ieDriverZip.log"
Remove-Item "$ieDriverZip.log"

$installDir = "$systemdrive\Selenium\IEDriver\x86"

if(!(test-path "$installDir"))
{
    $result = new-item -Path "$installDir" -ItemType Directory
}

Copy "$cdir\IEDriverServer.exe" "$installDir"

if(test-path "$installDir\IEDriverServer.exe")
{
    Write-Host "Deployed $installDir\IEDriverServer.exe"
}else{
    Write-Error "Failed to deploy to $installDir\IEDriverServer.exe"
}

# ----------------------------------------------------------------------------------------------------
# IE 64bit
# ----------------------------------------------------------------------------------------------------

# IEDriverServer_x64_2.42.0.zip
$ieVersion='2.42.0'
$ieVersionDir='2.42'
$ieDriverZipBasename="IEDriverServer_x64_${ieVersion}"
$ieDriverZip="$ieDriverZipBasename.zip"

$zipUrl = "http://selenium-release.storage.googleapis.com/$ieVersionDir/$ieDriverZip"

if(!(test-path "$cdir\$ieDriverZip"))
{
    Write-Host "Fetching $zipUrl"
    (new-object System.Net.WebClient).DownloadFile("$zipUrl", "$ieDriverZip")
}

& '.\7za.exe' x -y $ieDriverZip >"$ieDriverZip.log"
Remove-Item "$ieDriverZip.log"

$installDir = "$systemdrive\Selenium\IEDriver\x64"

if(!(test-path "$installDir"))
{
    $result = new-item -Path "$installDir" -ItemType Directory
}

Copy "$cdir\IEDriverServer.exe" "$installDir"

if(test-path "$installDir\IEDriverServer.exe")
{
    Write-Host "Deployed $installDir\IEDriverServer.exe"
}else{
    Write-Error "Failed to deploy to $installDir\IEDriverServer.exe"
}
