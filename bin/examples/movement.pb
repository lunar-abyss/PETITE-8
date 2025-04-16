rem position of the player
let x: 22
let y: 14

rem bitmap of the player
bitmap 0: 01110 01110 11111 01110 01010

rem main loop
loop:

  rem move left
  if keyl: $, fi-keyl
    let x: x - 1
  fi-keyl:

  rem move right
  if keyr: $, fi-keyr
    let x: x + 1
  fi-keyr:

  rem move up
  if keyu: $, fi-keyu
    let y: y - 1
  fi-keyu:

  rem move down
  if keyd: $, fi-keyd
    let y: y + 1
  fi-keyd:

  rem clear the screen
  rect 0, 0, 48, 32, 0

  rem draw the player
  sprite 0, x, y, 2

  rem looping
  frame
  goto loop