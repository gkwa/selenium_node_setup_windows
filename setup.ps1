$ErrorActionPreference = 'stop'
$WarningPreference = 'stop'

$relFile='CHROME_LATEST_RELEASE'
$cdir = (Get-Location).Path
$relFileAbsPath = $cdir + "\" + "$relFile"

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

$installDir = "${env:ProgramFiles(x86)}\Google ChromeDriver"
if([IntPtr]::Size -eq 4) #32bit windows
{
    $installDir = "${env:ProgramFiles}\Google ChromeDriver"
}

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