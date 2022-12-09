# OutLine-Shading
//Stencil测试 显示不出描边 需要把描边的pass cull back才行  但是这样违背了stencil测试
Shader中的多种描边算法

1.基于观察角度和表面法线的轮廓线渲染：OutLine_A_Fragment / OutLine_A_Vertex

2.过程式几何轮廓线渲染：OutLine_B_Geometry

——— 单独Pass计算了轮廓 ：Outline_SinglePass

3.基于图像处理的轮廓线渲染：OutLine_C_Image



