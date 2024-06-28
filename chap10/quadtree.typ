// curl "https://gist.githubusercontent.com/oliver-ni/701eec83f6cc0b7e9464c2e67e607faa/raw/abc4f03d36669bb506268a989f1cc2dfdb2ce5dd/tree.typ" -o tree.typ

#import "tree.typ": tree
#set page("a3", flipped: true)
#set text(font: "Noto Sans CJK SC")

== 4

*（教材P512页，第10.39题。）*

分割的四叉树如下：

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


// #let showtree(i, subtree) = tree($R_#i$, ..subtree.filter(x => type(x) == array).enumerate().map(((j, x)) => showtree(str(i) + str(j + 1), x)))

// #showtree("", split(im))

#let showtree2(arr, idx: "") = {
  if arr.len() == 4 {
    tree($R_idx$, ..arr.enumerate().map(((i, tree)) => showtree2(tree, idx: idx + str(i + 1))))
  } else {
    tree($R_idx$)
  }
}

#showtree2(split(im))


// #let showtree0(i, subtree) = {
//   subtree
//   let children = subtree.map(x => showtree(i + 1, x))
//   assert(children.all(x => type(x) == content), message: "subtree must be a list of trees")
//   // tree($R_#i$, ..children)
// }

// #showtree(1, split(im))

/*
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
    tree("G"),
    tree("H"),
  )
)
*/