-- CH.18 Iterators and the Generic for

-- 그 동안 generic for 를 사용했으나, generic for에서 사용되는 itorator에 대해서는 다루지 않았다.
-- 여기서는 itorator를 작성하는 법에 대해서 다룬다.

print("\n-------------Iterators and Closures-------------")
-- itorator는 컬렉션의 요소들에 걸쳐 반복하는 것은 가능하게 하는 구조물을 말한다.
-- Lua에서는 함수로 iterator를 표현한다. 반복시 매번 그 함수가 호출되고, 그 다음 요소를 반환한다.

-- 함수가 호출될 때마다 현재의 상태를 기록하여, 다음 호출 준비를 하기위해서는, 현재 상태를 저장하는 방법이 필요하고,
-- closure는 이에 대한 구현방법이 될 수있다.
-- 물론, 새로운 closure를 생성하면, 그에 따른 non-local variable도 함께 생성되는 것을 의미한다.
-- 즉, non-local variable을 정의하는 공간(함수)이 필요하고
-- 그러므로, closure를 구성할 때는 일반적으로 두개의 함수가 관여하게 된다. closure자신과 closure를 생성하는 factory이다.

function values(t) -- closure를 반환하는 iterator factory함수
	local i = 0 -- 아래의 익명함수에 대한 non-local variable i
	return function()
				i = i + 1
				return t[i]
			end
end

t = {10, 20, 30}
iter = values(t) -- values 함수는 익명의 function을 리턴한다 (이 시점에서 i는 0으로 t는 해당 테이블로 초기화되어있다)
while true do
	local element = iter() -- iter() 함수를 실행하면, 초기에는 i가 1이되고 t[1]을 리턴하여 element에 할당한다.
	if element == nil then break end
	print(element)
end

for element in values(t) do -- generic for 는 iter변수를 필요로 하지 않는다. 내부적으로 그것을 처리한다.
	print(element)
end

print("\n-------------The Semantics of the Generic for-------------")
-- 이전에 서술한 iterator의 단점은 하나의 새로운 루프를 설정값으로 초기화하기 위해, 하나의 새로운 closure가 필요하다는 것이다.
-- generic for의 자체적인 기능을 이용하면 iterator function의 상태를 초기화하거나 유지하기 위해 사용할 수 있다.

-- generic for는 loop안에서 세가지 값을 유지한다.
-- iterator function, invariant state, control variable

-- 이 값들은 iterator factory가 리턴하는 다중 리턴값으로서,
-- 단순하게 iterator function만 반환하는 경우, invariant state와 control variable은 nil값이 된다.

-- 많은 설명 보다는 아래의 코드에 모든 것이 담겨있다. 아래와 같은 코드는,
--[[
for var_1, ..., var_n in explist do
	block
end
]]--
-- 다음의 코드와 등가이다.
--[[
do
	local _f, _s, _var = explist
	while true do
		local var_1, ... , var_n = _f(_s, _var)
		_var = var_1
		if _var == nil then break end
		block
	end
end
]]--

-- _f : iterator function
-- _s : invariant state -> 처음 단 한번만 설정되어 유지되는 값. iterator function의 인수로서 활용됨
-- _var : control variable -> 루프를 돌 때마다, iteroator function이 빈환하는 첫번째 변수에 의해 재 설정되는 값. iterator function의 인수로서 활용됨.

-- 즉, iterator function f는 a1 = f(s, a0) 의 점화식을 갖는다.

print("\n-------------Stateless Iterators-------------")
-- Stateless Iterators는 iterator function이 어떤 내부 상태를 가지지 않고,
-- 오로지 입력되는 인자인 invariant state와 control variable에 의해서만 결과값이 결정되는 iterator function을 말한다.

-- stateless가 아닐 경우, iterator function f는 f()가 호출 될 때마다 호출된 시점에 따라 다른 값을 내놓지만
-- stateless일 경우, f(s, an) 에서 s와 an의 입력값이 동일한 경우 언제나 같은 결과를 내놓게 된다.

-- 따라서, stateless iterator의 경우, 내부상태가 존재하지 않으므로 매번 closure를 새로 생성할 필요가 없다.

-- 대표적인 stateless iterator는 다음과 같이 정의 될수 있는 ipairs함수라고 한다.
--[[
local function iter (t, i)
	i = i + 1
	local v = t[i]
	if v then
		return i, v
	end
end
 
function ipairs (t)
	return iter, t, 0 -- iter 함수는 별도 함수로 미리 함수화 되어 있으므로, ipairs()함수를 여러번 호출하여도 closure가 매번 새로 생성되지 않는다.
end
]]--

--[[
function pairs (t) -- pairs함수도 closure를 매번 새로 생성하지 않는 stateless 방식으로 정의 되어 있다.
	return next, t, nil
end
]]--

-- 다음과 같이 Lua의 변수의 복수 할당 특성을 이용해서 pairs함수를 사용하지 않고, 직접 next함수를 사용하는 것도 가능하다.
--[[
for k, v in next, t do
	loop body
end
]]--

print("\n-------------Traversing Tables in Order-------------")
-- 일반적으로 테이블의 key는 순서를 갖지 않기 때문에 pairs()를 사용해도, 정렬된 key의 순서로 값을 받지 못한다.
-- iterator function을 사용하면 이런 문제를 해결할 수 있는데, 
function pairsByKeys (t, f)
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

-- 위의 iterator factory는 다음과 같이 사용한다.
--[[
for name, line in pairsByKeys(lines) do
	print(name, line)
end
]]--

print("\n-------------True Iterators-------------")
-- 사실 iterator라는 명칭은 약간 잘못되어 있다. 왜냐하면, Lua에서 itorator는 "반복"하지 않기 때문이다.
-- 반복하는 것은 for 루프이지 iterator가 아니다. iterator는 단순히 연속적인 결과를 반환할 뿐이다.
-- iterator보다는 generator가 더 어울리는 명칭이겠지만, 이미 iterator의 개념은 Java를 포함한 다른 언어에서 잘 정립되어 있다.

-- function 자체가 내부에서 반복을 수행하도록 하는 true iterator 구현 할 수도 있다.
-- 다음과 같은 함수를 정의 하였다고할 때,
function allwords (f)
	for line in io.lines() do
		for word in string.gmatch(line, "%w+") do
			f(word) -- call the function
		end
	end
end
-- 아래와 같이 f에 함수만 전달해주면 해당 함수에 대해서 iteration을 수행한다.
-- allwords(print)

--[[ -- 익명함수를 전달하는 경우
local count = 0
allwords(function (w)
	if w == "hello" then count = count + 1 end
end)
print(count)
]]--

-- 이런 방식의 구현은 for문이 아직 없던 과거의 Lua에서 주로 사용하던 형태이다.
-- 하지만, 앞서 줄곳 설명해왔던 generator 형태의 iterator가 더 유연성을 가진다.
-- 첫번째로 복수의 iterator로 다중 for문을 구성할 수 있다.
-- 두번째로 break나 return을 이용해서 iteration을 종료할 수 있다. 
-- (ture iterator는 break는 불가능하며, return을 할경우 단지 값을 익명함수가 값을 반환할 뿐 iteration이 종료되지 않는다.)

-- end of chapter