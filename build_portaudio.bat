SETLOCAL
echo ---- Building Portaudio ----
set PORTAUDIO_PATH=pa_stable_v190600_20161030
set VALRETURN=0

if %MACHINE_X86% (
  set CMAKE_GENERATOR="Visual Studio 14 2015"
  set LIB_SUFFIX=x86
) else (
  set CMAKE_GENERATOR="Visual Studio 14 2015 Win64"
  set LIB_SUFFIX=x64
)

if %CONFIG_RELEASE% (
  set CONFIG=Release
) else (
  set CONFIG=Debug
)

if %STATIC_LIBS% (
  set MSVC_TARGET=portaudio_static
) else (
  set MSVC_TARGET=portaudio
)

REM delete solution files
cd build\%PORTAUDIO_PATH%\build
rd /S /Q cmake
mkdir cmake
cd cmake

REM generate solution
"%CMAKEDIR%\cmake" ..\..\ -G %CMAKE_GENERATOR% -DCMAKE_BUILD_TYPE=%CONFIG% -DPA_USE_ASIO=ON
IF ERRORLEVEL 1 (
    set VALRETURN=1
	goto END
)

%MSBUILD% portaudio.sln /p:Configuration=%CONFIG% /p:Platform=%PLATFORM% /t:Portaudio\%MSVC_TARGET%:Clean;Portaudio\%MSVC_TARGET%:Rebuild
IF ERRORLEVEL 1 (
    set VALRETURN=1
	goto END
)

copy ..\..\include\portaudio.h %INCLUDE_DIR%

if %STATIC_LIBS% (
  copy %CONFIG%\portaudio_static_%LIB_SUFFIX%.lib %LIB_DIR%
) else (
  copy %CONFIG%\portaudio_%LIB_SUFFIX%.exp %LIB_DIR%
  copy %CONFIG%\portaudio_%LIB_SUFFIX%.lib %LIB_DIR%
  copy %CONFIG%\portaudio_%LIB_SUFFIX%.dll %LIB_DIR%
)

:END
cd %ROOT_DIR%
REM the GOTO command resets the errorlevel and the endlocal resets the local environment,
REM so I have to use this workaround
ENDLOCAL & SET VALRETURN=%VALRETURN%
exit /b %VALRETURN%
