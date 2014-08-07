selenium_node_setup_windows
===========================
```cmd
powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/TaylorMonacelli/selenium_node_setup_windows/master/setup.ps1'))"
```
This will

1. download IE and chrome drivers to %sytemdrive%\Selenium
2. dowload selenium-server-standalone...jar to current directory
3. create jar_x86.cmd and jar_x64.cmd scripts to make it easy to run node
