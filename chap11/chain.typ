#let colored(x) = text(fill: red, $#x$)

#let calcChain(chain) = {
  let chain- = ()
  let content = []
  let first = int(chain.at(0)) - int(chain.at(chain.len()-1))
  if first < 0 {
    first += 4
  }
  content += [0. #colored($ #chain.at(chain.len()-1) - #chain.at(0) = first;$)]
  for i in range(chain.len() - 1) {
    let pre = chain.at(i)
    let post = chain.at(i + 1)
    let delta = int(post) - int(pre)
    content += [ + $post - pre = #delta#if delta < 0 [$, quad #delta + 4 = #(delta+4)$] #if i == chain.len() - 2 {"."} else {";"}$ ]
    if delta < 0 {
      delta += 4
    }
    chain-.push(delta)
  }
  (
    content: content,
    first: first,
    res: chain-.map(str).join(""),
  )
}

#let chain = "0110233210332322111"
#let (res, content, first) = calcChain(chain)

#import "util.typ": problem
#problem[
计算编码 #chain 的一次差分。
]

#content

故编码 $chain$ 的一次差分为 $res$；用循环首差链码计算的一次差分为 $colored(first)res$。

#let lShift(s, k) = {
  s.slice(k) + s.slice(0, k)
}

#let calcShape(chain) = {
  let min = chain
  for i in range(1, chain.len()) {
    let shifted = lShift(chain, i)
    if shifted < min {
      min = shifted
    }
  }
  min
}
