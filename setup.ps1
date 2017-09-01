# http://selenium-release.storage.googleapis.com/index.html
# https://code.google.com/p/selenium/wiki/Grid2
# https://code.google.com/p/selenium/downloads/list
# http://selenium-release.storage.googleapis.com/index.html

$ErrorActionPreference = 'stop'
$WarningPreference = 'stop'

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
cinst --yes jdk8

killprocess chrome
killprocess chromedriver
cinst --yes GoogleChrome
cinst --yes selenium-chrome-driver

killprocess geckodriver
killprocess firefox
cinst --yes Firefox
cinst --yes selenium-gecko-driver

killprocess opera
killprocess operadriver
cinst --yes opera
cinst --yes selenium-opera-driver

killprocess iedriverserver
cinst --yes selenium-ie-driver

killprocess MicrosoftWebDriver
cinst --yes selenium-edge-driver

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
-Dwebdriver.ie.driver="$env:systemdrive/tools/selenium/IEDriverServer.exe" ^
-Dwebdriver.chrome.driver="$env:systemdrive/tools/selenium/chromedriver.exe" ^
-Dwebdriver.gecko.driver="$env:systemdrive/tools/selenium/geckodriver.exe" ^
-Dwebdriver.opera.driver="$env:systemdrive/tools/selenium/operadriver.exe" ^
-Dwebdriver.edge.driver="$env:systemdrive/tools/selenium/MicrosoftWebDriver.exe" ^
-jar selenium-server-standalone-$version.jar ^
-browser browserName=safari,maxInstances=5,platform=WINDOWS ^
-browser browserName=firefox,maxInstances=5,platform=WINDOWS ^
-browser "browserName=internet explorer,maxInstances=5,platform=WINDOWS" ^
-browser browserName=chrome,maxInstances=5,platform=WINDOWS ^
-role node ^
-port 5555 ^
-host selenium-node1.streambox.com ^
-hub http://selenium-hub1.streambox.com:4444/grid/register
"@	| Out-File -encoding 'ASCII' "jar_x86.cmd"

@"
taskkill /F /IM java.exe 2>NUL

java ^
-Dwebdriver.ie.driver="$env:systemdrive/tools/selenium/IEDriverServer.exe" ^
-Dwebdriver.chrome.driver="$env:systemdrive/tools/selenium/chromedriver.exe" ^
-Dwebdriver.gecko.driver="$env:systemdrive/tools/selenium/geckodriver.exe" ^
-Dwebdriver.opera.driver="$env:systemdrive/tools/selenium/operadriver.exe" ^
-Dwebdriver.edge.driver="$env:systemdrive/tools/selenium/MicrosoftWebDriver.exe" ^
-jar selenium-server-standalone-$version.jar ^
-browser browserName=safari,maxInstances=5,platform=WINDOWS ^
-browser browserName=firefox,maxInstances=5,platform=WINDOWS ^
-browser "browserName=internet explorer,maxInstances=5,platform=WINDOWS" ^
-browser browserName=chrome,maxInstances=5,platform=WINDOWS ^
-role node ^
-port 5555 ^
-host selenium-node1.streambox.com ^
-hub http://selenium-hub1.streambox.com:4444/grid/register
"@	| Out-File -encoding 'ASCII' "jar_x64.cmd"

@"
taskkill /F /IM operadriver.exe 2>NUL
taskkill /F /IM geckodriver.exe 2>NUL
taskkill /F /IM IEDriverServer.exe 2>NUL
taskkill /F /IM MicrosoftWebDriver.exe 2>NUL
taskkill /F /IM chrome.exe 2>NUL
taskkill /F /IM chromedriver.exe 2>NUL
taskkill /F /IM firefox.exe 2>NUL
taskkill /F /IM iedriverserver.exe 2>NUL
taskkill /F /IM java.exe 2>NUL
taskkill /F /IM opera.exe 2>NUL
taskkill /F /IM safari.exe 2>NUL
"@	| Out-File -encoding 'ASCII' "k.cmd"
