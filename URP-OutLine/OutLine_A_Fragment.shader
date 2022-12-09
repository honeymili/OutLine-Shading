////https://zhuanlan.zhihu.com/p/410710318
// 基于观察角度和表面法线的轮廓线渲染， 这种方法使用视角方向和表面法线的点乘结果来得到轮廓线信息的。
////UnityCG.cginc 拿出来 ObjSpaceViewDir 封装的函数 计算物体的视方向
Shader "Honey/Outline/View_frag"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", color) = (1,1,1,1)
        _OutLine("OutLine",float) = 0.2
        //_OutLineColor("OutLineColor", color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Pass
        {
            //cull front
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float3 normalWorld : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 binormal : TEXCOORD4;
                float3 objectViewDir : TEXCOORD5;
                float3 normal : TEXCOORD6;
            };

            CBUFFER_START(UnityPerMaterial)
            half4 _Color;
            float _OutLine;
            half4 _LightColor0;
            half4 _OutLineColor;
            CBUFFER_END

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex); 

//UnityCG.cginc            
float3 ObjSpaceViewDir (float4 v)
{
    float3 objSpaceCameraPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos.xyz, 1)).xyz;
    return objSpaceCameraPos - v.xyz;
} 

            v2f vert (appdata v)
            {
                v2f o;
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.normalWorld = mul(float4(v.normal,0.+0),unity_WorldToObject).xyz;
                o.tangentDir = TransformObjectToWorldDir(v.tangent.xyz);
                o.binormal = cross(o.normalWorld,o.tangentDir) * v.tangent.w;
                o.uv = v.uv;
                //计算描边 获取观察角度和表面法线
                o.objectViewDir = ObjSpaceViewDir(v.vertex);
                o.normal = v.normal;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half3 surfaceColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _Color.rgb ;
                half3 objectViewDir = normalize(i.objectViewDir);
                half3 normal = normalize(i.normal);
                half3 outLineFactor = (step(_OutLine, dot(normal, objectViewDir))) ;
                half3 col = outLineFactor *surfaceColor;

                return  half4(col,1);
            }

            ENDHLSL
        }
    }
}
