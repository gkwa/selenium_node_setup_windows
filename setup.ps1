# http://selenium-release.storage.googleapis.com/index.html
# https://code.google.com/p/selenium/wiki/Grid2
# https://code.google.com/p/selenium/downloads/list
# http://selenium-release.storage.googleapis.com/index.html

$ErrorActionPreference = 'stop'
$WarningPreference = 'stop'


cinst --yes 7zip.commandline

try {
    Import-Module Pscx
} catch {
	& cinst --yes pscx
}

function killprocess {
    Param([string]$processname)

    try{
        While($true) {
            $running = Get-Process $processname
            if($running) {
                Stop-Process -processname $processname
                sleep -m 4000; #give extra time for process to die
                break
            }
            sleep -m 500
        }
    }catch{
    }
}

killprocess java

$relFile='CHROME_LATEST_RELEASE'
$cdir = (Get-Location).Path
$relFileAbsPath = $cdir + "\" + "$relFile"
$systemdrive="${env:systemdrive}"

$driverZip = "chromedriver_win32.zip"

if(!(test-path "$relFileAbsPath")) {
    Invoke-WebRequest -Uri http://chromedriver.storage.googleapis.com/LATEST_RELEASE -OutFile CHROME_LATEST_RELEASE
}

$chromeDriverVersion = gc $relFile

$zipURL = "http://chromedriver.storage.googleapis.com/$chromeDriverVersion/$driverZip"

if(!(test-path "$cdir\$driverZip")) {
    Write-Host "Fetching $zipURL..."
    Invoke-WebRequest -Uri $zipURL -OutFile $driverZip
}

&cmd /c 7z x -y $driverZip >7z_out.txt
Remove-Item 7z_out.txt

$installDir = "$systemdrive\Selenium\ChromeDriver"

if(!(test-path "$installDir")) {
    $result = new-item -Path "$installDir" -ItemType Directory
}

killprocess chromedriver

Copy "$cdir\chromedriver.exe" "$installDir"

Add-PathVariable -Target User -Name Path -Value $installDir

if(test-path "$installDir\chromedriver.exe") {
    Write-Host "Deployed $installDir\chromedriver.exe"
} else {
    Write-Error "Failed to deploy to $installDir\chromedriver.exe"
}

# ----------------------------------------------------------------------------------------------------
# IE 32bit
# ----------------------------------------------------------------------------------------------------


# IEDriverServer_Win32_3.5.1.zip
$ieVersion='3.5.1'
$ieVersionDir='3.5'
$ieDriverZipBasename="IEDriverServer_Win32_${ieVersion}"
$ieDriverZip="$ieDriverZipBasename.zip"

$zipUrl = "http://selenium-release.storage.googleapis.com/$ieVersionDir/$ieDriverZip"

if(!(test-path "$cdir\$ieDriverZip")) {
    Write-Host "Fetching $zipUrl"
    Invoke-WebRequest -Uri $zipURL -OutFile $ieDriverZip
}

&cmd /c 7z x -y $ieDriverZip >"$ieDriverZip.log"
Remove-Item "$ieDriverZip.log"

$installDir = "$systemdrive\Selenium\IEDriver\x86"

if(!(test-path "$installDir")) {
    $result = new-item -Path "$installDir" -ItemType Directory
}

killprocess IEDriverServer

Copy "$cdir\IEDriverServer.exe" "$installDir"

if(test-path "$installDir\IEDriverServer.exe") {
    Write-Host "Deployed $installDir\IEDriverServer.exe"
}else{
    Write-Error "Failed to deploy to $installDir\IEDriverServer.exe"
}

# ----------------------------------------------------------------------------------------------------
# IE 64bit
# ----------------------------------------------------------------------------------------------------

# IEDriverServer_x64_3.5.1.zip
$ieVersion='3.5.1'
$ieVersionDir='3.5'
$ieDriverZipBasename="IEDriverServer_x64_${ieVersion}"
$ieDriverZip="$ieDriverZipBasename.zip"

$zipUrl = "http://selenium-release.storage.googleapis.com/$ieVersionDir/$ieDriverZip"

if(!(test-path "$cdir\$ieDriverZip")) {
    Write-Host "Fetching $zipUrl"
    Invoke-WebRequest -Uri $zipURL -OutFile $ieDriverZip
}

&cmd /c 7z x -y $ieDriverZip >"$ieDriverZip.log"
Remove-Item "$ieDriverZip.log"

$installDir = "$systemdrive\Selenium\IEDriver\x64"

if(!(test-path "$installDir")) {
    $result = new-item -Path "$installDir" -ItemType Directory
}

killprocess IEDriverServer

Copy "$cdir\IEDriverServer.exe" "$installDir"

if(test-path "$installDir\IEDriverServer.exe") {
    Write-Host "Deployed $installDir\IEDriverServer.exe"
}else{
    Write-Error "Failed to deploy to $installDir\IEDriverServer.exe"
}

# ----------------------------------------------------------------------------------------------------
# Registry key update: FEATURE_BFCACHE
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

#32bit windows
if([IntPtr]::Size -eq 4) {
    $p = 'hklm:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BFCACHE'
    if(!(test-path "$p")) {
        $result = new-item "$p" -force
    }

    $result = new-itemproperty "$p" -name "iexplore.exe" -value 0 -propertytype DWord -force

} else {
    #64bit windows

    $p = "hklm:\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BFCACHE"
    if(!(test-path "$p")) {
        $result = new-item "$p" -force
    }

    $result = new-itemproperty "$p" -name "iexplore.exe" -value 0 -propertytype DWord -force
}

# ----------------------------------------------------------------------------------------------------
# Selenium jar download
# ----------------------------------------------------------------------------------------------------
$version   ='3.5.3'
$versionDir='3.5'
$jarBasename="selenium-server-standalone-$version"
$jarFilename="$jarBasename.jar"
$jarUrl="http://selenium-release.storage.googleapis.com/$versionDir/$jarFilename"

if(!(test-path "$jarFilename")) {
    Write-Host "Fetching $jarUrl"
    Invoke-WebRequest -Uri $jarUrl -OutFile $jarFilename
}

# ----------------------------------------------------------------------------------------------------
# Write batch file to start jar
# ----------------------------------------------------------------------------------------------------

@"
taskkill /F /IM java.exe 2>NUL

java ^
-Dwebdriver.ie.driver="$systemdrive/Selenium/IEDriver/x86/IEDriverServer.exe" ^
-Dwebdriver.chrome.driver="$systemdrive/Selenium/ChromeDriver/chromedriver.exe" ^
-jar selenium-server-standalone-$version.jar ^
-browser browserName=safari,maxInstances=5,platform=WINDOWS ^
-browser browserName=firefox,maxInstances=5,platform=WINDOWS ^
-browser "browserName=internet explorer,maxInstances=5,platform=WINDOWS" ^
-browser browserName=chrome,maxInstances=5,platform=WINDOWS ^
-role node ^
-port 5555 ^
-host node1.streambox.com ^
-hub http://selenium-hub1.streambox.com:4444/grid/register
"@	| Out-File -encoding 'ASCII' "jar_x86.cmd"

@"
taskkill /F /IM java.exe 2>NUL

java ^
-Dwebdriver.ie.driver="$systemdrive/Selenium/IEDriver/x64/IEDriverServer.exe" ^
-Dwebdriver.chrome.driver="$systemdrive/Selenium/ChromeDriver/chromedriver.exe" ^
-jar selenium-server-standalone-$version.jar ^
-browser browserName=safari,maxInstances=5,platform=WINDOWS ^
-browser browserName=firefox,maxInstances=5,platform=WINDOWS ^
-browser "browserName=internet explorer,maxInstances=5,platform=WINDOWS" ^
-browser browserName=chrome,maxInstances=5,platform=WINDOWS ^
-role node ^
-port 5555 ^
-host node1.streambox.com ^
-hub http://selenium-hub1.streambox.com:4444/grid/register
"@	| Out-File -encoding 'ASCII' "jar_x64.cmd"

@"
taskkill /F /IM chrome.exe 2>NUL
taskkill /F /IM chromedriver.exe 2>NUL
taskkill /F /IM firefox.exe 2>NUL
taskkill /F /IM iedriverserver.exe 2>NUL
taskkill /F /IM java.exe 2>NUL
taskkill /F /IM opera.exe 2>NUL
taskkill /F /IM safari.exe 2>NUL

"@	| Out-File -encoding 'ASCII' "k.cmd"
