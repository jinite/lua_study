
local JSON = require "JSON"
local TestModule = require "test-module"

local old = TestModule.readFile("securitysensor-old.json")
local new = TestModule.readFile("securitysensor-new.json")
local oldtbl = JSON:decode(old)
local newtbl = JSON:decode(new)

print("----------securitysensor-old.json")
TestModule.trvtbl(oldtbl)
print("-------------------------")
print("----------securitysensor-new.json")
TestModule.trvtbl(newtbl)
print("-------------------------")

local difftbl1 = TestModule.difftbl(oldtbl,newtbl,TestModule.DIFFTBL.INVISIBLE,TestModule.DIFFTBL.INVISIBLE)
print("----------difftbl1")
TestModule.trvtbl(difftbl1)
print("-------------------------")




--local raw_json_text    = JSON:encode(lua_value)        -- encode example
--local pretty_json_text = JSON:encode_pretty(lua_value) -- "pretty printed" version

--TestModule.trvtbl(lua_value)
