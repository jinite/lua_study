local mod1 = {}

local a = "init value"

mod1.init = function (value)
	
	a = value

	return mod1
end

mod1.showvalue = function ()
	print(a)
end

return mod1
