#let sn(x) = {
  let (b, e) = x.split(("e")).map(float)
  $#b dot 10^#e $
}

= 作业

1. 14mm×14mm的CCD摄像机芯片有2048×2048个元素，将它聚焦到相距0.5m远的一个方形平坦区域。该摄像机每毫米能分辨多少线对？摄像机配备了一个35mm镜头。（提示：成像处理模型如图2.3所示，但使用摄像机镜头的焦距替代眼睛的焦距。）

物方焦距 $f = 0.5" m"$，像方焦距 $f = 35" mm"$

$ d = 0.5\ "m", Gamma =  $

TODO 图

2. 高清晰度电视（HDTV）使用1080条水平电视线隔行扫描来产生图像（每隔一行在显像管表面画一条线，每两场形成一帧，每场用时1/60秒）。图像的宽高比是16:9。在水平行数固定的情况下，求图像的垂直分辨率。一家公司已经设计了一种图像获取系统，该系统由HDTV图像生成数字图像。在该系统中，每条（水平）电视行的分辨率与图像的宽高比成正比，彩色图像的每个像素都有24比特的灰度分辨率，红色、绿色、蓝色图像各8比特。这三幅原色图像形成彩色图像。存储90分钟的一部HDTV电影需要多少比特？

对于高度为 $1080" line"$ 的图像，宽度为 $ 1080/9*16 = 1920" line", $

图像面积 $ A = 1920 times 1080 = 2073600" px". $

每像素需 $24" bit"$，则每幅图像需 $ 24 times A = 49766400" bit".$

若每场时间 $T=1/60" s"$，每两场形成一帧，则视频的帧率为

$ f = 1/(2T) = 30" Hz". $

#import "@preview/unify:0.4.3": num, qty

不考虑压缩，存储 $t = 90 "min" = 5400 "s"$ 的一部 HDTV 电影，需要 $ 49766400 times 30 times 5400 = #num("8062156800000")
"bit". $

3. 这两个子集是 m 邻接的.

4. 一个像素宽度的 m 通路转换为 4 通路的一种算法

#import "@preview/algorithmic:0.1.0"
#import algorithmic: algorithm

#algorithm({
  import algorithmic: *
  Function("m-Paths-to-Four-paths", args: ($bold(A)$, $x_0$, $y_0$), {
    Cmt[设定通路起点]
    Assign[$x$][$x_0$]
    Assign[$y$][$y_0$]
    State[]
    While(cond: [*True*], {
      Cmt[寻找通路中下一个像素的位置]
      Cmt[若为 4 邻接，不用更改，直接进行下一步]
      If(cond: $A [x+1][y] = 1$, {
        Assign[$x$][$x+1$]
      })
      ElsIf(cond: $A [x][y+1] = 1$, {
        Assign[$y$][$y+1$]
      })
      ElsIf(cond: $A [x-1][y] = 1$, {
        Assign[$x$][$x-1$]
      })
      ElsIf(cond: $A [x][y-1] = 1$, {
        Assign[$y$][$y-1$]
      })
      Cmt[若为 8 邻接，则增加一个 4 邻接像素]
      ElsIf(cond: $A [x+1][y+1] = 1$, {
        Assign[$bold(A)[x+1][y]$][$1$]
        // OR Assign[$bold(A)[x][y+1]$][1]
        Assign[$x$][$x+1$]
        Assign[$y$][$y+1$]
      })
      ElsIf(cond: $A [x+1][y-1] = 1$, {
        Assign[$bold(A)[x+1][y]$][$1$]
        // OR Assign[$bold(A)[x][y-1]$][1]
        Assign[$x$][$x+1$]
        Assign[$y$][$y-1$]
      })
      ElsIf(cond: $A [x-1][y+1] = 1$, {
        Assign[$bold(A)[x-1][y]$][$1$]
        // OR Assign[$bold(A)[x][y+1]$][1]
        Assign[$x$][$x-1$]
        Assign[$y$][$y+1$]
      })
      ElsIf(cond: $A [x-1][y-1] = 1$, {
        Assign[$bold(A)[x-1][y]$][$1$]
        // OR Assign[$bold(A)[x][y-1]$][1]
        Assign[$x$][$x-1$]
        Assign[$y$][$y-1$]
      })
    })
    Return[]
  })
})
