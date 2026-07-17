return function(rune)
	rune.RegisterLibrary("math", {
		abs = math.abs,
		acos = math.acos,
		asin = math.asin,
		atan = math.atan,
		atan2 = math.atan,
		ceil = math.ceil,
		clamp = math.clamp,
		cos = math.cos,
		cosh = math.cosh,
		deg = math.deg,
		exp = math.exp,
		floor = math.floor,
		fmod = math.fmod,
		frexp = math.frexp,
		huge = math.huge,
		ldexp = math.ldexp,
		log = math.log,
		log10 = math.log10,
		max = math.max,
		min = math.min,
		modf = math.modf,
		pi = math.pi,
		pow = math.pow,
		rad = math.rad,
		random = math.random,
		randomseed = math.randomseed,
		round = math.round,
		sign = math.sign,
		sin = math.sin,
		sinh = math.sinh,
		sqrt = math.sqrt,
		tan = math.tan,
		tanh = math.tanh,

		lerp = function(a, b, t)
			return a + (b - a) * t
		end,

		map = function(x, inMin, inMax, outMin, outMax)
			return outMin + (x - inMin) * (outMax - outMin) / (inMax - inMin)
		end,

		dist = function(x1, y1, x2, y2)
			return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
		end,
	})
end
