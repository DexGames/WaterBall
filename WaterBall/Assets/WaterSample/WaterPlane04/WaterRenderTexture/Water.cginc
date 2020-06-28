#include "Noise.cginc"

float4 _Amplitude;
float4 _Frequency;
float4 _Steepness;
float4 _Speed;
float4 _DirectionA;
float4 _DirectionB;
float4 _Noise;
 
float4 _Amplitude2;
float4 _Frequency2;
float4 _Steepness2;
float4 _Speed2;
float4 _DirectionC;
float4 _DirectionD;
float4 _Noise2;

float _NoiseStrength;
float _NoiseSizeLerp;
 
static const float amplitude[8] = {_Amplitude.x, _Amplitude.y, _Amplitude.z, _Amplitude.w, _Amplitude2.x, _Amplitude2.y, _Amplitude2.z, _Amplitude2.w};
static const float frequency[8] = {_Frequency.x, _Frequency.y, _Frequency.z, _Frequency.w, _Frequency2.x, _Frequency2.y, _Frequency2.z, _Frequency2.w};
static const float steepness[8] = {_Steepness.x, _Steepness.y, _Steepness.z, _Steepness.w, _Steepness2.x, _Steepness2.y, _Steepness2.z, _Steepness2.w};
static const float speed[8] = {_Speed.x, _Speed.y, _Speed.z, _Speed.w, _Speed2.x, _Speed2.y, _Speed2.z, _Speed2.w};
static const float2 dir[8] = {_DirectionA.xy, _DirectionA.zw, _DirectionB.xy, _DirectionB.zw, _DirectionC.xy, _DirectionC.zw, _DirectionD.xy, _DirectionD.zw};
static const float noiseSize[8] = {_Noise.x, _Noise.y, _Noise.z, _Noise.w, _Noise2.x, _Noise2.y, _Noise2.z, _Noise2.w};
 
float _WaveTimeSpeed;

float4 _WaterBaseColor;
float4 _WaterShallowColor;
float _WaterBaseColorStrength;
float _WaterHeightColorCoef;
 
float3 GerstnerWave(float2 amplitude, float frequency, float steepness, float speed, float2 dir, float noise, float2 v, float time, int seed)
{
	float3 p;
	float2 d = normalize(dir.xy);
	float q = steepness;
 
	seed *= 3;
	v += noise2(v * noise + time, seed) * _NoiseStrength;
	float f = dot(d, v) * frequency + time * speed;
	p.xz = q * amplitude * d.xy * cos(f);
	p.y = amplitude * sin(f);
 
	return p;
}

float3 GerstnerWave_Cross(float2 amplitude, float frequency, float steepness, float speed, float2 dir, float noise, float2 v, float time, int seed)
{
	float3 p;
	float2 d = normalize(dir.xy);
	float q = steepness;
	seed *= 3;
 
	float3 p1;
	float3 p2;
	float2 d1 = normalize(dir.xy);
	float2 d2 = float2(-d.y, d.x);
 
	float2 v1 = v + noise2(v * noise + time * d * 10.0, seed) * _NoiseStrength;
	float2 v2 = v + noise2(v * noise + time * d * 10.0, seed + 12) * _NoiseStrength;
	float2 f1 = dot(d1, v) * frequency + time * speed;
	float2 f2 = dot(d2, v) * frequency + time * speed;
	p1.xz = q * amplitude * d1.xy * cos(f1);
	p1.y = amplitude * sin(f1);
	p2.xz = q * amplitude * d2.xy * cos(f2);
	p2.y = amplitude * sin(f2);
 
	p = lerp(p1, p2, noise2(v * _NoiseSizeLerp + time, seed) * 0.5 + 0.5);
 
	return p;
}
