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

rem key variables to check
let keyl: 0
let keyr: 0
let keyz: 0

rem generating the enemies
let i: 0
gen-lp:
  
  rem is i odd?
  let odd: 0
  if i / 2 = (i - 1) / 2: $, not-odd
    let odd: 1
  not-odd:

  rem setting the enemy position
  poke i * 5 + 4,   enemies + i * 2
  poke 1 + odd * 7, enemies + i * 2 + 1
  
  rem looping
  let i: i + 1
  if i < ecount: gen-lp, $

rem main loop
loop:
  
  rem getting the keys
  peek keyl, 250
  peek keyr, 251
  peek keyz, 254

  rem moving the player left
  if keyl: $, end-if-keyl
  if px > 3: $, end-if-keyl
    let px: px - 1
  end-if-keyl:

  rem moving the player right
  if keyr: $, end-if-keyr
  if px < 44: $, end-if-keyr
    let px: px + 1
  end-if-keyr:

  rem player shooting
  let pshoot: 0
  if keyz: $, end-if-keyz
  if ptimer = 0: $, end-if-keyz
    let pshoot: 1
    let ptimer: 12
  end-if-keyz:

  rem clear the screen
  rect 0, 0, 48, 32, 0

  rem updating and rendering enemies
  let i: 0
  upd-lp:

    rem getting the enemy position
    let ex: 0
    let ey: 0
    peek ex, enemies + i * 2
    peek ey, enemies + i * 2 + 1
    
    rem moving the enemy
    if etimer: end-if-etimer, $
      poke ey + 1, enemies + i * 2 + 1
    end-if-etimer:

    rem drawing the enemy
    rect ex,     ey + 1, 1, 4, 1
    rect ex + 2, ey,     1, 5, 1
    rect ex + 4, ey + 1, 1, 4, 1
    rect ex + 1, ey,     3, 1, 1
    rect ex + 1, ey + 2, 3, 2, 1

    rem if player shoots into the enemy
    if pshoot:      $, end-if-pshoot
    if ex - 1 < px: $, end-if-pshoot
    if ex + 5 > px: $, end-if-pshoot
    if ey < 32:     $, end-if-pshoot
      rect ex - 1, ey - 1, 7, 7, 3
      poke 251 - etimer / 32, enemies + i * 2 + 1
      let score: score + 1
    end-if-pshoot:

    rem player win and lose
    if score = 48: win, $
    if ey = 21:    lose, $
    
    rem looping
    upd-next:
    let i: i + 1
    if i < ecount: upd-lp, $

  rem drawing the shoot
  if pshoot: $, end-if-pshoot2
    rect px, 0, 1, py, 3
  end-if-pshoot2:

  rem rendering the player
  rect px - 2, py + 3, 1, 2, 2
  rect px - 1, py + 1, 1, 3, 2
  rect px,     py,     1, 5, 2
  rect px + 1, py + 1, 1, 3, 2
  rect px + 2, py + 3, 1, 2, 2

  rem draw the score
  rect 0, 31, score, 1, 1

  rem updating the shoot timer
  if ptimer: $, end-if-ptimer
    let ptimer: ptimer - 1
  end-if-ptimer:

  rem speeded enemy movement
  let etimer: etimer - 32

  rem looping
  frame
  goto loop

rem showing the lose screen
lose:

  rem clearing the screen
  rect 0, 0, 48, 32, 0

  rem sad face
  rect 22, 13, 1, 3, 3
  rect 25, 13, 1, 3, 3
  rect 22, 18, 1, 1, 3
  rect 25, 18, 1, 1, 3
  rect 23, 17, 2, 1, 3

  rem looping in the lose
  frame
  goto lose

rem player wins
win: 

  rem clearing the screen
  rect 0, 0, 48, 32, 0
  
  rem funny face
  rect 22, 13, 1, 3, 3
  rect 25, 13, 1, 3, 3
  rect 22, 17, 1, 1, 3
  rect 25, 17, 1, 1, 3
  rect 23, 18, 2, 1, 3

  rem looping in the lose
  frame
  goto win