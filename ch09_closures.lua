-- CH.08 Closures

-- Lua에서 함수는 first-class value이다.
-- 이 의미는, Lua에서의 함수는 숫자나 문자열과 동일한 취급을 받는다는 것이다.
-- 함수는, 변수에 저장될 수 있고, 글로벌 또는 로컬 선언이 이루어 질수 있고, 인수로 전달될 수도 있고, 결과로 반환될 수도 있는 '값'이다.

-- 함수는 적절한 Lexical scoping을 갖는데,
-- 이것은, 함수가 그 함수를 포함하는 함수의 내부에 있는 로컬 변수에 접근할 수 있는 권한을 가지고 있다는 의미이다.
-- 이것은 결국, Lua가 람다대수를 수행가능한 언어라는 것을 의미하기도 한다.

-- 즉, Lua의 함수는 적절한 Lexical scoping을 갖는 first-class value로 요약할 수 있다.

print("\n-------------Functions as First-Class Values-------------")
a = {p = print} -- 테이블이 직접 함수를 할당 (first-class value이기 때문에 가능)
print = math.sin -- 이제부터 print함수는 sin 함수가 된다.
math.sin = a.p -- sin함수는 이제부터 print 함수가 된다
a.p(print(1))
math.sin("test")

-- 함수의 생성
-- syntactic sugar 버전
function foo(x) return 2*x end

-- Lua에서 정식으로 사용하는 함수 생성 코드
foo = function (x) return 2*x end -- 함수생성자로 function 타입 값을 생성하여, foo 변수에 할당하였다.

-- Lua에서 모든 함수는 함수명이 없다. (함수 리터럴이 변수에 할당되기 때문)
-- 함수 리터럴을 함수에 인수로 전달하므로써 보다 유연한 처리가 가능하다. 이때 함수를 인수로 받는 함수를 고차함수(higher-order function)라고 한다.
-- 고차함수로 확보되는 처리의 유연성은, 결국 함수를 first-class value로 취급하는 것에 기인한다.
network = {
	{name = "grauna", IP = "210.26.30.34"},
	{name = "arraial", IP = "210.26.30.23"},
	{name = "lua", IP = "210.26.23.12"},
	{name = "derain", IP = "210.26.23.20"},
}
table.sort(network, function (a,b) return (a.name > b.name) end) -- 익명 함수를 인수로 전달하여 정렬 기능 처리

function derivative (f, delta) -- 고차함수를 이용해서 함수의 도함수를 구하는 간단한 정의
	delta = delta or 1e-4
	return function (x) return (f(x + delta) - f(x))/delta end
end




math.sin = print -- 원래 기능으로 되돌리기
print = a.p -- 원래 기능으로 되돌리기
print("\n-------------Non-Global Functions-------------")
-- 테이블 내에 함수를 정의하는 3가지 방식
Lib = {}
Lib.foo = function (x,y) return x + y end -- 1
Lib = { foo = function (x,y) return x + y end } -- 2
function Lib.foo (x,y) return x + y end -- 3

-- 함수는 로컬변수에 저장될 수도 있다. 그러면 로컬 함수를 얻게 된다.
-- 또한, Lua는 각 chunk를 함수처럼 다룬다.

-- 로컬 함수를 syntactic sugar 버전으로 쓰면
local function f(params)
	-- body
end
-- 와 같다.



-- 로컬함수와 글로벌함수의 차이점
-- 아래 3개의 케이스에서 발생하는 문제들은 로컬변수의 선언시점과 함수에서의 참조값 설정으로 인해 발생할 수 있는 문제들이다.

-- case1. 로컬 변수에 재귀함수를 할당하는 경우 (에러발생)
local fact = function (n)
	if n == 0 then return 1
	else return n*fact(n-1) -- 이 문장은 로컬변수 fact가 "선언되기 전"에 실행된다. 즉, 여기서는 어쩔수없이 글로벌변수 fact를 참조하게되고, 익명함수화 한다.
	end
end
-- 추후, 로컬변수 fact가 선언되지만, 여전히 함수내부에 할당된 주소는 글로벌변수 fact를 가리키고 있어서, 함수를 실행시 에러를 발생시킨다.

-- case2. 글로벌 변수에 재귀함수를 할당하는 경우 (정상작동)
fact = function (n)
	if n == 0 then return 1
	else return n*fact(n-1) -- 이 문장이 실행될 때, 글로벌변수 fact를 참조하기로 한다.
	end
end
-- 글로벌변수 fact 공간에, 익명함수가 들어와 fact()함수로서 정상 기능한다.

-- case3. 로컬변수에 재귀함수를 할당하지만, 함수 리터럴 생성전에 미리 로컬변수를 선언하는 경우(정상작동)
local fact
fact = function (n)
	if n == 0 then return 1
	else return n*fact(n-1) -- 이 문장에서는 이미 로컬변수 fact가 있으므로, 자연스럽게 fact는 로컬변수 fact를 참조하게된다.
	end
end
-- 로컬변수 fact에 익명함수가 할당되면서, 함수내부에서 자기 자신을 참조하도록 하는 재귀구조가 완성이 된다.

-- 함수 리터럴 생성시점에 변수가 어떤것이 들어있는지는 크게 중요한 부분이 아니다.
-- 실제로 함수의 사용시점에서 올바른 값이 들어가 있기만 하면 된다.
-- 반면, 변수를 사용할 때, 자체적으로 로컬인지 글로벌인지를 결정할 수 있는 시점은 함수리터럴 생성시점뿐이므로,
-- 그 참조되는 변수가 로컬인지 글로벌인지가 더 중요하다.

-- Syntatic sugar 표현을 사용하면, 자동으로 로컬변수 선언이 분리되므로 걱정할 필요는 없다.
local function foo (params) -- 이렇게 전개된다 --> local foo; foo = function (params) body end
	-- body
end 
-- 하지만, 간접 재귀 함수(f가 g를 호출하고, 다시 g가 f를 호출하는 방식으로 정의된 함수)를 사용하게 되면,
-- Syntatic sugar 버전도 에러가 발생하므로 사전 선언을 해줘야만한다.


print("\n-------------Lexical Scoping-------------")
-- 함수 안에 존재하는 로컬변수를, 그 함수 안에 존재하는 함수의 내부에서 완벽하게 접근 가능하도록 하는 기능을 lexical scoping이라고 한다.
-- 이 기능은 얼핏 당연하게 느껴지지만, 사실은 그렇지 않다.
function newCounter ()
	local count = 0
	return function ()
			count = count + 1 -- count 변수는 lexical scoping이 지원되지 않는다면, 실은 이 함수에서는 참조할 수 없는 위치에 존재한다.
			return count -- 이때, count 변수는 local 과 global 어느쪽에도 속하지않는 variable이므로, non-local variable 또는 upvalue라고 한다.
		end
end
-- Lua에서는 이 참조 불가능한 상황을 해결하기 위해, closure라는 개념을 사용한다.
-- closure란 함수와 그 함수가 필요한 모든 non-local 변수를 포함한 묶은 것을 이야기한다. (function + non-local variable == closure)
-- 기술적으로, 함수(function)란 closure의 일종의 프로토타입으로 볼 수 있다.
c1 = newCounter ()
c2 = newCounter () -- newCounter() 호출될때마다 새로운 closure가 생성되어 다시 1부터 카운트하게 된다.

-- 위의 예제에서와 같이 closure는 다른 함수를 생성하는 함수로도 유용하다.

-- closure는 또한 callback 함수에 유용하다. 유사한 이벤트에 대해서 반복적으로 함수를 생성할 수도 있고,
-- non-local variable을 사용하기 때문에 동적으로 할당도 가능하다

do -- closure를 사용하면, 이런식의 재정의도 가능하다
	local oldSin = math.sin -- sin함수의 입력값을 radian에서 degree로 재정의 하는 경우, 여기서 oldSin은 do-end block내에서만 접근가능하지만
	local k = math.pi / 180
	math.sin = function (x)
	return oldSin(x * k) -- 함수에서는 접근할수 있다. 이렇게 closure를 이용해서 이전함수는 완전히 사용하지 못하게 하고, 새함수를 정의한다.
	end
end

do -- closure를 사용하면, 이런식의 재정의도 가능하다
	local oldOpen = io.open -- 기존의 파일스트림을 여는 io.open함수를 closure범위에 저장하고
	local access_OK = function (filename, mode) end -- 접근 확인을 진행하고
	
	io.open = function (filename, mode) -- 접근 여부에 따라, io.open을 정상 실행할지, 접근 거부를 할지 정한후 수행한다.
				if access_OK(filename, mode) then
					return oldOpen(filename, mode)
				else
					return nil, "access denied"
				end
			end
end
-- 이런 식의 재정의를 통해, 확인되지 않은 접근에 대해 파일스트림의 접근을 원천 봉쇄할 수 있다.

-- 이런 기술들을 사용하면, Lua 자체 기반의 Lua식 샌드박스를 만들 수도 있다. 특정 보안 요구사항에 맞게 환경을 조정하는 것도 가능하다.


print("\n-------------A Taste of Functional Programming-------------")
-- 이번 챕터에서의 closure 생성 기법을 기반으로, 함수형 프로그래밍에 대한 맛을 본다.
-- 임의의 형상을 조합해서 영역을 만드는 함수를 제작한다.

function disk (cx, cy, r) -- 가령 디스크의 영역을 정의하는 기본함수
	return function (x, y)
			return (x - cx)^2 + (y - cy)^2 <= r^2
		end
end
function rect (left, right, bottom, up) -- 사각형 영역을 정의하는 기본함수
	return function (x, y)
			return left <= x and x <= right and
			bottom <= x and x <= up
		end
end

function complement (r) -- 영역을 반전시키는 함수
	return function (x, y)
			return not r(x, y)
		end
end

function union (r1, r2) -- 영역을 합치는 함수
	return function (x, y)
			return r1(x, y) or r2(x, y)
		end
end

-- 등.. 이런 함수를 조합하여 다양한 영역을 구성할 수 있다.






-- end of chapter


