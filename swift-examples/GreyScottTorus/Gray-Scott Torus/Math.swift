import simd

func matrixFromPerspectiveFOVAspectLH(fovY: Float, aspect: Float, nearZ: Float, farZ: Float) -> float4x4 {
	let yscale = 1.0 / tanf(fovY * 0.5 )
	let xscale = yscale / aspect
	let q = farZ / (farZ - nearZ)
	
	let m = float4x4([
		[xscale, 0,          0, 0],
		[0, yscale,          0, 0],
		[0,      0, q         , 1],
		[0,      0, q * -nearZ, 0]
		])
	
	return m
}

func matrixFromRotation(radians: Float, x: Float, y: Float, z: Float) -> float4x4 {
	let v = vectorNormalize(x: x, y: y, z: z)
	let sin = sinf(radians)
	let cos = cosf(radians)
	let cosp = 1 - cos
	
	let m00 = cos + cosp * v.x * v.x
	let m01 = cosp * v.x * v.y + v.z * sin
	let m02 = cosp * v.x * v.z - v.y * sin
	
	let m10 = cosp * v.x * v.y - v.z * sin
	let m11 = cos + cosp * v.y * v.y
	let m12 = cosp * v.y * v.z + v.x * sin
	
	let m20 = cosp * v.x * v.z + v.y * sin
	let m21 = cosp * v.y * v.z - v.x * sin
	let m22 = cos + cosp * v.z * v.z
	
	let m = float4x4([
		[m00,m01,m02,0],
		[m10,m11,m12,0],
		[m20,m21,m22,0],
		[  0,  0,  0,1],
	])
	
	return m
}

func matrixFromTranslation(x: Float, y: Float, z: Float) -> float4x4 {
	var m = matrix_identity_float4x4
	m.columns.3 = [x, y, z, 1.0]
	return m
}

func vectorNormalize(x:Float, y: Float, z: Float) -> vector_float3 {
	let magnitude = sqrtf(x * x + y * y + z * z)
	return vector_float3( [ x/magnitude, y/magnitude, z/magnitude ] )
}
