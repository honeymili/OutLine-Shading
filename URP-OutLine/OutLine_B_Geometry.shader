//过程式几何轮廓线渲染
//把前面的模板测试换成了剔除操作。正常渲染的时候剔除背面渲染正面，第二次顶点扩张之后剔除正面渲染背面，这样渲染背面时由于顶点外扩的那一部分就将被我们所看见，
//而原来的部分则由于是背面且不透明所以不会被看见，形成轮廓线渲染原理。因此从原理上也能看出，这里得到的轮廓线不单单是外轮廓线。
Shader "Honey/OutLine/B_Geometry"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor("OutlineColor", color) = (0,0,0,1)
        _Outline("_Outline",range(0,1)) = 0.1
    }
    SubShader
    {
        //Tags { "RenderType"="Opaque" }
        Tags  { "RenderPipeline"="UniveralPipeline" "RenderType"="Opaque" }
        LOD 100
 
        Pass
        {

            Tags{"LightMode" = "UniversalForward"} 
            cull back
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"  

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            TEXTURE2D(_MainTex);                 
            SAMPLER(sampler_MainTex);

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float4 surfaceColor = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, i.uv);
                return half4 (surfaceColor.rgb,1);
            }
            ENDHLSL
        }

Pass
        {
            Name "OutLine"
            Tags{ "LightMode" = "SRPDefaultUnlit" }
            cull front
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"  

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };
            CBUFFER_START(UnityPerMaterial)
            float _Outline;
            half4 _OutlineColor;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                //把顶点和法线变换到视角空间下 为了让描边可以在观察空间达到最好的效果
                float4 pos = mul(UNITY_MATRIX_MV, v.vertex); 
                float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
                //设置法线z分量 并归一化 
                 normal.z = -0.5;
                //将顶点沿其方向扩张 得到扩张后的顶点坐标 对法线的处理是为了避免背面扩张后的顶点挡住正面的面片
                pos = pos + float4(normalize(normal), 0) * _Outline;
                //把顶点从视角空间变换到剪裁空间
                o.vertex = mul(UNITY_MATRIX_P, pos);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                return half4(_OutlineColor.rgb, 1);
            }
            ENDHLSL
        }
    }
}