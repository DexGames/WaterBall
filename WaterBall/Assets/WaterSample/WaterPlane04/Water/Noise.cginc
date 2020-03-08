
float2 rand2d(float2 st, int seed)
{
	float2 s = float2(dot(st, float2(127.1, 311.7)) + seed, dot(st, float2(269.5, 183.3)) + seed);
	return -1.0 + 2.0 * frac(sin(s) * 43758.5453123);
}
 
float noise2(float2 st, int seed)
{
	float2 p = floor(st);
	float2 f = frac(st);
 
	float w00 = dot(rand2d(p, seed), f);
	float w10 = dot(rand2d(p + float2(1.0, 0.0), seed), f - float2(1.0, 0.0));
	float w01 = dot(rand2d(p + float2(0.0, 1.0), seed), f - float2(0.0, 1.0));
	float w11 = dot(rand2d(p + float2(1.0, 1.0), seed), f - float2(1.0, 1.0));
	
	float2 u = f * f * (3.0 - 2.0 * f);
 
	return lerp(lerp(w00, w10, u.x), lerp(w01, w11, u.x), u.y);
}
 
float3 rand3d(float3 p, int seed)
{
	float3 s = float3(
		dot(p, float3(127.1, 311.7,  74.7)) + seed,
		dot(p, float3(269.5, 183.3, 246.1)) + seed,
		dot(p, float3(113.5, 271.9, 124.6)) + seed);

	return -1.0 + 2.0 * frac(sin(s) * 43758.5453123);
}
 
float noise3(float3 st, int seed)
{
	float3 p = floor(st);
	float3 f = frac(st);
 
	float w000 = dot(rand3d(p, seed), f);
	float w100 = dot(rand3d(p + float3(1, 0, 0), seed), f - float3(1, 0, 0));
	float w010 = dot(rand3d(p + float3(0, 1, 0), seed), f - float3(0, 1, 0));
	float w110 = dot(rand3d(p + float3(1, 1, 0), seed), f - float3(1, 1, 0));
	float w001 = dot(rand3d(p + float3(0, 0, 1), seed), f - float3(0, 0, 1));
	float w101 = dot(rand3d(p + float3(1, 0, 1), seed), f - float3(1, 0, 1));
	float w011 = dot(rand3d(p + float3(0, 1, 1), seed), f - float3(0, 1, 1));
	float w111 = dot(rand3d(p + float3(1, 1, 1), seed), f - float3(1, 1, 1));
	
	float3 u = f * f * (3.0 - 2.0 * f);
 
	float r1 = lerp(lerp(w000, w100, u.x), lerp(w010, w110, u.x), u.y);
	float r2 = lerp(lerp(w001, w101, u.x), lerp(w011, w111, u.x), u.y);
 
	return lerp(r1, r2, u.z);
}
 
float fbm(float2 st, int seed) 
{
	float val = 0.0;
	float a = 0.5;
 
	for(int i = 0; i < 6; i++)
	{
		val += a * noise2(st, seed);
		st *= 2.0;
		a *= 0.5;
	}

	return val;
}
