////https://zhuanlan.zhihu.com/p/410710318
Shader "Honey/OutLine/SinglePass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", color) = (1,1,1,1)
        _Outline("OutLine",range(0,1)) = 0.2
        _OutlineColor("OutLineColor",color) = (0,0,0,1)
    }
    SubShader
    {
         Tags  { "RenderPipeline"="UniveralPipeline" "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            //Name "OutLine"
            //Tags{ "LightMode" = "SRPDefaultUnlit" }
            //cull front
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
                float4 pos = mul(UNITY_MATRIX_MV, v.vertex); 
                float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);  
                normal.z = -0.5;
                pos = pos + float4(normalize(normal), 0) * _Outline;
                o.vertex = mul(UNITY_MATRIX_P, pos);

                return o;
            }

            float4 frag(v2f i) : SV_Target 
            { 
                return float4(_OutlineColor.rgb, 1);               
            }
            ENDHLSL
        }  
    }
}
