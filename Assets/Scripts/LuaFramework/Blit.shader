Shader "Unlit/Blit"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Rect("Rect", Vector) = (0.5, 0.5, 0.5, 0.5)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

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

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Tex_ST;
			float4 _Rect;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _Tex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				clip(_Rect.x - abs(i.uv.x - _Rect.y));
				clip(_Rect.z - abs(i.uv.y - _Rect.w));
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
