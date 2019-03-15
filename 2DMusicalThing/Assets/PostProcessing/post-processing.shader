// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/Pixelate"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		[Header(ScreenEffect)]
		_LinesSize("Line Size", Float) = 1.0
		_MiddleLine("Middle Line",Float) = 5.0
		_DisplacementTex("Displacement",2D) = "white" {}
		_Strength("Strength",float) = 1.0

		[Header(Chromatic Aberration)]
		_AberrationDist("Offset", Range(-10, 10)) = 0.0


		[Header(Noise)]
		_NoiseStrength("Noise Strength",Range(0, 0.005)) = 0.005
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

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
				half4 pos:POSITION;
				fixed4 sPos : TEXCOORD0;
				float2 uv : TEXCOORD1;
			};


			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.sPos = ComputeScreenPos(o.pos);
				return o;
			}
			
			sampler2D _MainTex, _CameraDepthTexture;
			float _LinesSize;
			float _MiddleLine;
			
			float _AberrationDist;
			sampler2D _DisplacementTex;
			float _Strength;

			float _focusDistance;
			float _focusRange;

			float _NoiseStrength;

			float4 aberration3D(float2 uv) {
				fixed4 col = fixed4(1, 1, 1, 1);

				float2 red_uv = uv + float2(_AberrationDist / _ScreenParams.x, 0);
				float2 blue_uv = uv + float2(_AberrationDist / _ScreenParams.x, 0);

				col.r = tex2D(_MainTex, red_uv).r;
				col.g = tex2D(_MainTex, uv).g;
				col.b = tex2D(_MainTex, blue_uv).b;

				return col;
			}


			float random(float p)
			{
				return frac( abs(sin(p + _Time.y + frac(p))) );
			}


			float4 frag (v2f i) : SV_Target
			{
				float4 col = tex2D(_MainTex, i.uv);

				float noise = _NoiseStrength==0? 0:((1+_NoiseStrength) * random(i.sPos.y));

				fixed p = i.sPos.y / i.sPos.w;

				float difX = _ScreenParams.x - i.pos.x;
				float difY = _ScreenParams.y - i.pos.y;
				if (abs(difX) < _ScreenParams.x/_MiddleLine || i.pos.x < _ScreenParams.x / _MiddleLine || i.pos.x -_ScreenParams.x > _ScreenParams.x - (_ScreenParams.x / _MiddleLine) ) {
					return  float4(0, 0, 0, 0);
				}
				else if (abs(difY) < _ScreenParams.y / _MiddleLine || i.pos.y < _ScreenParams.y / _MiddleLine ) {
					return float4(0, 0, 0, 0);
				}
				else {

					if (difX < 0) {
						if ((uint)(p* _ScreenParams.y / floor(_LinesSize + noise)) % 2 == 0) {
							col = col.r * 0.3 + col.g * 0.59 + col.b * 0.11; //B&W
							col /= 2;
						}
						else {
							col = aberration3D(i.uv);
						}
					}
					else {

						if ((uint)(p* _ScreenParams.y / floor(_LinesSize + noise)) % 2 != 0) {
							col = col.r * 0.3 + col.g * 0.59 + col.b * 0.11; //B&W
							col /= 2 ;
						}
						else {
							col = aberration3D(i.uv);
						}
					}
				}	
				

				return col + 0.05* floor(noise);
				
			}
			ENDCG
		}

		GrabPass{  }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD;
			};

			struct v2f
			{
				half4 pos: POSITION;
				float2 uv : TEXCOORD;
				fixed4 sPos : TEXCOORD1;
			};


			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.sPos = ComputeScreenPos(o.pos);
				return o;
			}

			

			sampler2D _MainTex;
			sampler2D _GrabTexture;
			float4 _GrabTexture_TexelSize;

			sampler2D _DisplacementTex;
			float _Strength;



			float4 frag(v2f i) : SV_Target
			{
				#if UNITY_UV_STARTS_AT_TOP
				if (_GrabTexture_TexelSize.y < 0)
						i.uv.y = 1 - i.uv.y;
				#endif
				
				fixed p = i.sPos.y / i.sPos.w;

				half2 n = tex2D(_DisplacementTex, i.uv);
				half2 d = n * 2 - 1;
				i.uv += d * _Strength;
				i.uv = saturate(i.uv);


				float4 col = tex2D(_GrabTexture, i.uv);

				return col;

			}
			ENDCG
		}
	}
}
