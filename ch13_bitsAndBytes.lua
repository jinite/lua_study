-- CH.13 Bits and Bytes

-- 비트 확인용 임시 함수 (예상치 못했지만 음의 정수도 정상적으로 표현이 된다)
function bitsOf(x, n) -- x : 정수, n : 표시할 자릿수
	local result = ""
	for i = 1, n do
		if x % 2 == 1 then
			result = "1" .. result
		else
			result = "0" .. result
		end
		if i % 8 == 0 then result = " " .. result end
		x = x // 2
	end
	return result
end

-- Lua는 텍스트와 유사하게 바이너리 데이터를 다룬다.
-- Lua의 문자열을 다루는 거의 대부분의 라이브러리 함수들은 임의의 바이트를 다룰 수 있다.

print("\n-------------Bitwise Operators-------------")
-- Lua version 5.3 부터 number값에 대한 표준 비트 연산자를 제공한다. 산술연산자와는 달리 정수값에 대해서만 작동한다.
-- & : and, | : or, ~ : exclusive-or, >> : logical right shift, << : logical left shift, ~ : bitwise not 
print(string.format("%x", 0xff<<16))

-- 표준 Lua에서는 64비트를 지원하지만, 64비트 정수에 대해 상위 32비트를 제거하면 32비트 정수조작도 수행할수 있다.
-- lua는 right shift 연산에 대해 산술적 right shift (right shift 시에 부호비트로 빈공간을 채워주는것) 제공하지 않는다. (shift연산에 대해 빈공간은 무조건 0으로 채운다)
-- 대신, floor division (x//(2^n)) 을 수행함으로써, 산술적 right shift와 동일한 결과를 얻을 수 있다.
print(string.format("%x", 0xff<<16))
print(bitsOf(-752,32))
print(bitsOf(-752 // 2^3,32)) -- -752를 산술적 right shift를 수행함.
-- x << n 은 x >> -n과 같은 결과를 준다.

print("\n-------------Unsigned Integers-------------")
-- lua는 부호없는 정수형에 대한 명시적인 지원은 제공하지 않으나, 약간의 주의를 기울이면 unsigned integer를 다룰 수 있다.
-- 여기서 문제는, 값이 정수형 변수에 어떻게 저장되냐가 아니라 Lua가 그것을 어떻게 보여주는가이다.
-- signed 정수형의 표현방식으로 인해, 더하기, 빼기, 곱하기에 대해서, unsigned 정수형과 동일한 방식으로 작동한다.
-- 즉, signed 정수형을 unsigned 정수형으로 취급하고, 더하기, 빼기, 곱하기를 해도 저장된 값의 bit배열은 일관성을 유지한다는 것이다.
-- 하지만, 비교를 수행할 때는 그 결과가 달라지게 되는데, signed 정수형의 최상단 비트는 부호비트이기 때문이다.
-- Lua는 signed 정수형을 unsigned 정수형이라고 가정할 경우에 비교를 수행하는 함수를 제공한다. math.ult(a, b), a less than b, (a < b)
-- 또, 다른 비교 방법은 부호비트를 반전시켜 비교하는 방식이 있다.
-- 나누기의 경우도, unsigned와 signed의 저장 결과는 차이가 난다.


print("\n-------------Packing and Unpacking Binary Data-------------")
-- Lua는 값을 바이너리 데이터로 변환하는 기능을 제공한다.

-- string.pack(p, v1, v2, v3, ...) : p패턴에 따라, v1, v2, v3 ... 등을 전부 엮어 하나의 문자열로 (취급할 수 있는 바이너리로 데이터로) 변환
-- string.unpack(p, s, i) : p(format string)패턴 만큼 s문자열을 순차적으로 읽어들이되, i지점부터 읽기 시작한다.
s = string.pack("iiiiii", 3, -27, 450, 4, 7, 9, 45) -- 6개의 정수패턴으로 하나의 문자열을 제작
print(#s)
v1, v2, v3, i = string.unpack("iii", s) -- 3개의 정수만 읽어들임 (정수 1개에 4바이트가 되어 i에는 마지막으로 읽어들인 바이트의 다음 바이트인 13이 저장된다)
print(v1, v2, v3, i)
v1, v2, v3, i = string.unpack("iii", s, i) -- 그 다음 3개의 정수만 읽어들임
print(v1, v2, v3, i)
-- 패턴을 준수하는 문자열을 만들수만 있다면 굳이 string.pack함수를 쓰지 않아도 string.unpack이 가능한 문자열을 제작할 수 있다.

-- # 정수를 다루는법
-- b는 char형, h는 short형, i는 int형, l은 long 형으로 취급된다.
x = string.pack("i7", 1 << 54) -- 정수가 저장되는 길이를 지정하기 (7바이트 정수로 저장된다)
print(#x)
-- 기존의 문자를 대문자로 바꾼 정수패턴은 unsigned integer 형으로 취급한다.
s = "\xFF"
string.unpack("b", s) --> b : signed integer
string.unpack("B", s) --> B : unsigned integer

-- # 문자열을 다루는법
-- 문자열을 표현하는 3가지 방법이 존재한다.
-- 1. 0으로 끝나는 문자열　(z)
-- 2. 고정 길이 문자열 (cn) : n바이트로 문자열 길이 고정
-- 3. 명시적으로 길이를 정의한 문자열 (sn) : 문자열의 길이를 n바이트로 표현
s = string.pack("!2s3", "hello")
print(s)
 
-- # 부동소수점을 다루는 법
-- f는 단정도 부동소수점
-- d는 배정도 부동소수점
-- n은 Lua float

-- # 엔디안 컨트롤하는 법
-- 디폴트 값으로, Lua는 머신이 사용하는 엔디안 규칙을 따른다.
-- >는 후속하는 인코딩을 빅 엔디안 (또는 network byte order)으로 바꾼다.
-- <는 리틀 엔디안으로 바꾼다.
-- =는 머신의 디폴트 엔디안으로 되돌린다.
 
-- # 기타
-- n! : 정렬하기 (사용방법을 잘 모르겠음, 스킵)
-- x : 1바이트 패딩 (사용방법을 잘 모르겠음, 스킵)

print("\n-------------Binary files-------------")
-- io.input, io.output은 항상 텍스트모드로 파일을 연다
-- POXIS에서는 바이너리 파일과 텍스트 파일의 차이가 없으나 윈도우같은 일부 시스템에서는 바이너리를 파일을 여는데 특별한 방법이 필요하다. (io.open 의 옵션 b)

-- 여기서는 파일의 유용한 바이너리 처리 예시 설명
-- 1. 윈도우 텍스트 파일을 유닉스 텍스트 파일로 변환
-- 2. 바이너리 파일에서 모든 문자열 찾아서 출력
-- 3. hex dump 출력


-- end of chapter