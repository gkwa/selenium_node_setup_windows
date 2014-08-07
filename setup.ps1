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

<#

https://code.google.com/p/selenium/wiki/InternetExplorerDriver

For IE 11 only, you will need to set a registry entry on the target
computer so that the driver can maintain a connection to the instance of
Internet Explorer it creates. For 32-bit Windows installations, the key
you must examine in the registry editor is
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet
Explorer\Main\FeatureControl\FEATURE_BFCACHE. For 64-bit Windows
installations, the key is
HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Internet
Explorer\Main\FeatureControl\FEATURE_BFCACHE. Please note that the
FEATURE_BFCACHE subkey may or may not be present, and should be created
if it is not present. Important: Inside this key, create a DWORD value
named iexplore.exe with the value of 0.
#>

if([IntPtr]::Size -eq 4) #32bit windows
{
    $result = new-itemproperty "hklm:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BFCACHE" `
      -name "iexplore.exe" -value 0 -propertytype DWord -force

}

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

<#

https://code.google.com/p/selenium/wiki/InternetExplorerDriver

For IE 11 only, you will need to set a registry entry on the target
computer so that the driver can maintain a connection to the instance of
Internet Explorer it creates. For 32-bit Windows installations, the key
you must examine in the registry editor is
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet
Explorer\Main\FeatureControl\FEATURE_BFCACHE. For 64-bit Windows
installations, the key is
HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Internet
Explorer\Main\FeatureControl\FEATURE_BFCACHE. Please note that the
FEATURE_BFCACHE subkey may or may not be present, and should be created
if it is not present. Important: Inside this key, create a DWORD value
named iexplore.exe with the value of 0.
#>

if(!([IntPtr]::Size -eq 4)) #64bit windows
{
    $result = new-itemproperty "hklm:\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BFCACHE" `
      -name "iexplore.exe" -value 0 -propertytype DWord -force
}




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
