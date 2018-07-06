Shader "Unlit/NewUnlitShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	    _FoamTex ("FoamTexture", 2D) = "white" {}
		_FlowMap ("Flow Map", 2D) = "white" {}
		_FlowSpeed ("Flow Speed", float) = 1.0
		_FlowPower ("Flow Power", float) = 1.0
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
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
			sampler2D _FoamTex;
			sampler2D _FlowMap;
			float4 _MainTex_ST;
			float4 _FoamTex_ST;
			float4 _FlowMap_ST;
			float _FlowSpeed;
			float _FlowPower;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// sample the Texture



				float2 flowDir = tex2D(_FlowMap, i.uv) - 0.5;
				flowDir *= _FlowPower;

				float progress1 = frac(_Time.x * _FlowSpeed);
				float progress2 = frac(_Time.x * _FlowSpeed + 0.5);
				float2 uv1 = i.uv + flowDir * progress1;
				float2 uv2 = i.uv + flowDir * progress2;

				float lerpRate = abs((0.5 - progress1)/ 0.5);

				fixed4 foam1 = tex2D(_FoamTex, uv1);
				fixed4 foam2 = tex2D(_FoamTex, uv2);

				fixed4 col1 = tex2D(_MainTex, uv1) * (foam1 * 2);
				fixed4 col2 = tex2D(_MainTex, uv2) * (foam2 * 2);

				fixed4 resultCol = lerp(col1, col2, lerpRate);
				resultCol.a = resultCol + 0.2;


				return resultCol;
			}
			ENDCG
		}
	}
}
