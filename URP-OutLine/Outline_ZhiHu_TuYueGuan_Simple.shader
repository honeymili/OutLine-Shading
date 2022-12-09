//BackFacing ： https://zhuanlan.zhihu.com/p/361285222
//最简版本 无开关 
Shader "Honey/Outline/ZhiHu_TuYueGuan_Simple"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", color) = (1,1,1,1)
        _Outline("OutLine",range(0,10)) = 0.2
        _OutlineColor("OutLineColor",color) = (0,0,0,1) 
    }
    SubShader
    {
       
        Pass
        {
            Name "Base"
            Tags{"LightMode" = "UniversalForward"}
            Cull off
            HLSLPROGRAM
            #pragma target 3.0
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
                float4 surfaceColor = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv) *_Color;
                return half4(_Color.rgb, 1);
            }
            ENDHLSL
        }

       Pass
        {
            Name "OutLine"
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
                float4 scaledScreenParams = GetScaledScreenParams();
                float ScaleX = abs(scaledScreenParams.x / scaledScreenParams.y);//求得X因屏幕比例缩放的倍数
                v2f o;
                VertexPositionInputs GetVertex = GetVertexPositionInputs(v.vertex .xyz); //TransformObjectToHClip
                VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal);
                float3 normalCS = TransformWorldToHClipDir(normalInput.normalWS);// TransformObjectToWorldNormal
                float2 extendDis = normalize(normalCS.xy) *(_Outline*0.01);//根据法线和线宽计算偏移量
                extendDis.x /=ScaleX ;//由于屏幕比例可能不是1:1，所以偏移量会被拉伸显示，根据屏幕比例把x进行修正
                o.vertex = GetVertex.positionCS;
                //屏幕下描边宽度不变，则需要顶点偏移的距离在NDC坐标下为固定值
                //因为后续会转换成NDC坐标，会除w进行缩放，所以先乘一个w，那么该偏移的距离就不会在NDC下有变换
                o.vertex.xy += extendDis * o.vertex.w ;
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
/*
       
        */