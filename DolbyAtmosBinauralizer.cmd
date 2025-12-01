@Echo OFF
SETlocal EnableExtensions
SETlocal EnableDelayedExpansion
Set ALSOFT_LOGFILE=OpenAL.log
Set ALSOFT_LOGLEVEL=3
pushd "%~dp0"

:Begin
cls
Call :Print Dolby Atmos Binauralizer
Call :Print Script to spatialize Dolby Atmos tracks, using OpenAL Soft HRTF
Call :Print Version 1.1.1

If not exist "CavernizeGUI.exe" (
	Call :Print [91mCavernizeGUI.exe does not exist.[0m
	Call :Print [96mPress any key to check again after you've manually copied the files, and if not found, open the browser to download it and then extract it along with the other files into this folder...[0m
	Pause >Nul
	If not exist "CavernizeGUI.exe" (Start https://cavern.sbence.hu/cavern/downloading.php?get=cavernize_gui)
	)
If not exist "truehdd.exe" (
	If exist "%AppData%\Cavernize\truehdd\truehdd.exe" (
		Copy "%AppData%\Cavernize\truehdd\truehdd.exe" "%~dp0truehdd.exe" 1>NUL 2>&1
		) else (
		Set FileNotFound=True
		Call :Print [91mtruehdd.exe does not exist.[0m
		Call :Print [96mPress any key to check again after you've manually copied the files, and if not found, open the browser to download it ^(x86_64-pc-windows-msvc^) and then extract it into this folder...[0m
		Pause >Nul
		If not exist "truehdd.exe" (Start https://github.com/truehdd/truehdd/releases/latest)
		)
	)
If not exist "allafplay.exe" (
	Set FileNotFound=True
	Call :Print [91mallafplay.exe does not exist.[0m
	Call :Print [96mPress any key to check again after you've manually copied the files, and if not found, open the browser to download it and then extract it into this folder...[0m
	Pause >Nul
	If not exist "allafplay.exe" (Start https://github.com/kcat/openal-soft/releases/download/utils/utils.zip)
	)
If not exist "ffmpeg.exe" (
	Set FileNotFound=True
	Call :Print [91mffmpeg.exe does not exist.[0m
	Call :Print [96mPress any key to check again after you've manually copied the files, and if not found, open the browser to download it and then extract it into this folder...[0m
	Pause >Nul
	If not exist "ffmpeg.exe" (Start https://github.com/AnimMouse/ffmpeg-autobuild/releases/latest)
	)
If not exist "OpenAL32.dll" (
	Set FileNotFound=True
	Call :Print [93mOpenAL32.dll does not exist.[0m
	Call :Print [96mPress any key to check again after you've manually copied the files, and if not found, open the browser to download it ^(Win64^) and then extract it into this folder...[0m
	Pause >Nul
	If not exist "OpenAL32.dll" (Start https://github.com/kcat/openal-soft/releases/download/latest/OpenALSoft+HRTF.zip)
	)
If not exist "alsoft.ini" (
	Set FileNotFound=True
	Call :Print [93malsoft.ini does not exist.[0m
	Call :Print [96mPress any key to check again after you've manually copied the files, and if not found, open the browser to download it and then extract it into this folder...[0m
	Pause >Nul
	If not exist "alsoft.ini" (Start https://github.com/kcat/openal-soft/releases/download/latest/OpenALSoft+HRTF.zip)
	)
If "!FileNotFound!"=="True" (
	Set FileNotFound=
	GoTo :Begin
	)

If "%1"=="" (
	set /p Input=[96mDrag one or more files into this script file directly or into this window, then press Enter:[0m 
	For %%I in (!Input!) do (
		IF EXIST "%%~I" (
			If /I "%%~xI"==".laf" (
				Call :Play "%%~I"
				) else (
				Call :Decode "%%~I"
				)
			)
		)
	) else (
	for %%I in (%*) do (
		IF EXIST "%%~I" (
			If /I "%%~xI"==".laf" (
				Call :Play "%%~I"
				) else (
				Call :Decode "%%~I"
				)
			)
		)
	)
	
Call :Print All tasks have been completed. Press any key to exit.
Pause >Nul
Exit

:Decode
Echo.
Call :Print [7m"%~1"[0m
MkDir "%AppData%\Cavernize\truehdd\" 1>NUL 2>&1
If not exist "%AppData%/Cavernize/truehdd.version" (
	Call :Print "" >"%AppData%/Cavernize/truehdd.version"
	)
If not exist "%AppData%\Cavernize\truehdd\truehdd.exe" (
	If exist "truehdd.exe" (
		Copy "truehdd.exe" "%AppData%\Cavernize\truehdd\truehdd.exe" 1>NUL 2>&1
		)
	)
For %%L in ("%~1") do (
	Call :PrintLogRun CavernizeGUI.exe -input "%%~L" -format LimitlessAudio -output "%%~dpL%%~nL.laf"
	If not exist "%%~dpL%%~nL.laf" (
		Call :Print [93mFailed to generate "%%~dpL%%~nL.laf". Trying alternative method...[0m
		Call :PrintLogRun ffmpeg.exe -y -i "%%~L" -c copy -f truehd "%%~dpL%%~nL.input"
		Call :PrintLogRun truehdd.exe decode --progress "%%~dpL%%~nL.input" --output-path "%%~dpL%%~nL"
		If exist "%%~dpL%%~nL.input" (Del "%%~dpL%%~nL.input" 1>NUL 2>&1)
		Call :PrintLogRun CavernizeGUI.exe -input "%%~dpL%%~nL.atmos" -format LimitlessAudio -output "%%~dpL%%~nL.laf"
		If exist "%%~dpL%%~nL.atmos" (Del "%%~dpL%%~nL.atmos" 1>NUL 2>&1)
		If exist "%%~dpL%%~nL.atmos.audio" (Del "%%~dpL%%~nL.atmos.audio" 1>NUL 2>&1)
		If exist "%%~dpL%%~nL.atmos.metadata" (Del "%%~dpL%%~nL.atmos.metadata" 1>NUL 2>&1)
		)
	Call :PrintLogRun allafplay.exe -render "hrtf,f32" "%%~dpL%%~nL.laf"
	If exist "%%~dpL%%~nL.laf" (Del "%%~dpL%%~nL.laf" 1>NUL 2>&1)
	If exist "%%~nL.caf" (Move "%%~nL.caf" "%%~dpL%%~nL.caf" 1>NUL 2>&1)
	Call :PrintLogRun ffmpeg.exe -y -i "%%~dpL%%~nL.caf" -c:a flac -compression_level 12 -strict -2 "%%~dpL%%~nL.flac"
	If exist "%%~dpL%%~nL.caf" (Del "%%~dpL%%~nL.caf" 1>NUL 2>&1)
	Call :Print [0m
	If exist "%%~dpL%%~nL.flac" (
		Call :Print [92m"%%~dpL%%~nL.flac" has been generated.[0m
		Call :Print [96mYou can now load it as an external track in supported media players.[0m
		) else (
		Call :Print [91mFailed to generate "%%~dpL%%~nL.flac".[0m
		)
	)
Exit /B

:Play
For %%L in ("%~1") do (
	If exist "%%~dpL%%~nL.laf" (Call :PrintLogRun allafplay.exe "%%~dpL%%~nL.laf")
	)
Exit /B

:Print
Echo %*
Exit /B

:PrintLogRun
Echo [94m%*[0m
Echo %*>>Log.txt
%*
Exit /B