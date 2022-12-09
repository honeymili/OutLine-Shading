//https://zhuanlan.zhihu.com/p/109101851
Shader "Honey/Ouline/ZhiHu_2173_1"
{
     Properties
    {
        _Outline("OutLine",range(0,10)) = 0.2
        _OutlineColor("OutLineColor",color) = (0,0,0,1) 
    }
    SubShader
    {

        Pass
        {
            Name "Base"
            Tags {"LightMode"="UniversalForward"}
            Cull off
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

            v2f vert (appdata v)
            {
                v2f o;
                //o.worldPos = TransformObjectToWorld(v.vertex.xyz);
                o.vertex = TransformObjectToHClip(v.vertex);
                //内置管线
                //o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                return half4(1,1,1,1);
            }
            ENDHLSL
        }
        
        Pass
        {
            Name "Outline"
            Tags{ "LightMode" = "SRPDefaultUnlit" }
            Cull front
           
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
                float3 normalWorld : TEXCOORD0;
            };
            CBUFFER_START(UnityPerMaterial)
            float _Outline;
            half4 _OutlineColor;
            CBUFFER_END

             v2f vert (appdata v) 
            {
                v2f o;
                //顶点沿着法线方向外扩
                o.vertex = TransformObjectToHClip(float4(v.vertex.xyz + v.normal * _Outline * 0.1 ,1));
                //内置管线
                // o.pos = UnityObjectToClipPos(float4(v.vertex.xyz + v.normal * _OutlineWidth * 0.1 ,1));
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