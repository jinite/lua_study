-- CH.15 Data Files and Serialization

-- 데이터 파일을 다룰 때, 데이터를 다시 읽는 것 보다 쓰는 것이 일반적으로 훨씬 쉽다. x

-- Data description은 1993년에 만들어진 Lua의 주요 어플리케이션 중 하나였다.
-- 당시 텍스트 기반의 data description은 SGML이 주류였다.
-- SGML이 복잡하였기에, 1998년에 이를 단순화하여 XML을 만들었고,
-- 2001년에 Javascript를 기반으로 JSON 만들어졌고, Lua 데이터 파일과 유사하다.
-- JSON은 국제표준이라는 큰 장점이 있어 여러 언어에서 JSON을 지원한다.
-- 제한된 형식의 Lua파일을 data description으로서 사용하면 읽어들이기가 명확하고 유연성을 가진다.

-- 프로그래밍의 소스코드 자체(Lua)를 data description의 용도로 사용하는 것은, 유연하지만 두가지 문제가 있다.
-- 1. 보안 : 데이터 파일이 프로그램 내에서 무분별하게 사용될 수 있다. 하지만 샌드박스에서 실행하여 문제를 해결할 수있다.
-- 2. 성능 : 소스코드가 data description으로 사용되므로, 매번 컴파일을 해야할 필요가 있다. 다만, Lua는 빠르게 실행될 뿐아니라 빠르게 컴파일 되므로 큰 문제가 되진 않는다.

print("\n-------------Data Files-------------")
-- Data description의 용도로 Lua파일을 이용할 경우, 일반적으로 다음과 같은 형식으로 처리 된다.

-- 파일명 : data
-- 본 파일이 data description의 용도로 사용되는 Lua 파일이다.
-- Entry{"Donald E. Knuth", "Literate Programming", "CSLI", 1992}
-- Entry{"Jon Bentley", "More Programming Pearls", "Addison-Wesley", 1990}

-- 파일명 : entry.lua
-- data파일에 보존된 데이터 수를 출력한다.
local count = 0
function Entry ()
	count = count + 1 
end
dofile("data")
print("number of entries: " .. count)

-- 다음과 같이 self-describing data format으로 하면, 형식을 수정하거나 사람이 직접 데이터 파일을 읽을 때 용이하다.
-- Entry{author = "Jon Bentley", title = "More Programming Pearls", year = 1990, publisher = "Addison-Wesley",}

print("\n-------------Serialization-------------")
-- 객체 등 개념적 구체화된 데이터는 순서를 가질수도 있고 아닐 수도 있지만,
-- 이에 상관없이 메모리에 보존하거나 네트워크상에 전달하기 위해, 일렬로 이어진 바이트의 나열로 표현할 필요가 있다.
-- 이것을 serialization직렬화 라고 한다.
-- 반대로, 직렬회된 데이터를 재구성(deserialization)하는 것도 가능하다.
-- data description 형식은 객체를 지정된 규칙의 텍스트의 형태로 표현하는 것이므로,
-- 객체를 data description 형식으로의 변환하는 작업은, 직렬화의 일종이라 할 수 있다.

-- 여기서는 Data description의 형식으로, 즉, Lua코드의 형태로 직렬화가 이루어지므로
-- 해당 코드를 그대로 컴파일용의 소스코드로 이용할 수 있으므로, 따로 역직렬화를 하기 위한 함수가 필요하지 않다.

-------------- 값의 직렬화
-- 정수의 직렬화
function serialize (o)
	if type(o) == "number" then
		io.write(tostring(o))
	else
	end
end

-- 정수와 부동소수점, 문자열의 직렬화
local fmt = {integer = "%d", float = "%a"}
function serialize (o)
	if type(o) == "number" then
		io.write(string.format(fmt[math.type(o)], o)) -- 정수/부동소수점
	elseif type(o) == "string" then
		io.write(string.format("%q", o)) -- 문자열
	else
	end
end

-- Lua 5.3.3 부터는 %q가 확장되어, 정수/부동소수점/문자열/불린형에 대해서 사용가능하게 되었으며
-- 특히, 부동소수점의 경우에는 정밀도를 보장하기 위해, 16진수로 저장한다.
-- 이를 이용해서 함수를 좀더 간소화하면,
function serialize (o)
	local t = type(o)
	if t == "number" or t == "string" or t == "boolean" or t == "nil" then
		io.write(string.format("%q", o))
	else
	end
end


-------------- 테이블의 직렬화
-- 테이블의 직렬화는 테이블 구조에 대해 어떤 가정을 하느냐에 따라 몇가지 방법으로 나뉠 수있다.

-- 1. 주기성이 없는 테이블의 직렬화 (테이블 생성자 형식을 이용)
function serialize (o)
	local t = type(o)
	if t == "number" or t == "string" or t == "boolean" or t == "nil" then
		return string.format("%q", o)
	elseif t == "table" then
		io.write("{\n")
		for k,v in pairs(o) do
			io.write(string.format(" [%s] = ", serialize (k)))
			io.write(serialize(v))
			io.write(",\n")
		end
		io.write("}\n")
	else
		error("cannot serialize a " .. type(o))
	end
end

-- 2. 주기성이 있는 테이블의 직렬화 (생성자 형식으로는 테이블을 만들 수 없음)
-- # 가정의 내용
-- - 주기성 : 자기가 자기자신을 참조하는 경우 ex) a[2] = a
-- - 공유된 하위테이블 : 하위테이블을 다른 변수에서 참조하는 경우 ex) a[1] = {3, 4, 5}; a.z = a[1]
-- - key 로는 string과 number만 허용
function basicSerialize (o)
	-- assume 'o' is a number or a string
	return string.format("%q", o)
end

function save (name, value, saved)
	saved = saved or {} -- initial value
	io.write(name, " = ")
	if type(value) == "number" or type(value) == "string" then
		io.write(basicSerialize(value), "\n")
	elseif type(value) == "table" then
		if saved[value] then -- value already saved?
			io.write(saved[value], "\n") -- use its previous name
		else
			saved[value] = name -- save name for next time
			io.write("{}\n") -- create a new table
			for k,v in pairs(value) do -- save its fields
				k = basicSerialize(k)
				local fname = string.format("%s[%s]", name, k)
				save(fname, v, saved)
			end
		end
	else
		error("cannot save a " .. type(value))
	end
end

-- end of chapter