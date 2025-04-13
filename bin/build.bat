@:: setup
@echo off

:: initial output
call:alert "PETITE-8 - Build Script"

:: all parameters
set SRC=
set SRC_NAME=
set OUT=
set RUN=0
set EXE=PETITE-8.exe

:: parameters loop
:loop
  :: are there any parameters
  if "%~1"=="" goto done
  
  :: if output passed
  if "%~1"=="-o" (
    set OUT=%2
    shift
    shift
    goto loop
  )
  
  :: use compressed mio version
  if "%~1"=="-emioc" (
    set "EXE=PETITE-8-MIO-C.exe"
    shift
    goto loop
  )

  :: use non-compressed mio version default
  if "%~1"=="-emio" (
    set "EXE=PETITE-8-MIO.exe"
    shift
    goto loop
  )

  :: run after build
  if "%~1"=="-r" (
    set RUN=1
    shift
    goto loop
  )
  
  :: or source
  set SRC=%~1
  set SRC_NAME=%~n1
  shift
  goto loop
:done

:: if source not passed
if "%SRC%"=="" (
  call:error "Source not passed!"
  call:alert "Defaulting to game.pb"
  set SRC=game.pb
  set SRC_NAME=game
)

call:alert "Output: %OUT%"
:: if output not passed
if "%OUT%"=="" (
  set OUT=%SRC_NAME%.exe
)

:: is source found
call:alert "Source: %SRC%"
if not exist %SRC% (
  call:error "Source not found!"
  goto :eof
)
call:success "Source found!"

:: the actual building
call:alert "EXE: %EXE%"
call:alert "Building..."
( copy /b /y %EXE% + %SRC% %OUT% ) > nul
call:success "Done!"

:: if run after build
if "%RUN%"=="1" (
  call:alert "Starting project..."
  start %SRC_NAME%.exe /i
)

:: info
:alert
  powershell Write-Host -ForegroundColor Blue %1
goto :eof

:: on error
:error
  powershell Write-Host -ForegroundColor Red %1
goto :eof

:: if everything ok
:success
  powershell Write-Host -ForegroundColor Green %1
goto :eof