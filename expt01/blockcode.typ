#import "@preview/codelst:2.0.1": sourcecode
#import "@preview/showybox:2.0.1": showybox

#let bc = (body, filename: "") => {
  showybox(
    breakable: true,
    frame: (
      title-color: black.lighten(25%),
      body-color: black.lighten(98%),
      border-color: black.lighten(80%),
      thickness: 1pt,
      radius: 3pt,
    ),
   title: [
     #set text(font: "Roboto Slab", size: .85em)
     #filename
   ],
   sourcecode(frame: none)[#body],
  )
}
