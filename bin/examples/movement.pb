rem variables for keys
let keyl: 0
let keyr: 0
let keyu: 0
let keyd: 0

rem position of the player
let x: 22
let y: 14

rem main loop
loop:

  rem peek keys from addresses
  peek keyl, 250
  peek keyr, 251
  peek keyu, 252
  peek keyd, 253

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
  rect x,     y,     4, 4, 1
  rect x + 1, y + 1, 1, 1, 3
  rect x + 3, y + 1, 1, 1, 3

  rem looping
  frame
  goto loop