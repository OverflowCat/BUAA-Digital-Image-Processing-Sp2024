#let chain = "0110233210332322111"
计算编码 #chain 的一次差分。

#let chain- = ()
#let first = int(chain.at(chain.len()-1)) - int(chain.at(0))
#let colored(x) = text(fill: red, $#x$)
0. #colored($ #chain.at(chain.len()-1) - #chain.at(0) = first;$)
#for i in range(chain.len() - 1) {
  let pre = chain.at(i)
  let post = chain.at(i + 1)
  let delta = int(post) - int(pre)
  [ + $post - pre = #delta#if delta < 0 [$, quad #delta + 4 = #(delta+4)$] #if i == chain.len() - 2 {"."} else {";"}$ ]
  if delta < 0 {
    delta += 4
  }
  chain-.push(delta)
}
#let res = chain-.map(str).join("")

故编码 $chain$ 的一次差分为 $res$；用循环首差链码计算的一次差分为 $colored(first)res$。