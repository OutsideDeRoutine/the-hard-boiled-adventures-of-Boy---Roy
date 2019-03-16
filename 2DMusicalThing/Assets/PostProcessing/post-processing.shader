Shader "Custom/ScreenEffect"
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
		_NoiseSize("Noise Size",Range(0, 0.5)) = 0.005
		_NoiseLines("Noise Lines",float) = 1
	    _NoiseVel("Noise Velocity",float) = 1
		_NoiseTraslation("Noise Traslation",float) = 1
		_NoiseIntensity("Noise Intensity",float) = 1
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
				float3 noise_uv : TEXCOORD2;
			};


			sampler2D _MainTex, _CameraDepthTexture;
			float _LinesSize;
			float _MiddleLine;

			float _AberrationDist;
			sampler2D _DisplacementTex;
			float _Strength;

			float _focusDistance;
			float _focusRange;

			float _NoiseSize;
			float _NoiseVel;
			float _NoiseLines;
			float _NoiseIntensity;
			float _NoiseTraslation;

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.sPos = ComputeScreenPos(o.pos);
				o.noise_uv = v.vertex.xyz / v.vertex.w;
				o.noise_uv.x *= _NoiseTraslation;
				return o;
			}



			float random(float p)
			{
				float x = (_Time.y * _NoiseVel) + (frac(p) * 2);
				return (abs(sin(x / (0.6 / _NoiseLines))));
			}


			float hash(float n)
			{
				return frac(sin(n / _Time.y)*43758.5453);
			}

			float makeNoise(float3 x)
			{
				// The noise function returns a value in the range -1.0f -> 1.0f

				float3 p = floor(x);
				float3 f = frac(x);

				f = f * f*(3.0 - 2.0*f);
				float n = p.x + p.y*57.0 + 113.0*p.z;

				return lerp(lerp(lerp(hash(n + 0.0), hash(n + 1.0), f.x),
					lerp(hash(n + 57.0), hash(n + 58.0), f.x), f.y),
					lerp(lerp(hash(n + 113.0), hash(n + 114.0), f.x),
						lerp(hash(n + 170.0), hash(n + 171.0), f.x), f.y), f.z);
			}


			float4 aberration3D(float2 uv) {
				fixed4 col = fixed4(1, 1, 1, 1);

				float2 red_uv = uv + float2(_AberrationDist / _ScreenParams.x, 0);
				float2 blue_uv = uv + float2(_AberrationDist / _ScreenParams.x, 0);

				col.r = tex2D(_MainTex, red_uv).r;
				col.g = tex2D(_MainTex, uv).g;
				col.b = tex2D(_MainTex, blue_uv).b;

				return col;
			}


			float4 frag (v2f i) : SV_Target
			{
				float4 col = tex2D(_MainTex, i.uv);

				float noise = _NoiseSize==0? 0:((1+_NoiseSize) * random(i.sPos.y));

				if (floor(noise) > 0) {
					col = tex2D(_MainTex, i.noise_uv) * _NoiseIntensity;
					//col /= makeNoise(500000 * (normalize(i.noise_uv))); //ruido
					//col.rgb = (1 - col); col.rgb *= col.a; //invertir colores
					_AberrationDist *= _NoiseIntensity;
				}

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
						if ((uint)(p* _ScreenParams.y / floor(_LinesSize )) % 2 == 0) {
							col = col.r * 0.3 + col.g * 0.59 + col.b * 0.11; //B&W
							col /= 2;
						}
						else {
							col = aberration3D(i.uv);
						}
					}
					else {
						if ((uint)(p* _ScreenParams.y / floor(_LinesSize )) % 2 != 0) {
							col = col.r * 0.3 + col.g * 0.59 + col.b * 0.11; //B&W
							col /= 2 ;
						}
						else {
							col = aberration3D(i.uv);
						}
					}
				}	

				return col;
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


				float4 col = tex2D(_GrabTexture, i.uv);

				return col;

			}
			ENDCG
		}
	}
}
