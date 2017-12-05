SETLOCAL
echo ---- Building protobuf ----
set PROTOBUF_PATH=protobuf-2.6.1
SET VALRETURN=0

if %MACHINE_X86% (
  set PLATFORM=Win32
) else (
  set PLATFORM=x64
)

if %CONFIG_RELEASE% (
  set CONFIG=Release
) else (
  set CONFIG=Debug
)

cd build\%PROTOBUF_PATH%\vsprojects

if %STATIC_LIBS% (
  set MSVC_TARGET=libprotobuf-lite
  set SOLUTION=protobuf.sln
) else (
  set MSVC_TARGET=libprotobuf-lite-dynamic
  set SOLUTION=protobuf-patched.sln
  REM create vc project to produce the dynamic version of libprotobuf-lite and
  REM add it to a new protobuf-patched.sln solution
  %BIN_DIR%\patch.exe libprotobuf-lite.vcxproj convert_libprotobuf-lite_to_dynamic.patch -o libprotobuf-lite-dynamic.vcxproj
  %BIN_DIR%\patch.exe protobuf.sln add_libprotobuf-lite-dynamic_to_solution.patch -o protobuf-patched.sln
)

%MSBUILD% %SOLUTION% /p:Configuration=%CONFIG% /p:Platform=%PLATFORM% /t:%MSVC_TARGET%:Clean;%MSVC_TARGET%:Rebuild
IF ERRORLEVEL 1 (
    SET VALRETURN=1
	goto END
)

if NOT %STATIC_LIBS% ( copy %PLATFORM%\%CONFIG%\libprotobuf-lite.dll %LIB_DIR% )
copy %PLATFORM%\%CONFIG%\libprotobuf-lite.lib %LIB_DIR%
copy %PLATFORM%\%CONFIG%\libprotobuf-lite.pdb %LIB_DIR%
call extract_includes.bat
xcopy /E /Y include %INCLUDE_DIR%

:END
cd %ROOT_DIR%
REM the GOTO command resets the errorlevel and the endlocal resets the local environment,
REM so I have to use this workaround
ENDLOCAL & SET VALRETURN=%VALRETURN%
exit /b %VALRETURN%
