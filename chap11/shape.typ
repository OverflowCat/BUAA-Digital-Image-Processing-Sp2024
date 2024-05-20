#import "@preview/cetz:0.2.2"

#cetz.canvas(length: 2cm,{
  import cetz.draw: *

  // 外框
  set-style(mark: (end: "straight"))
  line((1, 0), (0, 0), stroke: blue)  // 底部
  line((3, 0), (2, 0), stroke: blue)  // 底部

  line((0, 1), (0, 2), stroke: blue)
  line((0, 0), (0, 1), stroke: blue)
  line((1, 1), (1, 0), stroke: blue)
  line((2, 0), (2, 1), stroke: blue)
  line((3, 1), (3, 0), stroke: blue)
  line((3, 2), (3, 1), stroke: blue)

  line((2, 1), (1, 1), stroke: blue)
  line((0, 2), (1, 2), stroke: blue)
  line((1, 2), (2, 2), stroke: blue)
  line((2, 2), (3, 2), stroke: blue)

  set-style(mark: none)
  let v-(x, y)  = line((x, y - .05), (x, y + .05))
  let h-(x, y)  = line((x - .05, y), (x + .05, y))
  let dot(x, y, ..arguments) = circle((x, y), radius: .05, ..arguments)
  h-(0, 1)
  h-(3, 1)
  v-(1, 2)
  v-(2, 2)
  dot(0, 2, fill: red, stroke: red)
  content((0, 2.2), "起点")
  content((.5, 2.15),  $0$)
  content((1.5, 2.15), $0$)
  content((2.5, 2.15), $0$)
  content((3.15, 1.5), $3$)
  content((3.15, .6),  $3$)
  content((2.5, .15),  $2$)
  content((2.15, .6),  $1$)
  content((1.5, 1.15), $2$)
  content((1.15, .6),  $3$)
  content((.5, .15),   $2$)
  content((.15, .6),  $1$)
  content((.15, 1.5),  $1$)

  let colored(x) = text(fill: purple, $#x$)
  content((1, 2.2), colored($0$))
  content((2, 2.2), colored($0$))
  content((3, 2.2), colored($3$))
  content((3.15, 1), colored($0$))
  content((3.15, 0), colored($3$))
  content((2-.15, 0), colored($3$))
  content((2.15, 1.1), colored($1$))
  content((1-.15, 1.1), colored($1$))
  content((1.15, 0), colored($3$))
  content((-.2, 0), colored($3$))
  content((-.2, 1), colored($0$))
  content((-.2, 2), colored($3$))
})