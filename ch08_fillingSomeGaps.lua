-- CH.08 Filling some Gaps

-- 본 챕터는 1~7 챕터 사이에 부족한 부분을 매꾸는 내용으로 구성



print("\n-------------Local Variables and Blocks-------------")
-- Lua의 변수는 기본적으로 전역변수이다.
x = 10
function a()
	y = 20
	print(x) -- 함수밖에서 선언된 x에 함수 내에서 접근 가능
end
a()
print(y) -- 함수 안에서 선언된 y에 함수 밖에서 접근가능
-- 현재 자신이 속한 범위 안에서만 유효하게 하려면 local 키워드를 붙인다. (제한 범위 종류 : chunk, body 등)
-- 인터랙티브 모드에서는 각 라인이 하나의 chunk이므로, local로 정의하게되면 다음 라인에서는 못 읽을 수 있다.
-- 인터렉티브 모드에서 chunk로 분리되는 현상을 막기 위해서는, do-end를 사용하여 명시적으로 블록을 지정해주면 좋다.

local l = 3
do
	local l = 4
	print(l) -- 로컬변수 l에 접근한다
	-- 로컬변수 l 수명 종료
end
print(l) -- 보다 상위의 로컬변수 l에 접근한다

-- 혹자는, 글로벌이 디폴트가 되기보다, 로컬이 디폴트가 되어야한다고 말하지만,
-- 사실 가장 깔끔한 방법은, 로컬도 글로벌도 디폴트가 되지 않는 것이다.
-- strict.lua 모듈을 사용하면, 함수 안에서는 미리 글로벌 선언 되어있지 않은 전역변수에는 접근할 수 없도록 한다.
-- 이것이 의미하는 바는, 글로벌은 글로벌 영역에서만 선언할 수 있다는 것이다.

value1 = 3
do
	local value1 = value1 -- 로컬영역 내부에서 자유롭게 변수를 조작해도, 글로벌 변수에 영향을 미치지 않도록 하는 관용구
	value1 = value1 + 10
	print (value1)
end
print(value1)

print("\n-------------Control Structures-------------")
a = 0
-- if then elseif else end
-- Lua는 switch 문이 없다
if a < 0 then
	b = 1
elseif a > 0 then
	b = 2
else
	b = 3
end

-- while do end
while a > 0 do
	a = a - 1
end

-- repeat until (C에서의 do while문과 같은 기능)
-- 참고로, 루프 안(repeat~until)에서 선언된 로컬 변수는 조건부(until~) 에서도 visible하다.
repeat
	a = a + 1
until a > 0

-- (Numerical) for do end
for var = 5, 20, 2 do -- var이 5부터 시작하여 20이 될때까지 2씩 더해가면서 루프를 반복
	print(var)
end

for var = 5, 20 do -- var이 5부터 시작하여 20이 될때까지 1씩 더해가면서 루프를 반복
	print(var)
end
-- 여기서 제어변수 var는 로컬변수로 선언되며, 루프 안에서만 유효하다.
-- 제어변수의 값은 루프 안에서 임의로 변경하지 않는 편이 좋다. (결과 예측불가능)
-- 루프가 끝나기전에 탈출하고 싶은 경우, break를 사용하라.

-- (Generic) for in do end
-- iterator 함수가 순차적으로 반환하는 값을 처리해가며 루프를 반복하는 방식이다.
-- iterator 함수는 사용자가 직접 정의할 수 있으며 그 방법은 ch18에서 소개된다.
t = {10, 20, 30}
for _, v in ipairs(t) do
	print(_, v)
end

-- break, return, goto
-- break : break가 포함된 for, repeat, while 루프문을 한단계 탈출할 때 사용
-- return : 단순하게 return문이 포함된 함수를 종료할 때 사용. 자연스럽게 종료되는 함수는 암시적 return이 존재하므로 굳이 사용할 필요가 없다.
--          return은 해당 블록에서 마지막 구문이 되어야만한다. 그렇지않으면 절대 실행될 수 없는 코드가 발생하기 때문.
--          하지만 디버깅을 위해서 의도적으로 리턴을 중간에 삽입하는 경우가 생긴다.
function foo ()
	return -- 여기서는 return이 함수에서 마지막 구문이 아니므로 에러가 발생
	do return end -- 하지만 여기서는 블록 내부에서 return 마지막 문장이므로 에러가 발생하지 않는다.
	-- other statements
end
-- goto : goto는 논란이 많은 명령어지만, 잘 사용하면 강력한 도구가 될 수 있다. Lua에서는 goto를 사용하여 점프할 수 있는 위치에 몇가지 제한이 있다.
-- 1. 블록 안으로 점프 불가능, 2. 함수 밖으로 점프 불가능, 3. 로컬 변수가 작용하는 영역 내부로 들어갈 수 없음
-- goto의 일반적인 사용방법은, Lua에는 제공하지 않으나 다른 언어에서 제공하는 제어기능(continue 등)을 모방하는 것이다.
-- goto는 또한 유한 상태 기계를 구현하는데에도 탁월하다. (물론, goto를 사용하지 않는 좋은 방법도 존재한다)

while some_condition do
	if some_other_condition then goto continue end
	local var = something
	-- some code --> 로컬변수 var가 작용하는 영역은 해당 블록의 마지막 non-void statement에서 끝난다. (즉, 이 줄까지만, 로컬변수가 영향을 미친다)
	::continue:: -- 레이블은 void statement로 취급되고, 여기는 로컬변수 var가 작용하는 영역 밖이 되므로, 해당 레이블로 점프가 가능하다.
end
















-- end of chapter