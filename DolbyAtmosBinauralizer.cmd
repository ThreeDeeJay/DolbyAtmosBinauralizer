@echo off
Set ALSOFT_LOGFILE=OpenAL.log
Set ALSOFT_LOGLEVEL=3
pushd "%~dp0"


Echo Dolby Atmos Binauralizer
Echo Script to spatialize Dolby Atmos tracks, using OpenAL Soft HRTF

IF NOT "%~1"=="" (
	IF EXIST "%~1" (
		Call :Decode "%~1"
		Call :Complete "%~1"
	)
) else (
if exist *.laf (
	for %%L in (*.laf) do (
		Call :Decode "%~1"
		Call :Complete "%~1"
		)
	)
)
Pause

:Decode
For %%L in ("%~1") do (
	If not exist "%%~dpL%%~nL.atmos"	(ffmpeg -i "%%~L" -c copy -f truehd - | truehdd decode --progress - --output-path "%%~dpL%%~nL")
	If not exist "%%~dpL%%~nL.laf"		(CavernizeGUI.exe -input "%%~dpL%%~nL.atmos" -format LimitlessAudio -output "%%~dpL%%~nL.laf")
	If not exist "%%~dpL%%~nL.caf"		(allafplay.exe -render "hrtf,f32" "%%~dpL%%~nL.laf")
	If exist "%%~nL.caf"				(move "%%~nL.caf" "%%~dpL%%~nL.caf")
	If not exist "%%~dpL%%~nL.flac"		(ffmpeg.exe -i "%%~dpL%%~nL.caf" -c:a flac -compression_level 12 -strict -2 "%%~dpL%%~nL.flac")
	Echo Conversion complete.
	)

:Complete
Echo Press any key to play the file or just close this window if you're planning to load it as an external track in a media player.
Pause >Nul
For %%L in ("%~1") do (
	If exist "%%~dpL%%~nL.laf"			(allafplay.exe "%%~dpL%%~nL.laf")
	)
GoTo :Complete