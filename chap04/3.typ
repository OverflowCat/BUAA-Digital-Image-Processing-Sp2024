#import "@preview/unify:0.6.0": qty
#import "helper.typ": Q
#let a = qty(0.5, "mm")

#Q[3、	考虑一幅棋盘图像，其中每一个方格的大小为 #a×#a。假定图像在两个坐标方向上无限扩展，为避免混淆，问最小取样率是多少（样本数/mm）？（教材P192页，第4.12题。）]

记方格边长为 $a = #a $，则其最高频率

$ f_max = 1 / a = #qty(2, "mm^-1"). $

根据 Nyquist 采样定理，取样率至少应为最高频率的两倍，所以

$ f_upright(s) = 2 f_max = #qty(4, "mm^-1"). $

即最小取样率是 4 样本数 / mm。