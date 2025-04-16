rem simple space shooter game
let px: 24
let py: 32 - 5 - 2
let pshoot: 0
let ptimer: 0
let score: 0

rem this is an address of the array
let enemies: 64

rem enemies data
let ecount: 8
let etimer: 0 - 32

rem bitmaps: 0: player, 1: enemy, 2: explosion, 3: win, 4: lose
bitmap 0: 00100 01110 01110 11111 10101
bitmap 1: 01110 10101 11111 11111 10101
bitmap 2: 10101 01110 11111 01110 10101
bitmap 3: 1001 0000 1001 0110
bitmap 4: 1001 0000 0110 1001

rem generating the enemies
let i: 0
gen-lp:
  
  rem is i odd?
  let odd: 0
  if i / 2 = (i - 1) / 2: $, fi-not-odd
    let odd: 1
  fi-not-odd:

  rem setting the enemy position
  poke i * 5 + 4,   enemies + i * 2
  poke 1 + odd * 7, enemies + i * 2 + 1
  
  rem looping
  let i: i + 1
  if i < ecount: gen-lp, $

rem main loop
loop:

  rem moving the player left
  if keyl: $, fi-keyl
  if px > 3: $, fi-keyl
    let px: px - 1
  fi-keyl:

  rem moving the player right
  if keyr: $, fi-keyr
  if px < 44: $, fi-keyr
    let px: px + 1
  fi-keyr:

  rem player shooting
  let pshoot: 0
  if keyz: $, fi-keyz
  if ptimer = 0: $, fi-keyz
    let pshoot: 1
    let ptimer: 12
  fi-keyz:

  rem clear the screen
  rect 0, 0, 48, 32, 0

  rem updating and rendering enemies
  let i: 0
  upd-lp:

    rem getting the enemy position
    peek ex, enemies + i * 2
    peek ey, enemies + i * 2 + 1
    
    rem moving the enemy
    if etimer: fi-etimer, $
      poke ey + 1, enemies + i * 2 + 1
    fi-etimer:

    rem drawing the enemy
    sprite 1, ex, ey, 1

    rem if player shoots into the enemy
    if pshoot:      $, fi-pshoot
    if ex - 1 < px: $, fi-pshoot
    if ex + 5 > px: $, fi-pshoot
    if ey < 32:     $, fi-pshoot
      rect ex, ey, 5, 5, 0
      sprite 2, ex, ey, 3
      poke 251 - etimer / 32, enemies + i * 2 + 1
      let score: score + 1
    fi-pshoot:

    rem player win and lose
    if score = 48: win, $
    if ey = 21:    lose, $
    
    rem looping
    upd-next:
    let i: i + 1
    if i < ecount: upd-lp, $

  rem drawing the shoot
  if pshoot: $, fi-pshoot2
    rect px, 0, 1, py, 3
  fi-pshoot2:

  rem rendering the player
  sprite 0, px - 2, py, 2

  rem draw the score
  rect 0, 31, score, 1, 1

  rem updating the shoot timer
  if ptimer: $, fi-ptimer
    let ptimer: ptimer - 1
  fi-ptimer:

  rem enemy movement timer
  let etimer: etimer - 32

  rem looping
  frame
  goto loop

rem showing the lose screen
lose:
  rect 0, 0, 48, 32, 0
  sprite 4, 22, 14, 3
  frame
  goto lose

rem player wins
win: 
  rect 0, 0, 48, 32, 0
  sprite 3, 22, 14, 3
  frame
  goto win