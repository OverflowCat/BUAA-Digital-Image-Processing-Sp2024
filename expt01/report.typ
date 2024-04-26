=== 计算局部直方图

对于给定图像中任意像素的坐标，$S_(x y)$ 表示规定大小的以 $(x," "y)$ 为中心的邻域（子图像），记 $p_S_(x y)$ 为区域 $S_(x y)$ 中像素的规一化直方图，$r_i$ 为灰度，则该邻域中像素的均值

$ m_S_(x y) = sum^(L-1)_(i=0) r_i p_S_(x y) (r_i) $

$ sigma_S_(x y) = sum^(L-1)_(i=0) $


对于 $x=0,1,2,dots.c,M-1,quad y=0,1,2,dots.c,N-1$，有

=== 优化

$
g(x,y) = cases(
 E dot.c f(x","y)","quad &m_S_(x y) <= k_0 m_G " 且 " k_1 sigma_G <= sigma_S_(x y) <= k_2 sigma_G,
 f(x,y)"," quad &"其他"
)
$
