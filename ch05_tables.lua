-- CH.05 Tables

-- table은 Lua가 관리하는 구조 매커니즘이다.
-- Lua는 패키지와 객체를 나타내기 위해서도 table을 사용한다.
-- math.sin 은 math 라이브러리의 sin 함수로 생각되기 쉽지만, Lua에서는 문자열 sin을 키로 사용하여 math 테이블에 색인을 생성하라는 의미이다.
-- table은 객체이다.
-- Lua는 테이블을 사용할 때 언제나 참조값만을 이용한다.

a = {} -- 테이블을 생성하고 참조값을 가져와라
a["x"] = 10 -- 키값 x에 해당하는 새로운 멤버에 값 10을 할당하라
a[20] = "great" -- 키값 20에 해당하는 새로운 멤버에 값 great를 할당하라

-- 내용확인
print(a["x"])
print(a[20])


b = a -- b에 a테이블의 참조값을 할당
a = nil -- b는 그대로 있지만, a는 더이상 테이블을 참조하지 않음
b = nil -- b도 더이상 테이블을 참조하지 않음
-- 이제 a도 b도 테이블을 참조하지 않으므로 참조되지 않는 테이블은 GC에 의해 삭제된다.

a = {}
print(a[3]) -- 아직 초기화 되지 않은 값은 전역변수에서와 같이 nil을 출력한다.
-- 반대로 전영변수에서와 같이 nil을 할당하여 지울 수도 있다
-- 전역변수의 특성과 동일한 이유는, Lua는 전역변수를 일반 테이블에 저장하기 때문이다.

-- Lua에서 아래 두 식은 등가이다.
a["x"] = 3
a.x = 3

-- Lua에서 a[0] 와 a["0"]는 등가가 아니다
a[0] = "number key"
a["0"] = "string key"

-- Lua에서 a[2] 와 a[2.0]은 등가이다

-- constructor
days = {} -- 가장 기본적인 형태의 constructor
days = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"} -- 리스트로 초기화된 constructor
a = {x = 10, y = 20} --  레코드 형태로 멤버로 초기화

print(days[4]) -- Wednesday 출력
print(a["x"]) -- 10출력
print(a.y) -- 20출력

-- 어떤 constructor를 사용하든지 상관없이 새로운 멤버를 추가하는 것에는 제한이 없다
-- 또한, 선언시 스타일을 섞을 수도 있다.

-- 위의 레코드 및 리스트 초기화는 특정한 문자열 변수의 선언에 제한이 있으므로, 좀더 일반적인 형태의 선언도 가능하다.
opnames = {["+"] = "add", ["-"] = "sub", ["*"] = "mul", ["/"] = "div"}
a = {[1] = "red", [2] = "green", [3] = "blue",}

for i = 1, #a do -- #은 lenth operator이다. 정수 1부터 새었을 때 중간에 공백없이 n까지 도달하였을 때, 그것을 sequence라고 하며 그 sequence의 길이를 재는 것이 #이다.
	print(a[i])
end

-- 1, 2, 3 : a sequence
-- 1, 2, 3, 7, 9 : not a sequence (1, 2, 3 부분만 sequecne)

print("\n-------------Table Traversal-------------")
t = {10, print, x = 12, k = "hi"}
for k, v in pairs(t) do -- pairs iterator : 모든 key-value를 볼수 있지만, 항상 같은 순서가 나온다고 보장하지 않는다.
	print(k, v)
end
t = {10, print, 12, "hi"}
for k, v in ipairs(t) do -- ipairs iterator : sequence기반의 key-value 밖에 볼수 없지만, 항상 같은 순서로 나오는 것을 보장한다.
	print(k, v)
end
t = {10, print, 12, "hi"}
for k = 1, #t do
	print(k, t[k]) -- # operator를 이용해서 sequece를 순회하기도 한다. (ipairs iterator 와 같은 결과)
end

print("\n-------------Safe Navigation-------------")
E = {} -- 재사용가능한 빈테이블로서 두면 유사한 처리가 발생하였을 때 편리하게 사용가능하다.
zip = (((company or E).director or E).address or E).zipcode -- 각 테이블을 한번씩만 참조하면서 nil값 테스트를 할 수 있는 적절한 방법


print("\n-------------The Table Library-------------")
t = {[1] = 10,[2] = 20,[3] = 30,[4] = 40,[10] = 50,[11] = 60}
table.insert(t, 5, 13) -- 테이블의 특정 장소에 엘리먼트 삽입 (sequence 에 적용)
table.remove(t, 5) -- 테이블의 특정 장소의 엘리먼트 삭제 (sequence 에 적용)
table.move(t, 1, #t, 2) -- table.move(a, f, e, t) : a테이블의 인덱스f부터 인덱스e 사이의 모든 엘리먼트를 인덱스t 위치로 이동시켜라.
for k, v in pairs(t) do
	print(k, v)
end

t2 = {}
table.move(t, 1, #t, 2, t2) -- table.move(a1, f, e, t, a2) : a1테이블의 인덱스f부터 인덱스e 사이의 모든 엘리먼트를 a2테이블의 인덱스t 위치로 이동시켜라.
for k, v in pairs(t2) do
	print(k, v)
end











































-- end of chapter