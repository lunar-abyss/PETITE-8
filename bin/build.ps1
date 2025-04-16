# parameters to set
[string] $Source     = "game.pb"
[string] $Output     = "game.exe"
[string] $Executable = "PETITE-8.exe"
[bool]   $RunBuild   = $false
[bool]   $Compress   = $false
[bool]   $SaveREMs   = $false

# parsing the arguments
for ([int] $i = 0; $i -lt $Args.Length; $i++)
{
  # getting the argument
  $arg = $Args[$i]

  # comparing the argument
  switch ($arg)
  {
    # setting the output file name
    "-o" { $Output = $Args[$i++ + 1] }

    # setting the executable name
    "-ec" { $Executable = "PETITE-8-C.exe" }
    "-en" { $Executable = "PETITE-8.exe" }

    # compressing the executable
    "-c"    { $Compress = $true }
    "-crem" { $SaveREMs = $true }

    # running the build
    "-r" { $RunBuild = $true }

    # adding the source file
    default { $Source = $arg }
  }
}

# main function
function Main
{
  # title
  Alert "PETITE-8 Build Tool V2"

  # write to console the arguments
  Alert "Source: $Source"
  Alert "Output: $Output"
  Alert "Executable: $Executable"
  Alert "Run Build: $RunBuild"
  Alert "Compress: $Compress" 
  
  # writing about compression
  if ($Compress) {
    Alert "Save REMs: $SaveREMs"
  }

  # getting the code
  [string] $Code = Compress(Get-Content $Source)

  # copy file
  Copy-Item `
    -Path $Executable `
    -Destination $Output

  # append to the file
  Add-Content `
    -Path $Output `
    -Value $Code

  # check for success
  if ($?) {
    Success "Done!"
  } else {
    Error "Failed!" -Fatal $true
  }

  # running the file
  if ($RunBuild) {
    Start-Process $Output
  }
}

# compressor function
function Compress([string[]] $Text)
{
  # initial size
  [int] $InitSize = ($Text -join "`n").Length

  # compressing text
  $Text = $Text `
    -join "`n" `
    -replace '(?<=^|\n)[ \t]*', "" `
    -replace "\n+", "`n" `
    -replace " *([,\-+*/=<>():]) *", '$1'

  # removing rems
  if (!$SaveREMs) {
    $Text = $Text -replace 'rem.*\n?', ""
  }

  # comparison
  Success "Compression: $InitSize -> $($Text[0].Length) ($([Math]::Floor($Text[0].Length / $InitSize * 10000) / 100)%)"

  # return the result
  return $Text
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