# initializing the paths
[string] $FOLDER   = "bin"
[string] $PATH     = "$FOLDER\PETITE-8"
[string] $OUTPUT   = "$PATH.exe"
[string] $OUTPUT_C = "$PATH-C.exe"

# properties
[bool] $COMPRESS      = $args -contains "-c"
[bool] $MAKE_MANIFEST = $args -contains "-m"
[bool] $NO_MANIFEST   = $args -contains "-d"
[bool] $START_EXE     = $args -contains "-r"
[bool] $USE_CONSOLE   = $args -contains "-sc"

# arguments for the executable
[string[]] $EXE_ARGS = @("-null")
for ($i = 0; $i -lt $Args.Length; $i++) {
  if ($Args[$i] -eq "-e") {
    $EXE_ARGS = $EXE_ARGS + $Args[$i + 1]
    Write-Host "Adding argument: $Args"
  }
}

# all arguments for size optimization
[string[]] $ARGUMENTS =
@(  
  # source files
  "src/*.c",
  "res/resources.res",

  # output file
  "-o", $OUTPUT

  # SIZE OPTIMIZATIONS
    # basic flag -3.5KB
    "-Oz",
    
    # linker flags
    "-Wl,-s",
    "-Wl,--as-needed",
    "-Wl,--exclude-libs=ALL",
    "-Wl,--gc-sections",
    
    # removing unwind tables
    "-fno-unwind-tables",
    "-fno-asynchronous-unwind-tables",
    
    # changing the entry point
    "-Wl,-epetite8",
    "-nostartfiles",

  # other
  "-static",
  "-std=c99",
  "-mwindows"
)

# retired flags:
# sections flags +1.5KB: "-fdata-sections", "-ffunction-sections", "-fdata-sections"
# other optimizations -0KB: # "-fmerge-all-constants"
# link-time optimization A LOT: "-flto=auto", "-fuse-linker-plugin"

# arguments for the resource file
[string[]] $RES_ARGS = @(
  "res\resources.rc",
  "-o", "res\resources.res",
  "-O", "coff"
)

# arguments list for upx
[string[]] $UPX_ARGS = @(
  $OUTPUT,
  "-o", $OUTPUT_C,
  "--best",
  "--ultra-brute",
  "--lzma",
  "--all-methods",
  "--overlay=strip"
)

# main function
function Main
{
  # appending the array because of arg
  if ($USE_CONSOLE) {
    # $ARGUMENTS = $ARGUMENTS + "-Wl,--subsystem,console"
  }

  # deleting the non-compressed exe
  if (Test-Path $OUTPUT) {
    Remove-Item $OUTPUT
    Alert "$OUTPUT deleted."
  }
  
  # deleting the compressed exe
  if (Test-Path $OUTPUT_C) {
    Remove-Item $OUTPUT_C
    Alert "$OUTPUT deleted."
  }
  
  # creating the folder
  if (!(Test-Path $FOLDER)) {
    New-Item `
      -ItemType Directory `
      -Path $FOLDER
    Alert "$Folder created."
  } 

  # building the resource file
  if ($MAKE_MANIFEST)
  {  
    # build with windres
    Start-Process "windres.exe" `
      -ArgumentList $RES_ARGS `
      -NoNewWindow `
      -Wait
   
    # was the build successful
    if (!$?) {
      Error "Resource file build failed!"
    } else {
      Success "Resource file built!"
    }
  }

  # building the exe
  Start-Process "gcc.exe" `
    -ArgumentList $ARGUMENTS `
    -NoNewWindow `
    -Wait

  # was the build successful
  if (!$?) {
    Error "Executable build failed!"
  } else {
    Success "Executable built! ($((Get-Item $OUTPUT).Length / 1024) KB)"
  }

  # if asking to remove the manifest
  if ($NO_MANIFEST)
  {
    # getting the icon
    Start-Process "ResourceHacker.exe" `
      -ArgumentList @(
        "-open", $OUTPUT,
        "-save", "_icon.res",
        "-action", "extract",
        "-mask", "ICON,,") `
      -Wait

    # removing resources
    Start-Process "ResourceHacker.exe" `
      -ArgumentList @(
        "-open", $OUTPUT,
        "-save", $OUTPUT,
        "-action", "delete",
        "-mask", "RT_MANIFEST,,") `
      -Wait

    # adding the icon back
    Start-Process "ResourceHacker.exe" `
    -ArgumentList @(
      "-open", $OUTPUT,
      "-save", $OUTPUT,
      "-action", "addoverwrite",
      "-res", "_icon.res",
      "-mask", "ICON,,") `
    -Wait

    # delete the icon resource
    Remove-Item "_icon.res"

    # alerting the result
    Success "Manifest removed! ($((Get-Item $OUTPUT).Length / 1024) KB)"
  }

  # compressing
  if ($COMPRESS)
  {
    # compressing with upx
    Start-Process "upx.exe" `
      -ArgumentList $UPX_ARGS `
      -NoNewWindow `
      -Wait

    # check if successful
    if (!$?) {
      Error "Compression failed!"
    } else {
      Success "Compression successful! ($((Get-Item $OUTPUT_C).Length / 1024) KB)"
    }
  }

  # start the exe if asked
  if ($START_EXE)
  {
    # start the exe
    Start-Process $OUTPUT `
      -ArgumentList $EXE_ARGS `
      -NoNewWindow

    # message
    Success "The executable started!"
  }
}

# function to alert usual data
function Alert([string] $Message) {
  Write-Host $Message -ForegroundColor Blue
}

# function to error usual data
function Error([string] $Message, [bool] $Fatal = $false)
{
  # writing to console
  Write-Host $Message -ForegroundColor Red
  
  # exiting if fatal
  if ($Fatal) {
    exit 1
  }
}

# function to write when success
function Success([string] $Message) {
  Write-Host $Message -ForegroundColor Green
}

# running the script
Main