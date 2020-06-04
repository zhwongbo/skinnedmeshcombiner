/////////////////
//描边outline
////////////////
float _Outline;
float4 _OutlineColor;
struct VertexInputOutline {
	float4 vertex : POSITION;
	float3 normal : NORMAL;
};
struct VertexOutputOutline {
	float4 pos : SV_POSITION;
	UNITY_FOG_COORDS(0)
};
VertexOutputOutline vertOutline(VertexInputOutline v) {
	VertexOutputOutline o = (VertexOutputOutline)0;
	o.pos = UnityObjectToClipPos(float4(v.vertex.xyz + v.normal * _Outline * 0.01, 1));
	UNITY_TRANSFER_FOG(o, o.pos);
	return o;
}
float4 fragOutline(VertexOutputOutline i) : COLOR{
	float4 finalCol = float4(_OutlineColor.rgb,1);
	UNITY_APPLY_FOG(i.fogCoord, finalCol);
	return finalCol;
}

//////////////////
//内发光rim
//////////////////
float _RimMin;
float _RimMax;
float _RimPower;
float4 _RimColor;
struct VertexInputRim
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
	float3 normal : NORMAL;
};
struct VertexOutputRim
{
	float2 uv : TEXCOORD0;
	float4 vertex : SV_POSITION;
	float3 worldNormal : TEXCOORD1;
	float3 worldViewDir :TEXCOORD2;
	UNITY_FOG_COORDS(0)
};
fixed4 ApplyRim(float3 worldViewDir,float3 worldNormal)
{
	float ndv = smoothstep(_RimMin, _RimMax, (1.0 - saturate(dot(worldViewDir, worldNormal))));
	return _RimColor * _RimPower * ndv;
}
VertexOutputRim vertRim(VertexInputRim v)
{
	VertexOutputRim o;
	o.vertex = UnityObjectToClipPos(v.vertex);
	o.uv = v.uv;
	o.worldNormal = UnityObjectToWorldNormal(v.normal);
	float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	o.worldViewDir = _WorldSpaceCameraPos.xyz - worldPos;
	UNITY_TRANSFER_FOG(o, o.vertex);
	return o;
}
fixed4 fragRim(VertexOutputRim i):COLOR
{
	float4 finalCol = ApplyRim(i.worldViewDir,i.worldNormal);
	UNITY_APPLY_FOG(i.fogCoord, finalCol);
	return finalCol;
}