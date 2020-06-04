Shader "PJAQ/Character/ToonV5" {
    Properties {
        //DIFFUSE
        _MainTex ("Main Texture (RGB)", 2D) = "white" {}
        [NoScaleOffset] _MaskTex ("Mask Texture Spec/Refl(R) Emission(G) UV(B)", 2D) = "white" {}

        //_LightColor ("Light Color", Color) = (1,1,1,1)

        //SHADOW
        _HColor ("Highlight Color", Color) = (1,1,1,1)
        _SColor ("Shadow Color", Color) = (0.5,0.5,0.5,1)

        //NORMAL
        [NoScaleOffset] _Normal ("#NORMAL# Normal", 2D) = "bump" {}

        //COLORING
        [NoScaleOffset] _SplatTex ("#COLORING# Coloring Map (Defualt Red)", 2D) = "red" {}
        _Color ("#COLORING# Color0 (r)", Color) = (1,1,1,1)
        _Color1 ("#COLORING# Color1 (g)", Color) = (1,1,1,1)
        _Color2 ("#COLORING# Color2 (b)", Color) = (1,1,1,1)
        _Color3 ("#COLORING# Color3 (1-r-g-b)", Color) = (1,1,1,1)

        //SHADOW RAMP
        [NoScaleOffset] _Ramp ("#RAMPT# Ramp (RGB)", 2D) = "gray" {}
        _RampThreshold ("#RAMPF# RampThreshold", Range(0, 1)) = 0.8
        _RampSmooth ("#RAMPF# RampSmooth", Range(0, 1)) = 0.1

        //SPECULAR
        _Specular ("#SPEC# SpecColor", Color) = (0.5,0.5,0.5,1)
        _Gloss ("#SPEC# Gloss", Range(0, 1)) = 0.5
        //_SpecularAL ("#REFL# SpecularAL", Cube) = "_Skybox" {}
        [NoScaleOffset] _MatCap ("#REFL# MatCap (RGB)", 2D) = "white" {}
        _SpecularAO ("#REFL# SpecularAO", Range(0, 1)) = 0.5

        //RIM LIGHT
        _RimColor ("#RIM# RimColor", Color) = (0.8,0.8,0.8,0.6)
        _RimMin ("#RIM# RimMin", Range(0, 1)) = 0.5
        _RimMax ("#RIM# RimMax", Range(0, 1)) = 1

        _Hight ("#RIM# Hight", Range(0, 5)) = 2
        _Offset ("#RIM# Offset", Range(-2, 0)) = -0.5

        //EMISSION
        _Emission ("#EMISSION# Emission", Color) = (0.5,0.5,0.5,1)
        //_EmissionTex ("#EMISSION# Emission Mask", 2D) = "white" {}

        //UV
        _LightMap ("#UV# LightMap", 2D) = "black" {}
        _XOffset ("#UV# XOffset", Range(0, 1)) = 0
        _YOffset ("#UV# YOffset", Range(0, 1)) = 0

        //OUTLINE
        _Outline ("#OUTLINE# Outline", Range(0, 10)) = 0.5
        _OutlineColor ("#OUTLINE# OutlineColor", Color) = (0,0,0,1)
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }

        LOD 600

        Pass {
            Name "Outline"
            Cull Front
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Assets/GameAssets/Shaders/CGIncludes/PJAQ.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 
            #pragma target 3.0
            #pragma vertex vertOutline
            #pragma fragment fragOutline
            ENDCG
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile _ _NORMAL_ON
            #pragma multi_compile _ _RAMPTEXT_ON
            #pragma multi_compile _ _COLORING_ON
            #pragma multi_compile _ _SPECULAR_ON
            #pragma multi_compile _ _REFLECT_ON
            #pragma multi_compile _ _EMISSION_ON
            #pragma multi_compile _ _UV_ANIM_ON
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
			#pragma skip_variants _COLORING_ON
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _MaskTex;
#if _NORMAL_ON
            uniform sampler2D _Normal;
#endif
#if _COLORING_ON
            uniform sampler2D _SplatTex;
            uniform float4 _Color;
            uniform float4 _Color1;
            uniform float4 _Color2;
            uniform float4 _Color3;
#endif
			//uniform float4 _LightColor;
            uniform float4 _HColor;
            uniform float4 _SColor;
#if _RAMPTEXT_ON
            uniform sampler2D _Ramp;
#else
            uniform float _RampThreshold;
            uniform float _RampSmooth;
#endif
#if _SPECULAR_ON
            uniform float4 _Specular;
            uniform float _Gloss;
#endif
#if _REFLECT_ON
            uniform sampler2D _MatCap;
            uniform float _SpecularAO;
#endif
            uniform float4 _RimColor;
            uniform float _RimMin;
            uniform float _RimMax;
            uniform float _Hight;
            uniform float _Offset;
#if _EMISSION_ON
            uniform float4 _Emission;
            //uniform sampler2D _EmissionTex; uniform float4 _EmissionTex_ST;
#endif
#if _UV_ANIM_ON
            uniform sampler2D _LightMap; uniform float4 _LightMap_ST;
            uniform float _XOffset;
            uniform float _YOffset;
#endif
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
#if _NORMAL_ON
                float4 tangent : TANGENT;
#endif
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
#if _NORMAL_ON
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
                LIGHTING_COORDS(5,6)
                UNITY_FOG_COORDS(7)
#else
                LIGHTING_COORDS(3,4)
                UNITY_FOG_COORDS(5)
#endif

#if _REFLECT_ON
                float2 matcap : TEXCOORD6;
#endif
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                //float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
#if _NORMAL_ON
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
#endif
#if _REFLECT_ON
			//MATCAP
			    float3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
			    worldNorm = mul((float3x3)UNITY_MATRIX_V, worldNorm);
			    o.matcap.xy = worldNorm.xy * 0.5 + 0.5;
#endif

                UNITY_TRANSFER_FOG(o,o.pos);
//#if _LIGHT_ON
                TRANSFER_VERTEX_TO_FRAGMENT(o)
//#endif
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                float4 objPos = mul ( unity_ObjectToWorld, float4(0,0,0,1) );
                float normalizedHight = saturate(( (i.posWorld.g - objPos.g) - _Offset ) / _Hight);
#if _NORMAL_ON
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalLocal = UnpackNormal(tex2D(_Normal, i.uv0));
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform ));
#else
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
#endif
#if _REFLECT_ON
                //float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
#endif
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 halfDirection = normalize(viewDirection+lightDirection);

                float4 mask = tex2D(_MaskTex, i.uv0);
                //fixed ndl = max(0, dot(normalDirection,lightDirection));
                //light wrap
                fixed ndl = max(0, (dot(normalDirection,lightDirection)*0.5+0.5));

////// Lighting:
                float3 lightColor = _LightColor0.rgb;//float3(1,1,1);
                //float attenuation = LIGHT_ATTENUATION(i);
                //UNITY_LIGHT_ATTENUATION(attenuation, i, i.posWorld)
                float attenuation = 1.0;
                float3 attenColor = attenuation * lightColor.rgb;
////// Emissive:
                float rim = smoothstep( _RimMin, _RimMax, (1.0 - saturate(dot(viewDirection,normalDirection))) );
                rim *= normalizedHight;
#if _EMISSION_ON
                //fixed3 emission = tex2D(_EmissionTex,TRANSFORM_TEX(i.uv0, _EmissionTex)) * _Emission.rgb * _Emission.a;
                fixed3 emission = _Emission.rgb * _Emission.a * mask.g;
#else
                fixed3 emission = fixed3(0,0,0);
#endif

#if _UV_ANIM_ON
                //fixed2 uv = (i.uv0+(_Time.g*_XOffset)*fixed2(1,0))+(_Time.g*_YOffset)*fixed2(0,1);
                fixed2 uv = i.uv0 + fixed2(_Time.g * _XOffset, _Time.g * _YOffset);
                float4 light = tex2D(_LightMap,TRANSFORM_TEX(uv, _LightMap));
                emission += light.rgb * light.a * mask.b;
#endif

                emission += _RimColor.rgb * rim * _RimColor.a * ndl;
//////// Diffuse:
                //fixed ndl = max(0, dot(normalDirection,lightDirection));
                //light wrap
                //fixed ndl = max(0, (dot(normalDirection,lightDirection)*0.5+0.5));

                fixed3 SColor = lerp(_HColor.rgb,_SColor.rgb,_SColor.a);
                fixed3 HColor = _HColor.rgb;

#if _RAMPTEXT_ON
                fixed3 ramp = tex2D(_Ramp, fixed2(ndl,ndl));
#else
                fixed3 ramp = smoothstep( (_RampThreshold-(_RampSmooth*0.5)), (_RampThreshold+(_RampSmooth*0.5)), ndl );
#endif
                ramp *= attenuation;
                ramp = lerp(SColor.rgb,HColor.rgb,ramp);

                fixed3 directDiffuse = lightColor * ramp;

                fixed3 indirectDiffuse = float3(0,0,0);

                // Ambient Light
                //indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb;

                float4 main = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));

#if _COLORING_ON
                fixed3 splat = tex2D(_SplatTex, i.uv0);
                float3 color = _Color.rgb * splat.r + _Color1.rgb * splat.g + _Color2.rgb * splat.b + _Color3.rgb * (1 - splat.r - splat.g - splat.b); 
                float3 diffuseColor = (color * main.rgb);
#else
                //float3 color = _Color.rgb;
                float3 diffuseColor = main.rgb;
#endif
                //float3 diffuseColor = (color * main.rgb);
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
////// Specular:
#if _SPECULAR_ON
                fixed ndh = max(0.0,dot(halfDirection,normalDirection));
                fixed specPow = exp2( _Gloss * 10.0 + 1.0 );
                fixed3 specularColor = _Specular.rgb;
                fixed3 directSpecular = attenColor * pow(max(0, dot(halfDirection, normalDirection)), specPow) * specularColor;
#else
                fixed3 directSpecular = fixed3(0,0,0);
#endif
#if _REFLECT_ON
                fixed3 specularAO = _SpecularAO;
                //fixed3 indirectSpecular = texCUBE(_SpecularAL, viewReflectDirection).rgb * specularAO;
                fixed3 indirectSpecular = tex2D(_MatCap, i.matcap).rgb * specularAO;
				#if _SPECULAR_ON
                indirectSpecular *= specularColor;
				#endif
#else
                fixed3 indirectSpecular = fixed3(0,0,0);
#endif
                fixed gloss = mask.r;
                float3 specular = (directSpecular + indirectSpecular) * gloss;
/// Final Color:
                float3 finalColor = emission + diffuse + specular;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);


                return finalRGBA;
            }
            ENDCG
        }
    }

    SubShader {
        Tags {
            "RenderType"="Opaque"
        }

        LOD 300

        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile _ _NORMAL_ON
            #pragma multi_compile _ _RAMPTEXT_ON
            #pragma multi_compile _ _COLORING_ON
            #pragma multi_compile _ _SPECULAR_ON
            #pragma multi_compile _ _REFLECT_ON
            #pragma multi_compile _ _EMISSION_ON
            #pragma multi_compile _ _UV_ANIM_ON
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
			#pragma skip_variants _COLORING_ON
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _MaskTex;
#if _NORMAL_ON
            uniform sampler2D _Normal;
#endif
#if _COLORING_ON
            uniform sampler2D _SplatTex;
            uniform float4 _Color;
            uniform float4 _Color1;
            uniform float4 _Color2;
            uniform float4 _Color3;
#endif
			//uniform float4 _LightColor;
            uniform float4 _HColor;
            uniform float4 _SColor;
#if _RAMPTEXT_ON
            uniform sampler2D _Ramp;
#else
            uniform float _RampThreshold;
            uniform float _RampSmooth;
#endif
#if _SPECULAR_ON
            uniform float4 _Specular;
            uniform float _Gloss;
#endif
#if _REFLECT_ON
            uniform sampler2D _MatCap;
            uniform float _SpecularAO;
#endif
            uniform float4 _RimColor;
            uniform float _RimMin;
            uniform float _RimMax;
            uniform float _Hight;
            uniform float _Offset;
#if _EMISSION_ON
            uniform float4 _Emission;
            //uniform sampler2D _EmissionTex; uniform float4 _EmissionTex_ST;
#endif
#if _UV_ANIM_ON
            uniform sampler2D _LightMap; uniform float4 _LightMap_ST;
            uniform float _XOffset;
            uniform float _YOffset;
#endif
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
#if _NORMAL_ON
                float4 tangent : TANGENT;
#endif
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
#if _NORMAL_ON
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
                LIGHTING_COORDS(5,6)
                UNITY_FOG_COORDS(7)
#else
                LIGHTING_COORDS(3,4)
                UNITY_FOG_COORDS(5)
#endif

#if _REFLECT_ON
                float2 matcap : TEXCOORD6;
#endif
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                //float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
#if _NORMAL_ON
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
#endif
#if _REFLECT_ON
			//MATCAP
			    float3 worldNorm = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
			    worldNorm = mul((float3x3)UNITY_MATRIX_V, worldNorm);
			    o.matcap.xy = worldNorm.xy * 0.5 + 0.5;
#endif

                UNITY_TRANSFER_FOG(o,o.pos);
//#if _LIGHT_ON
                TRANSFER_VERTEX_TO_FRAGMENT(o)
//#endif
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                float4 objPos = mul ( unity_ObjectToWorld, float4(0,0,0,1) );
                float normalizedHight = saturate(( (i.posWorld.g - objPos.g) - _Offset ) / _Hight);
#if _NORMAL_ON
                float3x3 tangentTransform = float3x3( i.tangentDir, i.bitangentDir, i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalLocal = UnpackNormal(tex2D(_Normal, i.uv0));
                float3 normalDirection = normalize(mul( normalLocal, tangentTransform ));
#else
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
#endif
#if _REFLECT_ON
                //float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
#endif
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 halfDirection = normalize(viewDirection+lightDirection);

                float4 mask = tex2D(_MaskTex, i.uv0);
                //fixed ndl = max(0, dot(normalDirection,lightDirection));
                //light wrap
                fixed ndl = max(0, (dot(normalDirection,lightDirection)*0.5+0.5));

////// Lighting:
                float3 lightColor = _LightColor0.rgb;//float3(1,1,1);
                //float attenuation = LIGHT_ATTENUATION(i);
                //UNITY_LIGHT_ATTENUATION(attenuation, i, i.posWorld)
                float attenuation = 1.0;
                float3 attenColor = attenuation * lightColor.rgb;
////// Emissive:
                float rim = smoothstep( _RimMin, _RimMax, (1.0 - saturate(dot(viewDirection,normalDirection))) );
                rim *= normalizedHight;
#if _EMISSION_ON
                //fixed3 emission = tex2D(_EmissionTex,TRANSFORM_TEX(i.uv0, _EmissionTex)) * _Emission.rgb * _Emission.a;
                fixed3 emission = _Emission.rgb * _Emission.a * mask.g;
#else
                fixed3 emission = fixed3(0,0,0);
#endif

#if _UV_ANIM_ON
                //fixed2 uv = (i.uv0+(_Time.g*_XOffset)*fixed2(1,0))+(_Time.g*_YOffset)*fixed2(0,1);
                fixed2 uv = i.uv0 + fixed2(_Time.g * _XOffset, _Time.g * _YOffset);
                float4 light = tex2D(_LightMap,TRANSFORM_TEX(uv, _LightMap));
                emission += light.rgb * light.a * mask.b;
#endif

                emission += _RimColor.rgb * rim * _RimColor.a * ndl;
//////// Diffuse:
                //fixed ndl = max(0, dot(normalDirection,lightDirection));
                //light wrap
                //fixed ndl = max(0, (dot(normalDirection,lightDirection)*0.5+0.5));

                fixed3 SColor = lerp(_HColor.rgb,_SColor.rgb,_SColor.a);
                fixed3 HColor = _HColor.rgb;

#if _RAMPTEXT_ON
                fixed3 ramp = tex2D(_Ramp, fixed2(ndl,ndl));
#else
                fixed3 ramp = smoothstep( (_RampThreshold-(_RampSmooth*0.5)), (_RampThreshold+(_RampSmooth*0.5)), ndl );
#endif
                ramp *= attenuation;
                ramp = lerp(SColor.rgb,HColor.rgb,ramp);

                fixed3 directDiffuse = lightColor * ramp;

                fixed3 indirectDiffuse = float3(0,0,0);

                // Ambient Light
                //indirectDiffuse += UNITY_LIGHTMODEL_AMBIENT.rgb;

                float4 main = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));

#if _COLORING_ON
                fixed3 splat = tex2D(_SplatTex, i.uv0);
                float3 color = _Color.rgb * splat.r + _Color1.rgb * splat.g + _Color2.rgb * splat.b + _Color3.rgb * (1 - splat.r - splat.g - splat.b); 
                float3 diffuseColor = (color * main.rgb);
#else
                //float3 color = _Color.rgb;
                float3 diffuseColor = main.rgb;
#endif
                //float3 diffuseColor = (color * main.rgb);
                float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
////// Specular:
#if _SPECULAR_ON
                fixed ndh = max(0.0,dot(halfDirection,normalDirection));
                fixed specPow = exp2( _Gloss * 10.0 + 1.0 );
                fixed3 specularColor = _Specular.rgb;
                fixed3 directSpecular = attenColor * pow(max(0, dot(halfDirection, normalDirection)), specPow) * specularColor;
#else
                fixed3 directSpecular = fixed3(0,0,0);
#endif
#if _REFLECT_ON
                fixed3 specularAO = _SpecularAO;
                //fixed3 indirectSpecular = texCUBE(_SpecularAL, viewReflectDirection).rgb * specularAO;
                fixed3 indirectSpecular = tex2D(_MatCap, i.matcap).rgb * specularAO;
				#if _SPECULAR_ON
                indirectSpecular *= specularColor;
				#endif
#else
                fixed3 indirectSpecular = fixed3(0,0,0);
#endif
                fixed gloss = mask.r;
                float3 specular = (directSpecular + indirectSpecular) * gloss;
/// Final Color:
                float3 finalColor = emission + diffuse + specular;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "AQ.ToonShaderGUI2"
}
