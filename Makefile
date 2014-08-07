t:
	cmd /c setup.cmd

clean:
	rm -f chromedriver_win32.zip
	rm -f chromedriver.exe
	rm -f IEDriverServer.exe
	rm -f IEDriverServer_Win32_*.zip
	rm -f IEDriverServer_x64_*.zip
	rm -f CHROME_LATEST_RELEASE
	rm -f LATEST_RELEASE
	rm -f jar_x64.cmd
	rm -f jar_x86.cmd
