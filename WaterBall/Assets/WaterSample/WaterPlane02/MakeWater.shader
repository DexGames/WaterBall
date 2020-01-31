
Shader "Custom/MakeWater"
{
    Properties
    {
        _AddTexture ("AddTexture", 2D) = "white" {}
		_Add ("Add", Float) = 0.0
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "RenderType"="Transparent" "LightMode" = "ForwardBase"}
        LOD 100

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha 

        Pass
        {
            CGPROGRAM

            #pragma vertex VS
            #pragma fragment FS

            #include "UnityCG.cginc"

            struct vs_input
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };

			struct fs_input
			{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
			};

			
            sampler2D _AddTexture;
            float4 _AddTexture_ST;
			float _Add;

			// 頂点シェーダー
            fs_input VS (vs_input i)
            {
                fs_input o;
				
				o.pos = UnityObjectToClipPos(i.pos);
				o.uv = i.uv;

                return o;
            }

			// フラグメントシェーダー
            fixed4 FS (fs_input i) : SV_Target
            {
				return tex2D(_AddTexture, i.uv);
            }

            ENDCG
        }
    }
}
