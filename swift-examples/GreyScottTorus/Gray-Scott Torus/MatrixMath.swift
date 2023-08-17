/**
 * Copyright © 2016 Caroline Begbie. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * Mathematical functions are courtesy of Warren Moore and his
 * excellent book Metal By Example. Thank you.
 * http://metalbyexample.com
 *
 * Any mathematical errors are my own.
 *
 */

import simd

typealias float4 = SIMD4<Float>
typealias float2 = SIMD2<Float>

extension matrix_float4x4 {
	init(translationX x: Float, y: Float, z: Float) {
		self.init()
		
		columns = (
			float4(1, 0, 0, 0),
			float4(0, 1, 0, 0),
			float4(0, 0, 1, 0),
			float4(x, y, z, 1)
		)
	}
	
	init(rotationAngle angle: Float, x: Float, y: Float, z: Float) {
		let c = cos(angle)
		let s = sin(angle)
		
		var column0 = float4(repeating: 0)
		column0.x = x * x + (1 - x * x) * c
		column0.y = x * y * (1 - c) - z * s
		column0.z = x * z * (1 - c) + y * s
		column0.w = 0
		
		var column1 = float4(repeating: 0)
		column1.x = x * y * (1 - c) + z * s
		column1.y = y * y + (1 - y * y) * c
		column1.z = y * z * (1 - c) - x * s
		column1.w = 0.0
		
		var column2 = float4(repeating: 0)
		column2.x = x * z * (1 - c) - y * s
		column2.y = y * z * (1 - c) + x * s
		column2.z = z * z + (1 - z * z) * c
		column2.w = 0.0
		
		self.init()
		
		let column3 = float4(0, 0, 0, 1)
		
		columns = (column0, column1, column2, column3)
	}
	
	init(projectionFov fov: Float, aspect: Float, nearZ: Float, farZ: Float) {
		let y = 1 / tan(fov * 0.5)
		
		self.init()
		
		let x = y / aspect
		let z = farZ / (nearZ - farZ)
		
		columns = (
			float4(x, 0, 0,  0),
			float4(0, y, 0,  0),
			float4(0, 0, z, -1),
			float4(0, 0, z * nearZ, 0)
		)
	}
}
