-- CH.10 Pattern Matching

-- Lua는 다른 스크립팅 언어들에서 제공하는 POSIX 정규식이나 Perl 정규식을 지원하지 않는다.
-- 이것은 이런 정규식들의 구현에 일반적으로 4000줄 이상의 코드가 필요하며, 이것은 Lua 전체 라이브러리의 절반이상의 양이다.
-- 그러므로 Lua에서는 전용의 패턴매칭을 제공하며 (600줄 이하), 다른 정규식이 가진 모든 기능을 제공하진 못하지만,
-- 여전히 강렬한 툴이며, 다른 정규식으로는 구현하기 어려운 것들을 지원하기도 한다.

print("\n-------------The Pattern-Matching Functions-------------")
-- 문자열 라이브러리는 패턴을 기반으로 4가지 함수를 제공한다.
-- string.find, string.match, string.gsub, string.gmatch

-- 함수 string.find는 주어진 문자열 속의 패턴을 찾는다.
s = "hello! hello world"
i, j = string.find(s, "hello") -- i에는 매칭이 시작된 인덱스, j에는 매칭이 종료된 인덱스 반환
print(string.sub(s, i, j)) -- 인덱스 i, j를 이용해서 매칭된 내용 출력해보기

-- param1 : 검색대상, param2 : 검색할문자열
-- param3 : 검색을 시작할 인덱스, param4 : plain text를 기반으로 검색하지 여부(param2에 무엇이 들어와도 일반 문자열로 취급되게됨)
string.find("a [word]", "[", 1, true)


-- 함수 string.match는 문자열에서 패턴을 검색한다는 의미에서 string.find함수와 유사하지만, 패턴과 일치한 문자열을 출력한다.
string.match("hello world", "hello") -- 예를 들어, 이것은 hello를 반환하지만,
date = "Today is 17/7/1990"
string.match(date, "%d+/%d+/%d+") -- 이것은 17/7/1990을 반환하게 된다.


-- 함수 string.gsub 3개의 필수 매개변수를 가지고 있다. 1번 매개변수의 내용을 2번 매개변수의 패턴으로 검색하여, 3번 매개변수로 교체한다.
string.gsub("cute Lua is cute", "cute", "greate") -- greate Lua is greate
string.gsub("all lii", "l", "x", 2) -- axx lii : 추가 파라미터를 이용해서 교체할 내용의 수를 조절할 수 있다.


-- 함수 string.gmatch 은 스트링을 훑으며 패턴과 일치한 모든 문자열을 차례로 받을수 있는 iterator를 반환한다.
s = "some string starts"
for w in string.gmatch(s, "%a+") do
	print(w)
end

print("\n-------------Patterns-------------")
-- 보통의 패턴매칭 라이브러리들은 백슬래시를 이스케이프 문자로 사용한다. 하지만 Lua는 패턴매칭에 대해서는 %기호를 사용한다.
-- 아래와 같이 .패턴의 경우, 패턴부분에 .을 사용할수 없다. 왜냐하면 패턴에서 .은 특별한 의미를 가지기 때문이다.
-- 그러므로 이 경우, %.를 대신 사용한다.
print(string.gsub("cute Lua is \\ cute.", "%.", "greate"))

-- 대괄호[] 를 사용하면 대괄호 안의 캐릭터 클래스(문자집합(char-set)을 대표하는 기호, 주로 . %a 등)와 단일 문자를 합쳐 하나의 캐릭터 클래스를 만들 수 있다.
-- char-set을 대괄호 안에 넣으면 character class가 되고, character class는 그 자체로 char-set이다. (하지만 대괄호 안에 대괄호를 넣어서 패턴을 생성할 수는 없다)
text = "how many vowels are there in this sentence?"
_, nvow = string.gsub(text, "[AEIOUaeiou]", "") -- 모음들을 하나의 문자집합으로 묶어 패턴매칭 실시
print(nvow)

-- 하나의 문자 a는 그 자체로 a를 대표하는 캐릭터 클래스(단지, 경우의수가 a밖에 존재하지 않는)로서, [a]로 볼 수있다.

-- 대괄호 안에서는, 하이픈- 을 사용하여 문자의 범위를 표현할 수 있다.
-- 즉, [0123456789]는 [0-9]와 동일한 의미를 갖는다.
print(string.gsub("cute 112333 Lua is \\ cute.", "3*3", "greate"))

-- 대괄호 안에서는, 캐럿^ 을 사용하여, 문자집합을 반전시킬 수 있다.
-- 즉, [^0-9] 는 숫자가 아닌 모든 문자를 의미한다. [^%s] 이런 표현도 있을 수 있지만, %S 라는 더 간단한 표현이 존재한다.


-- modifier를 사용하여, 패턴을 확장할 수 있다.
-- +는 1개 또는 그 이상의 동일 캐릭터 클래스의 반복을 허용한다. 대상 문자열이 "aaa"일 경우 "a+"가 패턴이라면 "가장 긴 것"을 대상으로 한다. 즉, a,a,a 각각이 아니라 aaa를 대상으로 한다.
-- *는 0개 또는 그 이상의 동일 캐릭터 클래스의 반복을 허용한다. 패턴과 일치하는 것 중 "가장 긴 것"을 대상으로한다. 이것은 주로 어떤 대상 문자가 옵셔널로 들어갈 경우에 설정해주는 패턴이다.
-- -는 0개 또는 그 이상의 동일 캐릭터 클래스의 반복을 허용한다. 다만, 패턴과 일치하는 것 중 "가장 짧은 것"을 대상으로 한다.
-- ?는 0개 또는 1개만 발생할 경우를 의미한다. 대표적으로, [+-]?%d+ 라고 하면, +또는 -기호가 붙거나 아무것도 안붙은 모든 정수에 대해서 패턴일치가 발생한다.

-- modifier는 캐릭터 클래스에만 적용할 수 있다. Lua에서는 패턴을 그룹화하여 modifier를 적용할 수는 없다.
-- 즉, 하나의 문자가 아닌, 어떤 단어를 modifier를 통해 옵션널 처리하는 것은 불가능하다. (우회 기법은 존재한다)

-- 패턴이 캐럿^ 으로 시작하면(대괄호 안에 있는 ^과는 다르다), 오로지 대상 문자열의 시작부분과 비교한다 (패턴에서 ^는 문자열의 시작을 나타내는 기호라고 봐도 좋다)
-- 패턴이 달러$ 로 끝나면, 오로지 대상 문자열의 마지막 부분과 비교한다. (패턴에서 $는 문자열의 마지막을 나타내는 기호라고 봐도 좋다)
s = "123451365243afsdfaf"
print(string.find(s, "af$"))


-- %b 는 밸런스를 의미하는 b이다. %bxy라고 쓰면, x로 시작해서 y로 끝나는 패턴을 찾는다.
-- 단, 여기서의 패턴은 괄호의 묶음 처리와 유사하다. 즉, x가 세번 등장할 경우, 네번째x가 등장하기전에 세번째y가 등장해야만이 패턴으로 인지 될수 있다.
-- 다르게 표현하면, x가 +1이고 y가 -1이라고 할 때, 왼쪽에서부터 연산하여 해당 y를 포함한 총합이 0이되는 y가 나오기 전까지는 패턴으로 인지되지 않는다.
-- 즉, %b()라고 할 때, '(()()())' 에서 가장 왼쪽의 '('는 가장 오른쪽의 ')'하고만 짝이되어 패턴으로 인지된다.
-- 여기서, 패턴으로 인지될 수 있는 '짝'중에서 가장 큰 범위를 최종적인 패턴으로 인지한다.
s = "a (enclosed (in) parentheses) line"
print((string.gsub(s, "%b()", "great")))
s = "a xxxnclosed (in) parenthesesyy line"
print((string.gsub(s, "%bxy", "")))

-- %f[char-set] 는 프론티어를 의미하는 f이다. %f[char-set]는 빈문자열""과 매칭된다. 하지만, 조건이 존재한다.
-- char-set에 있는 문자집합이 매칭의 조건이 된다. 즉, 그 다음 글자가 char-set에 포함되고, 이전글자는 포함되지 않는 조건에서만 빈문자열""과 매칭된다.
-- 즉, 만일, %f[a]가 있는 경우 문자열 "kabc"가 있다면, k와 a의 경계에서 매칭이 발생한다.
-- 프론티어 패턴은 문자열에서 첫번째 문자 이전에 null(ASCII 코드로 0)문자, 마지막 문자 이후에 null(ASCII 코드로 0)문자가 있는 것으로 취급한다.
-- 다음과 같은 응용이 있을 수 있다.
s = "the anthem is the theme"
print((string.gsub(s, "%f[%w]the%f[%W]", "one"))) -- the의 앞뒤로 영/숫자가 존재하지 않으면 매칭하라.

print("\n-------------Captures-------------")
-- capture는 패턴을 인지한 후, 특정 성분만을 뽑아내기 위해 사용한다.
-- 패턴 안에서 괄호() 를 사용하면 capture가 동작한다.
pair = "name = Anna" -- 여기서, name과 Anna를 각각 key와 value로 추출하고 싶다고 할 때,
key, value = string.match(pair, "(%a+)%s*=%s*(%a+)") -- string.match를 사용하면 괄호() 에 해당하는 성분만 추출할 수 있다.
print(key, value) 

-- %n이 있고 여기서 n이 숫자라면, 이것은 n번째 capture의 사본과 매칭한다.
s = "abb"
t1, t2 = string.match(s, "(a)(b)%2")  -- 왼쪽의 패턴은 결국 a와 b 그리고 두번째 capture의 결과(%2)인 b를 받아서 abb인 패턴만 감지할 수 있다.
print(t1)
print(t2)

-- %n를 gsub에 사용할 경우, %n은 패턴(두번째 파라미터)과 대체문자열(세번째 파라미터)에 둘다 쓰일 수 있다.
-- 특히 %0는 패턴내에서 매칭된 문자열 전체를 의미한다.
print((string.gsub("hello Lua!", "%a", "%0-%0")))

-- 다음에서, (.)(.)%2 패턴을 만족시킬 수 있는 문자열은 ell밖에 없으며, %0에는 ell %2에는 l %1에는 e가 대응하므로, 결과적으로 ell부분이 ellle로 교체된다.
print((string.gsub("hello Lua", "(.)(.)%2", "%0%2%1")))

-- capture를 이용해서 LaTeX 문법을 변환하는 예시
s = [[the \quote{task} is to \em{change} that.]]
s = string.gsub(s, "\\(%a+){(.-)}", "<%1>%2</%1>")
print(s)

-- 패턴으로 트림을 구현하는 예시
function trim (s)
	s = string.gsub(s, "^%s*(.-)%s*$", "%1")
	return s
end

print("\n-------------Replacements-------------")
-- string.gsub의 세번째 파라미터에 "함수"가 들어가면, 패턴이 매칭될 때마다 함수를 호출한다.
-- 각 호출에서의 인수는 capture에서 얻어진 값이고 반환값은 대체할 문자열이 된다.

-- string.gsub의 세번째 파라미터에 "테이블"이 들어가면,
-- 첫번째 capture를 키로 사용하여 조회된 값이 대체할 문자열이 된다.

-- 함수호출/테이블조회의 결과가 nil이면 변경이 발생하지 않는다.

name = "Lua"; status = "great"
print((string.gsub("$name is $status, isn't it?", "$(%w+)", _G))) -- 여기서 _G는 모든 글로벌 변수를 담고 있는 사전정의된 테이블이다.

print((string.gsub("print = $print; a = $a", "$(%w+)", function (n) return tostring(_G[n]) end)))

print(string.match("hello", "()l()l()")) -- 내용이 들어있는 괄호는 괄호 안의 내용을 capture하지만, 
-- 빈 괄호 () 를 사용하면 괄호에 해당하는 위치의 인덱스를 capture한다.
-- 괄호가 없을 경우 기본적으로 패턴 전체가 caputure 영역이 된다 
-- 즉, capture란 ()로 영역을 표시하지 않아도 패턴에서 항상 적용되고 있다
-- 반대로, ()는 기본적으로 패턴 전범위인 capture영역을 제한시켜주는 역할을 한다고 생각하면 좋다. ***

-- 주의 : 다른 빈괄호의 위치는 고려하지 않고 매칭값을 기준으로 자신의 빈괄호의 위치에 어떤 새로운 문자가 들어온다고 가정할 경우의 인덱스를 반환하게 된다.
-- 즉, ()l()l()의 경우,
-- 첫번째 빈괄호 he()llo 이므로 3
-- 두번째 빈괄호 hel()lo 이므로 4
-- 세번째 빈괄호 hell()o 이므로 5 이다. (옳은 해석)

-- 즉, he()l()l()o 도 아니며, : 3, 5, 7 (틀린 해석)
-- h(e)l()l(o) 는 더더욱 아니다. : 2, 4, 6 또는 2, nil, 5 (틀린 해석)

print(string.find("hello", "ello"))

print("\n-------------Tricks of the Trade-------------")
-- 패턴 매칭은 문자열 조작에 있어 강력한 툴이지만, 적절하게 구현된 파서를 대체할 수는 없다.
-- 느슨한 패턴은 구체화된 패턴보다 느리다.
i, j = string.find("asef", ".-")
print(i,j) -- 출력결과가 1 0 인 이유는 .-에 의해 비어있는 값도 매칭대상에 포함되기 때문이다.
i, j = string.find(";$% **#$hello13", "%a*")
print(i,j) -- 출력결과가 1 0 인 이유는 문자열 시작부분에서 첫번째 매칭결과가 비어있는 값으로 매칭이 되어버렸기 때문이다.

-- 이 이후의 내용은 예시 또는 utf8에 관한 내용

-- end of chapter