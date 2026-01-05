#let problemCounter = counter("q")
#let Q = (body) => context {
  set text(weight: "semibold")
  problemCounter.step()

  problemCounter.display("1、")
  body
}

#let FT = $cal(F)$
#let IFT = $FT^(-1)$
#let CONV = sym.star.filled
#let SUMOO = $sum^(oo)_(n=-oo)$
#let INTOO = $integral^(oo)_(-oo)$
