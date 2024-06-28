#let tree(label, ..children) = style(styles => block(align(center, {
  let label = rect(align(center + horizon)[#label])
  let label_dim = measure(label, styles)
  let children_widths = children.pos().map(x => measure(x, styles).width)
  let all_children = stack(dir: ltr, spacing: 1em, ..children.pos())
  let all_children_dim = measure(all_children, styles)

  // If there are no children, stacking will result in excess space

  if children.pos().len() == 0 {
    label
  } else {
    stack(spacing: 1em, label, all_children)
  }

  // Draw lines

  let label_bottom = (all_children_dim.width / 2, label_dim.height)
  let x = 0em
  let y = label_dim.height + 1em

  for (i, child) in children.pos().enumerate() {
    let child_dim = measure(child, styles)
    let child_top = (x + child_dim.width / 2, y)
    place(top + left, line(start: label_bottom, end: child_top))
    x += child_dim.width + 1em
  }
})))
