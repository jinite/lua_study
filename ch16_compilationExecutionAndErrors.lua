-- CH.16 Compilation, Execution, and Errors

-- Lua가 인터프리터 언어이기는 하지만, 실행 전에는 항상 소스코드를 중간형식으로 컴파일한다.(다른 인터프리터 언어도 마찬가지)
-- 인터프리터 언어의 구별되는 특징은, 컴파일 단계가 존재하지 않는 다는 것이아니라,
-- 생성된 코드를 즉석에서 간단하게 실행가능하다는 것이다.
-- dofile같은 함수의 존재가 Lua에게 인터프리터 언어의 특성을 부여한다고 말할 수 있다.
-- 본 챕터에서는 Lua의 프로세스, 컴파일, 오류처리 등에 대해 자세하게 설명한다.

print("\n-------------Compilation-------------") -- load를 이용한 특정 chunk의 컴파일 정의와 사용
-- dofile의 실제 구조
function dofile2 (filename)
	local f = assert(loadfile(filename)) -- 파일를 불러와서 청크를 컴파일하고 함수형태로 반환
	return f() -- 함수(청크)를 실행하고 청크의 return값을 반환
end

-- loadfile은 dofile보다 유연하다.
-- loadfile을 사용하면, dofile과는 달리 사용자가 직접 에러 처리가 가능하고,
-- loadfile은 컴파일된 결과를 재사용할 수 있으므로, 비용이 적게 든다.

-- load는 문자열에서 청크를 읽는다는 점을 제외하면, loadfile과 유사하다
-- load는 강력한 함수이나, 경우에 따라 이해할수 없는 코드를 생산할 수 있으므로, 더 간단한 방법이 없는지를 고려해야한다.
f = load("i = i + 1")
local s = ""
load(s)() -- 문자열 호출후 바로 실행하는 것도 가능

-- 다음 두 함수는 대체적으로 동일한 기능을 수행하는데, lexical scoping의 측면에서 다르게 동작할 수 있다.
f = load("i = i + 1") -- 글로벌 변수만 참조할 수 있다. (load의 특징)
f = function () i = i + 1 end -- 로컬변수 혹은 글로벌 변수 i를 참조할 수 있다.

-- load의 가장 일반적인 용도는 외부에서 가져온 코드 또는 동적으로 생성된 코드를 실행하는 것이다.

-- 사용자가 동적으로 표현식(expression)을 입력하여 값을 보여주는 코드
-- print "enter your expression:"
-- local line = io.read()
-- local func = assert(load("return " .. line))
-- print("the value of your expression is " .. func())

local filename = "dofiletest.lua"
local f2 = load(io.lines(filename, 1024),"","bt", _G) -- itorator가 load의 첫번째 파라미터에 들어갈 경우, nil이 나올때까지 반복적으로 읽어들인다.
-- 하지만, 이유는 모르겠으나, 이런 itorator 방식으로는 전역 환경정보의 전달이 불가능하여 print등 기본적인 함수를 사용할 수가 없다.
-- load 함수의 네번째 인수에 전역 환경정보를 전달 할 수 있는 인수가 들어간다.
print(f2())

-- load로 반환되는 함수는 다변수함수로 취급된다. 즉, function (...)
-- load와 loadfile은 일반적으로 에러를 발생시키지 않는다. 오류가 발생할 경우에 대신 nil과 에러메세지를 반환한다.

-- load는 컴파일 까지만 수행하고 그 결과물을 함수의 형태로 반환하는 것이다.
-- 그러므로, 반환된 함수를 실행하기 전까지는, 내부에 정의된 함수는 할당되지 않는다.
-- Lua에서 함수의 정의는 할당을 해야 비로소 효과를 발휘하며, 이것은 컴파일타임이 아니라 런타임에서 발생하기 때문이다.

print("\n-------------Precompiled Code-------------") -- luac로 생성한 binary chunk의 사용법
-- Lua는 미리 컴파일된 파일 (binary chunk) 를 지원한다.
-- 아래와 같은 형식으로 커맨드를 입력하면, 컴파일된 바이너리 파일이 생성된다.
-- luac -o prog.lc prog.lua

-- 생성된 바이너리 파일은 기존의 lua파일과 동일한 방식으로 실행가능하다.
-- load와 loadfile 또한 binary chunk를 읽을 수 있다.

-- string.dump()함수를 사용하면, 함수의 precompiled code를 읽어들여 다시 읽어들일 수 있는 문자열로 반환한다.
-- p = loadfile(arg[1])
-- f = io.open(arg[2], "wb")
-- f:write(string.dump(p))
-- f:close()

-- luac로 컴파일시 -l옵션을 사용할 경우, 주어진 chunk에 대해 컴파일러가 생성하는 opcode를 나열한다.
-- 더 자세한 내용은 웹에 lua opcode로 검색하면 관련자료를 얻을 수 있다.

-- precompiled code 의 특징
-- 1. 미리 컴파일된 코드는 원본보다 더 빠르게 로드된다.
-- 2. 소스가 우발적으로 변경되는 것을 막을 수 있다.
-- 3. 악의적으로 손상된 바이너리 코드가 존재할 수 있으므로, 신뢰할 수 없는 코드를 실행하는 것은 피해야한다.
-- 4. load 함수는 이런 점을 고려한 옵션을 가지고 있다.

-- load함수의 인수
-- 두번째 인수 : chunk의 이름 결정 (에러메세지 출력시에만 사용)
-- 세번째 인수 : "t" 텍스트만 허용, "b" 바이너리만 허용, "bt" 둘다 하용 (기본값)
-- 네번째 인수 : 환경정보

print("\n-------------Errors-------------") -- 오류처리 방식과 error 함수의 사용법
-- Lua는 다른 어플리케이션에 삽입되는 확장언어의 속성을 가지고 있기 때문에 오류가 발생했을 때 단순히 종료하거나 멈출수 없다.
-- 함수 error에 에러메세지를 인수로 전달하여 오류를 일으킬 수 있다.
-- print "enter a number:"
-- n = io.read("n")
-- if not n then error("invalid input") end

-- 이런 방식의 오류 메세지 호출 방식은 너무나 일반적인 방식이어서, Lua이것과 동일한 기능을 수행하는 내장함수 assert를 제공한다.
-- print "enter a number:"
-- n = assert(io.read("*n"), "invalid input")

-- 다만 여기서 assert는 일반적인 함수에 불과하기 때문에, 아래 코드에서 두번째 인수에 들어가는 문자열 연결처리는 오류가 발생하지 않아도 반드시 수행하게 된다.
-- 이런 경우 조금이라도 성능을 고려할 경우, 다른 방법을 고려하는 것이 나을 수도 있다.
-- n = io.read()
-- assert(tonumber(n), "invalid input: " .. n .. " is not a number")

-- 함수가 익셉션을 발생하였을 때 처리하는 방식으로는 두가지가 있다.
-- 1. 에러코드의 반환 (일반적으로 false 또는 nil)
-- 2. error함수를 호출하여 오류 발생

-- 에러의 처리방식에 법칙은 존재하지 않지만, 다음의 가이드라인을 따르는 것이 좋다.
-- 1. 쉽게 회피할 수 있는 오류는, 오류를 발생시킨다.
-- 2. 개발자의 의도와는 다르게 불가향력적으로 발생할 수 있는 오류는, 에러코드를 반환시킨다.

-- 가이드 라인의 근거는 다음과 같다.
-- 1. math.sin(x) 를 호출시, x에 숫자가 아닌 무언가가 들어간다면, 구조적으로 간단히 회피할 수 있음에도 불구하고 오류가 발생하였으므로
--    프로그램의 구조 자체에 어떤 문제가 있는 것을 의심해야하므로 오류를 발생시키고 작업을 중단한다.
-- 2. io.open으로 파일을 열때, 파일이 존재하지 않는다면, 이것은 구조적으로 언제든지 발생할 수 있는 오류이므로, 의도적으로 회피하는 것은 어렵다.
--    이런 경우 작업을 중단시키기 보다는 오류메세지를 포함한 문자열을 반환하는 것이 더 합리적이다.

print("\n-------------Error Handling and Exceptions-------------") -- pcall(protected call)의 사용법
-- error 함수는 오류를 발생시키고 작업을 중단시키지만, 반드시 Lua 내부에서 오류를 다루어야할 때가 있다.
-- pcall 함수에 의해 보호받는 함수는 어떠한 경우에도 오류를 발생시키지 않는다.
-- 오류가 없을 경우, true와 함수에서 반환된 값을 반환한다.
-- 오류가 있을 경우, false와 오류 객체를 반환한다.
-- 일반적으로 pcall은 아래와 같이 함수 리터럴을 캡슐화 하는 방식으로 사용한다.
local status, err = pcall(function () error({code=121}) end)
print(err.code) --> 121

-- 이러한 처리방식은, Lua에서 예외처리를 하는데 필요한 모든 것을 제공한다.
-- error함수로 예외를 throw하면, pcall이 catch한다.

print("\n-------------Error Messages and Tracebacks-------------") -- error함수에서 level의 사용법
-- 일반적으로 어떠한 형태의 에러 객체(error함수가 반환하는 객체)도 사용가능하지만, 일반적으로 문자열이 사용된다.
-- 
function foo (str)
	if type(str) ~= "string" then
		-- level 0 : 에러위치를 표시하지 않음
		-- level 1 : 순수하게 에러가 발생한 위치 표시 (디폴트)
		-- level 2 : (에러가 발생하도록 함수)를 호출한 위치 표시
		-- level 3 : ((에러가 발생하도록 함수)를 호출한 함수)를 호출한 위치 표시 (테스트 안해봄)
		-- ...
		error("string expected", 2) -- error함수의 에러 위치 추적 타입을 level 2로 설정 
	end
	return "test"
end

foo(12)

-- pcall을 사용하게 되면, 에러스택의 일부를 추적할수 없게 만들기 때문에, 이를 해소하고자 Lua는 xpcall함수를 지원한다.
-- xpcall은 pcall과 동일하게 동작하지만, 두번째 인수로 message handler function이 들어간다.
-- xpcall 사용시 에러가 발생한 경우, 함수는 스택 언와인드를 수행하기전 message handler function을 실행하게 된다.
-- 두가지 일반적인 message handler function으로는
-- 1. debug.debug --> 에러발생시 프롬프트를 제공하여 사용자가 무슨일이 일어났는지 검사할수 있다.
-- 2. debug.traceback --> 트랙백을 포함한 확장된 에러메세지를 제공.


-- end of chapter
