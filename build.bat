:: setup
@echo off
setlocal enabledelayedexpansion

:: alert
call:alert "Building..."

:: setting the output names
set OUTPUT=       bin\PETITE-8
set OUTPUT_MIO=   %OUTPUT%.exe
set OUTPUT_MIO_C= %OUTPUT%-C.exe

:: optimization parameters
set SIZE_OPTIMIZATION= ^
	-Os -flto=%NUMBER_OF_PROCESSORS% -fdata-sections -ffunction-sections ^
	-fno-unwind-tables -fno-asynchronous-unwind-tables^
	-Wl,--strip-all -Wl,--as-needed -Wl,--exclude-libs=ALL -Wl,--gc-sections -Wl,--build-id=none ^
	-fipa-sra -fipa-pta -fdevirtualize -fdevirtualize-speculatively -fvisibility=hidden ^
	-fno-math-errno -funsafe-math-optimizations -ffinite-math-only -fno-trapping-math -fno-signaling-nans -fno-rounding-math ^
	-fuse-linker-plugin -fno-ident -fno-stack-protector -fomit-frame-pointer -fno-plt -Wl,--no-insert-timestamp

:: static linking libraries
set STATIC_LINKING= ^
	-Wl,--dynamicbase -Wl,--nxcompat -Wl,--high-entropy-va -static ^
	-lm -ldinput8 -ldxguid -ldxerr8 -luser32 -lmingw32 -ladvapi32 -lws2_32 ^
	-lgdi32 -lwinmm -limm32 -lole32 -loleaut32 -lkernel32 -lcomctl32 -lcomdlg32 ^
	-lshell32 -lsetupapi -lversion -luuid

:: other parameters
set OTHER= -std=c17 -mwindows

:: cleaning directory
del /q %OUTPUT_MIO%
del /q %OUTPUT_MIO_C%
mkdir bin

:: building the resources
windres res/resources.rc -o res/resources.res -O coff

:: building
gcc src/*.c res/resources.res -o %OUTPUT_MIO% %SIZE_OPTIMIZATION% %STATIC_LINKING% %OTHER%

:: if error occured
if %errorlevel% neq 0 (
	call:error "Failed!"
)

:: compressing with upx disable for faster compilation, or for disabling antivirus fake triggers
upx %OUTPUT_MIO% -o %OUTPUT_MIO_C% --best --ultra-brute --lzma --all-methods --overlay=strip --compress-exports=1 --compress-icons=2 --compress-resources=1

:: if error occured
if %errorlevel% neq 0 (
	call:error "Failed!"
)

:: success
call:success "Done!"

:: running
@REM call:alert "Starting project..."
@REM start %OUTPUT_MIO% /i

:: FUNCTIONS

:: info
:alert
	powershell Write-Host -ForegroundColor Blue %1
goto :eof

:: on error
:error
	powershell Write-Host -ForegroundColor Red %1
	( )
goto :eof

:: if everything ok
:success
	powershell Write-Host -ForegroundColor Green %1
goto :eof