//https://zhuanlan.zhihu.com/p/410710318
//基于观察角度和表面法线
Shader "Honey/OutLine/View" 
{
    Properties 
    {
        _Outline ("Outline", Range(0, 1)) = 0.1
    }
    SubShader 
    {
        Pass 
        {
            Cull Back

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _Outline;

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed4 color : COLOR;
            };

            v2f vert (appdata_base v)
            {       
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 ObjViewDir = normalize(ObjSpaceViewDir(v.vertex));
                float3 normal = normalize(v.normal);
                float factor = step(_Outline, dot(normal, ObjViewDir));
                o.color = float4(1, 1, 1, 1) * factor;
                return o;
            }

            float4 frag(v2f i) : SV_Target 
            { 
                return i.color;
            }

            ENDCG
        }
    }
}
/*
轮廓线渲染方法一览
在RTR3中作者分成了5种类型(这在《Unity Shader入门精要》的P289页有讲):

1,基于观察角度和表面法线 通过视角方向和表面法线点乘结果来得到轮廓线信息。 简单快速，但局限性大。

2,过程式几何轮廓线渲染。 核心是两个Pass:第一个Pass只渲染背面并且让轮廓可见(比如通过顶点外扩);第二个Pass正常渲染正面。 
  快速有效，适应于大多数表面平滑的模型，但不适合立方体等平整模型。

3,基于图像处理。 可以适用于任何种类的模型。但是一些深度和法线变化很小的轮廓无法检测出来，如桌子上一张纸。

4,基于轮廓边检测。 检查这条边相邻的两个三角面片是否满足：(n0·v > 0) ≠ (n1·v > 0)。这里n0和n1分别表示两个相邻三角面片的法向,v是从视角到该边上任意顶点的方向。
  本质是检查相邻两个三角是否一个面向视角,另一个背向视角。 可以控制轮廓线的风格渲染。缺点是轮廓是逐帧单独提取的，帧与帧之间会出现跳跃性。

5,混合上述方法。 例如，首先找到轮廓线，把模型和轮廓边渲染到纹理中，再使用图像处理识别轮廓线，并在图像空间进行风格化渲染。

总结：这里我分别使用 基于观察角度和表面法线、模板测试、过程式几何轮廓线、基于图像处理（屏幕后处理） 的方法对一个简单场景做了实现。
      最后简单使用了 SDF 的方法去进行描边实现。 由于关注的是轮廓线的渲染方法，故这里我尽量采用最小实现，也就没有考虑光照的效果了。

*/