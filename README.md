selenium_node_setup_windows
===========================
```cmd
powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/TaylorMonacelli/selenium_node_setup_windows/master/setup.ps1'))"
```
This will

1. download IE and chrome drivers to %sytemdrive%\Selenium
2. set registry entries for IE recommended here: https://github.com/beatfactor/nightwatch/wiki/Internet-Explorer-Setup
3. dowload selenium-server-standalone...jar to current directory
4. create jar_x86.cmd and jar_x64.cmd scripts to make it easy to run node

More capability settings:

1. IE https://code.google.com/p/selenium/wiki/DesiredCapabilities#IE_specific
