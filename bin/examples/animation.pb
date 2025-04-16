rem position of the player
let x: 22
let y: 14
let f: 0

rem bitmap of the player
rem top f1 f3
bitmap 0: 0000 0110 0111 0011
bitmap 1: 0000 1100 1100 1110
bitmap 2: 0011 0011 0011 0010
bitmap 3: 1110 1100 1100 0100

rem full f2
bitmap 4: 0110 0111 0011 0011
bitmap 5: 1100 1100 1110 1110
bitmap 6: 0011 0111 0000 0000
bitmap 7: 1100 1110 0000 0000

rem bottom f3
bitmap 8:  0000 0110 0111 0011
bitmap 9:  0000 1100 1100 1110
bitmap 10: 0011 0011 0011 0001
bitmap 11: 1110 1100 1100 1000

rem main loop
loop:

  rem move left
  if keyl * (x > 1): $, fi-keyl
    let x: x - 1
  fi-keyl:

  rem move right
  if keyr * (x < 39): $, fi-keyr
    let x: x + 1
  fi-keyr:

  rem move up
  if keyu * (y > 2): $, fi-keyu
    let y: y - 1
  fi-keyu:

  rem move down
  if keyd * (y < 22): $, fi-keyd
    let y: y + 1
  fi-keyd:

  rem clear the screen
  rect 0, 0, 48, 32, 0

  rem draw the player
  if keyd + keyu + keyr + keyl: $, else-any-key
    let f: f + 1
    if f = 6: $, fi-any-key
  else-any-key:
    let f: 0
  fi-any-key:

  rem drawing the player
  sprite f / 2 * 4,     x,     y,     1
  sprite f / 2 * 4 + 1, x + 4, y,     1
  sprite f / 2 * 4 + 2, x,     y + 4, 1
  sprite f / 2 * 4 + 3, x + 4, y + 4, 1

  rem drawing the eyes
  if f / 2 = 1: $, else-eyes
    rect x + 3, y + 2, 1, 1, 3
    rect x + 5, y + 2, 1, 1, 3
  goto fi-eyes
  else-eyes:
    rect x + 3, y + 3, 1, 1, 3
    rect x + 5, y + 3, 1, 1, 3
  fi-eyes:

  rem drawing 4 boxes
  rect 1,  1,  46, 1,  2
  rect 1,  1,  1,  30, 2
  rect 46, 1,  1,  30, 2
  rect 1,  30, 46, 1, 2

  rem looping
  frame
  goto loop