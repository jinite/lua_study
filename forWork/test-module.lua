local _M = {}

local difftbl
local pairsByKeys
local trvtbl
local readFile

local DIFFTBL = {
	VISIBLE = nil,
	INVISIBLE = 1
}

-- table difference
difftbl = function (t1, t2, t1Mode, t2Mode)
	local result = {}
	if type(t1) == "table" and type(t2) == "nil" then
		for k, v in pairs(t1) do
			if type(v) ~= "table" then
				result[k] = v
			else
				result[k] = difftbl(v)
			end
		end
	else
		for k, v in pairs(t1) do
			if type(v) == "table" then
				if type(t2[k]) == "table" then
					-- table -> table
					result[k] = difftbl(v, t2[k])
				else
					-- table -> value(nil)
					if t1Mode == DIFFTBL.VISIBLE then
						result[k] = {difftbl(v), "-> " .. tostring(t2[k])}
					elseif t1Mode == DIFFTBL.INVISIBLE then
						result[k] = "(table) -> " .. tostring(t2[k])
					end
				end
			else
				if type(t2[k]) == "table" then
					-- value -> table
					if t2Mode == DIFFTBL.VISIBLE then
						result[k] = {tostring(v) .. " ->", difftbl(t2[k])}
					elseif t2Mode == DIFFTBL.INVISIBLE then
						result[k] = tostring(v) .. " -> (table)"
					end
				else
					-- value -> value(nil)
					if v ~= t2[k] then
						result[k] = tostring(v) .. " -> " .. tostring(t2[k])
					end
				end
			end
		end
		for k, v in pairs(t2) do
			if t1[k] == nil then
				if type(v) == "table" then
					-- nil -> table
					if t2Mode == DIFFTBL.VISIBLE then
						result[k] = {tostring(nil) .. " ->", difftbl(v)}
					elseif t2Mode == DIFFTBL.INVISIBLE then
						result[k] = tostring(nil) .. " -> (table)"
					end
				else
					-- nil -> value
					result[k] = tostring(nil) .. " -> " .. tostring(v)
				end
			end
		end
	end
	return result
end

-- table transverse and print
trvtbl = function (tbl, tab)
	if tab == nil then tab = 0 end
	local space = ""
	for _ = 1, tab, 1 do
		space = space .. "\t"
	end
	for k, v in pairsByKeys(tbl) do
		if type(v) == "table" then
			print(space .. tostring(k) .. " : " .. "(table)")
			trvtbl(v, tab + 1)
		else
			print(space .. tostring(k) .. " : " .. tostring(v))
		end
	end
end

-- alphabetical transverse iterator factory
pairsByKeys = function (t, f)
	local a = {}
	for n in pairs(t) do -- create a list with all keys
		a[#a + 1] = n
	end
	table.sort(a, f) -- sort the list
	local i = 0 -- iterator variable
	return function () -- iterator function
		i = i + 1
		return a[i], t[a[i]] -- return key, value
	end
end

readFile = function (filePath)
	local f = assert(io.open(filePath, "r"))
	local t = f:read("a")
	f:close()
	return t
end

_M = {
	DIFFTBL = DIFFTBL,
	difftbl = difftbl,
	trvtbl = trvtbl,
	readFile = readFile,
}
return _M
