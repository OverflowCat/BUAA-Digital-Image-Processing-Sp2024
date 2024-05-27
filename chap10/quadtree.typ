// curl "https://gist.githubusercontent.com/oliver-ni/701eec83f6cc0b7e9464c2e67e607faa/raw/abc4f03d36669bb506268a989f1cc2dfdb2ce5dd/tree.typ" -o tree.typ

#import "tree.typ": tree

#let im = (
  (0, 0, 0, 0, 0, 0, 0, 0),
  (0, 0, 0, 0, 0, 0, 0, 0),
  (0, 0, 1, 1, 1, 1, 0, 0),
  (0, 0, 1, 1, 1, 1, 0, 0),
  (0, 0, 1, 0, 0, 1, 0, 0),
  (0, 0, 1, 0, 0, 1, 0, 0),
  (0, 0, 0, 0, 0, 0, 0, 0),
  (0, 0, 0, 0, 0, 0, 0, 0),
)

#let same = (arr) => arr.all(x => x == arr.first())

#let split(im) = {
  let h = int(im.len() / 2)
  let w = int(im.at(0).len() / 2)
  if h < 1 or w < 1 or same(im.flatten()) {
    return im
  }
  // split into 4 quadrants
  let q1 = im.slice(0, h).map(row => row.slice(0, w))
  let q2 = im.slice(0, h).map(row => row.slice(w))
  let q3 = im.slice(h).map(row => row.slice(0, w))
  let q4 = im.slice(h).map(row => row.slice(w))
  (q1, q2, q3, q4).map(split)
}


#let showtree(i, subtree) = {
  let children = subtree.map(x => tree(i + 1, x))

  tree($R_#i$, children)
}

#showtree(1, split(im))

// split(im)

#tree(
  "A",
  tree(
    "B",
    tree("D"),
    tree("E")
  ),
  tree(
    "C",
    tree("F"),
    tree("G")
  )
)