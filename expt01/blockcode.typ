#import "@preview/codelst:2.0.1": sourcecode
#import "@preview/showybox:2.0.1": showybox

#let bc = (body, filename: "", type: "normal") => {
  let color = {
    if type == "wrong" {
      red.lighten(92%)
    } else if type == "right" {
      green.lighten(92%)
    } else { 
      black.lighten(98%)
    }
  }
  showybox(
    breakable: true,
    frame: (
      title-color: black.lighten(25%),
      body-color: color,
      border-color: black.lighten(80%),
      thickness: 1pt,
      radius: 3pt,
    ),
   title: [
     #set text(font: "Roboto Slab", size: .85em)
     #filename
   ],
  )[
     #show raw: set text(font: "IBM Plex Mono", size: 1.01em)     
     #sourcecode(frame: none)[#body]
  ]
}
