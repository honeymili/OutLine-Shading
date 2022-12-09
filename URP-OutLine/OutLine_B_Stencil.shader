//Stencil测试 显示不出描边 需要把描边的pass cull back才行  但是这样违背了stencil测试
Shader "Honey/OutLine/B_Stencil"
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
            Tags{"LightMode" = "UniversalForward"}
            Stencil
            {
                Ref 1
                Comp Always
                Pass Replace
            }
            HLSLPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

             struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
            };

            half4 _Color;
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
                float4 surfaceColor = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv) * _Color;
                return half4(surfaceColor.rgb, 1);
            }
            ENDHLSL
        }

        Pass
        {
            Name "OutLine"
            Tags{ "LightMode" = "SRPDefaultUnlit" }
            Stencil
            {
                Ref 1
                Comp NotEqual
            }

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