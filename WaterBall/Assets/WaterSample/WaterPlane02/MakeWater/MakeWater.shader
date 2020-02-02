
Shader "Custom/MakeWater"
{
    SubShader
    {
		Cull Off
		ZTest Off
		ZWrite Off

        Pass
        {
			Name "Update"

            CGPROGRAM

			#define SAMPLE_WAVE
			#ifdef SAMPLE_WAVE

            #include "UnityCustomRenderTexture.cginc"

			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment FS

			half4 FS(v2f_customrendertexture i) : SV_Target
			{
			    float2 uv = i.globalTexcoord;

				float du = 1.0 / _CustomRenderTextureWidth;
				float dv = 1.0 / _CustomRenderTextureHeight;
				float3 duv = float3(du, dv, 0);

				float2 color = tex2D(_SelfTexture2D, uv);
				float p = (2 * color.r - color.g + 0.2f * (
				    tex2D(_SelfTexture2D, uv - duv.zy).r +
				    tex2D(_SelfTexture2D, uv + duv.zy).r +
				    tex2D(_SelfTexture2D, uv - duv.xz).r +
				    tex2D(_SelfTexture2D, uv + duv.xz).r - 4 * color.r)) 
					* 0.999f;

				return float4(p, color.r, 0, 0);
			}
			#else 

			#endif

			ENDCG
        }
    }
}
