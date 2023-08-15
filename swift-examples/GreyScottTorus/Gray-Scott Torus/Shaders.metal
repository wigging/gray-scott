#include <metal_stdlib>
using namespace metal;

struct SceneConstants { float4x4 projectionMatrix; };
struct ModelConstants { float4x4  modelViewMatrix; };

struct VertexShaderOut {
	float4 position [[ position ]];
	half4 color     [[ flat     ]];
};

constant half4 colors[3][8] = {
	{
		half4(0.01764705, 0.0512, 0.01210714, 1),
		half4(0.17647055, 0.1116, 0.07107143, 1),
		half4(0.35294109, 0.2232, 0.14214286, 1),
		half4(0.52941164, 0.3348, 0.21321429, 1),
		half4(0.70588219, 0.4464, 0.28428571, 1),
		half4(0.88235273, 0.558 , 0.35535714, 1),
		half4(1.        , 0.6696, 0.42642857, 1),
		half4(1.        , 0.7812, 0.4975    , 1),
	},
	{
		half4(0.267004, 0.004874, 0.329415, 1),
		half4(0.275191, 0.194905, 0.496005, 1),
		half4(0.212395, 0.359683, 0.551710, 1),
		half4(0.153364, 0.497000, 0.557724, 1),
		half4(0.122312, 0.633153, 0.530398, 1),
		half4(0.288921, 0.758394, 0.428426, 1),
		half4(0.626579, 0.854645, 0.223353, 1),
		half4(0.993248, 0.906157, 0.143936, 1),
	},
	{
		half4(0.21960784, 0.25882354, 0.5254902,  1),
		half4(0.23529412, 0.3019608,  0.5647059,  1),
		half4(0.16862746, 0.4392157,  0.5803922,  1),
		half4(0.1764706,  0.6,        0.59607846, 1),
		half4(0.32156864, 0.61960787, 0.27058825, 1),
		half4(0.7490196,  0.80784315, 0.21568628, 1),
		half4(0.9254902,  0.627451,   0.1882353,  1),
		half4(0.6627451,  0.19215687, 0.16862746, 1),
	}
};

float4 pointForTopology(float4 p, float4x4 matrix, int topology) {
	float x = p.x, y = p.y;
	
	if (topology == 0) {
		p.x = cos(x) * (3 + cos(y));
		p.y = sin(x) * (3 + cos(y));
		p.z = sin(y);
		p = matrix * p;
	}
	else if (topology == 1) {
		p = matrix * p;
	}
	else if (topology == 2) {
		p.x = x / 4.5;
		p.y = y / 4.5 - 0.1;
	}
	
	return p;
}

vertex VertexShaderOut vertexShader(
	constant          float & time            [[ buffer(0) ]],
	constant SceneConstants & sceneConstants  [[ buffer(1) ]],
	constant ModelConstants & modelConstants  [[ buffer(2) ]],
	const  device    float2 * vertices        [[ buffer(3) ]],
	const  device     float * cells           [[ buffer(4) ]],
	const  device       int & colorScheme     [[ buffer(5) ]],
	const  device       int & topology        [[ buffer(6) ]],
	const  device       int & topologyOld     [[ buffer(7) ]],
	const  device     float & interpolate     [[ buffer(8) ]],
	
	uint vertexId [[ vertex_id ]]
){
	float4x4 matrix = sceneConstants.projectionMatrix * modelConstants.modelViewMatrix;
	uint i = vertexId / 6;
	
	float4 p = float4(vertices[vertexId].x, vertices[vertexId].y, 0, 1);
	float4 q = p;
	p = pointForTopology(p, matrix, topology);
	
	VertexShaderOut vertexOut;
	
	if (0 < interpolate && interpolate < 1) {
		q = pointForTopology(q, matrix, topologyOld);
		p = p * interpolate + q * (1 - interpolate);
	}
	
	vertexOut.position = p;
	vertexOut.color = colors[colorScheme][(int)(cells[i] * 8)];
	
	return vertexOut;
}

fragment half4 fragmentShader(VertexShaderOut vertexIn [[ stage_in ]]) {
	return vertexIn.color;
}

void kernel grayScottCore(
	constant   int & side   [[ buffer(0) ]],
	constant float & du     [[ buffer(1) ]],
	constant float & dv     [[ buffer(2) ]],
	constant float & f      [[ buffer(3) ]],
	constant float & k      [[ buffer(4) ]],
	constant float * U      [[ buffer(5) ]],
	  device float * Unext  [[ buffer(6) ]],
	constant float * V      [[ buffer(7) ]],
	  device float * Vnext  [[ buffer(8) ]],
					   
	uint2 S [[ threads_per_threadgroup ]],
	uint2 W [[ threadgroups_per_grid   ]],
	uint2 z [[ thread_position_in_grid ]])
{
	uint i = z.x + z.y * S.y * W.x;
	
	if (side * side < int(i)) return;
	
	uint x = i % side, y = i / side;
	
	bool leftEdge = (0 == x);
	bool topEdge  = (0 == y);
	bool rightEdge  = (uint(side)-1 == x);
	bool bottomEdge = (uint(side)-1 == y);
	
	uint left  = !leftEdge   ? i - 1    : i + side - 1;
	uint right = !rightEdge  ? i + 1    : i - side + 1;
	uint up    = !topEdge    ? i - side : side * (side - 1) + i;
	uint down  = !bottomEdge ? i + side : i % side;
	
	//_________________________________________________________/ Gray-scott part:
	
	float uvv = U[i] * V[i] * V[i];
	
	float lapu = U[left] + U[right] + U[up] + U[down] - 4 * U[i];
	float lapv = V[left] + V[right] + V[up] + V[down] - 4 * V[i];
	
	Unext[i] = U[i] + du * lapu - uvv + f * (1 - U[i]);
	Vnext[i] = V[i] + dv * lapv + uvv - V[i] * (f + k);
}
