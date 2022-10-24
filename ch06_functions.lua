-- CH.06 Fucntions

-- function은 Lua 구문의 추상화를 위한 주요 메커니즘이다.
-- function은 특정 작업을 수행하거나 값을 리턴할 수 있다.

-- 만약, 함수에 들어가는 인수가 literal string의 형태나, table constructor의 형태라면, 인수를 감싸는 괄호()를 생략할 수 있다.
-- print "Hello World" <--> print("Hello World")
-- f{x=10, y=20} <--> f({x=10, y=20})

-- 일반적으로 Lua에서는 성능상의 이유와 시스템 접근상의 이유로 C function에 의존한다.
-- Lua의 모든 function 라이브러리는 C로 쓰여져 있고, C로 정의된 function과 Lua로 정의된 function 사이에는 아무런 차이도 존재하지 않는다.

-- 함수 예시
function add(a)
	local sum = 0
	for i = 1, #a do
		sum = sum + a[i]
	end
	return sum
end
-- 함수에서 들어오는 매개변수의 수보다 적은 수의 인수가 들어오면, 부족한 매개변수는 nil로 대체된다.

print("\n-------------Multiple Results-------------")
s, e = string.find("hello Lua users", "Lua") -- Lua는 다중결과를 받을 수 있다.
print(s, e)

function multiResult()
	local a = 3
	local b = 5
	return a, b -- Lua는 다중결과를 리턴할 수 있다.
end
print(multiResult())

-- Lua는 구문의 형태에 따라, 다중결과의 결과수를 조정한다.
-- foo() : statement로 사용될 때 다중결과를 전부 폐기하며
-- t = 1 + foo() : 피연산자로 사용될 때, 첫번째 결과만 유지하며
-- a, b, c = 1, foo() : 리스트 형태로 입력할 때, foo()가 가장 마지막 표현식을 경우에만 모든 결과를 넣는다.

-- 리스트 형태로 다중결과가 입력될 때, Lua는 4가지 패턴을 보인다. foo()가 다중결과를 반환하는 function이라고 할때,
-- a, b = foo()
-- fnt(foo())
-- t = {foo()}
-- return foo()

-- print((foo())) : 괄호에 추가로 감싸는 방식으로 변수에 한번 할당한 것과 같은 리턴결과를 얻을 수 있음.


print("\n-------------Variadic Functions-------------")
function variadicFnc(f, ...)
	local t = {...} -- 리스트를 테이블의 형태로 값을 전달할수 있다. 또는
	local a, b, c = ... -- 리스트를 변수에 할당할 수도 있다
	
	print("first value : "..f)
	for i = 1, #t do
		print(t[i])
	end
	
	return ... -- 리스트를 그대로 다중결과로 반환할 수도 있다
end
print(variadicFnc(3, 4, 10, 25, 12))

function nonils (...)
	local arg = table.pack(...) -- 테이블 생성시, nil을 포함하여 들어간 인수의 수를 n에 할당해주는 function
	for i = 1, arg.n do
		print(arg[i])
	end
	return true
end
nonils(2,nil,3)

print(select(2, "a", nil, "c")) -- select 함수의 동작 : 정수가 들어오면 해당 정수의 인덱스 이후의 값을 다중결과로 반환
print(select("#", "a", nil, "c")) -- select 함수의 동작 : "#" 이 들어오면, 총 인수의 갯수 반환

-- 두 add 함수 구현의 비교
function add1 (...) -- 인수가 많을 때는 이쪽 add1 function이 더 빠르다
	local s = 0
	for _, v in ipairs{...} do -- {}로 테이블을 생성하지만
		s = s + v -- 많은 인수를 통해 select function을  호출할 필요가 없다.
	end
	return s
end

function add2 (...) -- 인수가 적을 때는 이쪽 add2 function이 더 빠르다
	local s = 0
	for i = 1, select("#", ...) do -- 테이블을 생성하지 않기 때문
		s = s + select(i, ...)
	end
	return s
end

print("\n-------------The function table.unpack-------------")
print(table.unpack{10,20,30}) -- table.unpack : 테이블 값을 받아, 다중결과로 반환하는 함수. 다중값을 받아 테이블로 반환하는 table.pack 함수의 반대
-- f(table.unpack(a)) : table.unpack의 중요한 용도는 가변개수의 리턴값으로 함수를 호출할 수 있다는 것이다.
function testfnt(...)
	print(...)
end
f = testfnt -- 특정 함수를 동적으로 할당하고
a = {1, 2, 3, 4, 5} -- 임의의 인수에 대해서
f(table.unpack(a)) -- 함수와 인수를 조립하므로써, 동적으로 할당된 함수를 가변개수의 인수에 대해서 호출 할 수 있다.
print(table.unpack({"Sun", "Mon", "Tue", "Wed"}, 2, 4)) -- 2번째 ~ 4번째 사이의 엘리먼트만 반환하겠다고 지정할 경우


print("\n-------------Proper Tail Calls-------------")
-- lua는 테일콜 제거를 지원한다.
function f (x) -- 이와 같은 함수가 있을 때,
	x = x + 1
	return g(x) -- g(x)는 테일콜이다.
	-- g(x)는 f(x)함수의 마지막 작업이므로, g(x)를 수행할 때 f(x)와 g(x)의 함수 스택이 동시에 존재할 필요가 없다.
	-- 그러므로, 특정 언어에서는 이 사실을 이용하여, 테일콜 호출시 추가적인 함수스택을 사용하지 않도록하는 방법을 사용하기도 한다.
	-- 이것이 tail call elimination
	-- 그러므로, 함수의 재귀 호출에 있어서도, tail call의 형태로 재귀가 발생하는 경우, 적절하게 tail recursive가 이루어진다.
end

-- 테일콜의 문제점은, 무엇이 테일콜인지를 구분하는 것에 있다.
-- Lua에서는, 오로지 return func(args)의 형태만 테일콜로 인정된다.





















































-- end of chapter