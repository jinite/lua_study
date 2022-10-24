-- CH.07 The External World

-- 스킵한 내용 리스트 (pdf페이지 기준)
-- p.63 8~19





-- Lua는 외부세계와 통신하기 위한 많은 기능을 제공하지는 않는다.
-- 순수한 Lua는 오로지 ISO C 표준이 제공하는 기능만을 제공한다. 즉, 기본적인 파일조작과 일부 추가기능만 제공한다.

print("\n-------------The Simple I/O Model-------------")
-- 라이브러리는 current input stream을 standard input(stdin)으로 초기화하고
-- current output stream을 standard output(stdout)으로 초기화 한다.

-- 하지만, current I/O stream을 io.input과 io.output 함수를 사용하면 바꿀 수 있다.
-- ex) io.input(filename)
-- io.input과 io.output이 적용된 시점부터, current I/O stream 새로 적용된 I/O stream으로 유지된다.
-- 다시 standard I/O stream으로 돌아오기 위해서는,
-- io.input(io.stdin), io.output(io.stdout) 을 해주면 된다.

-- current I/O stream으로부터, 쓸 때는 io.write를 사용하고 읽을 때는 io.read를 사용한다.
-- print는 항상 standard output에 쓰고 인수에는 tostring이 적용되며 개행등의 추가 문자가 들어가지만
-- io.write은 current output stream에 쓰며, 어떠한 추가작업도 들어가지 않는다.

io.input("testfile.txt")
--a = io.read("a") -- "a" 전체파일 읽기, "l" 한줄을 읽고 개행을 제거, "L" 한줄을 읽고 개행 유지, "n" 숫자를 순서대로 읽어오기, num num개 만큼의 글자를 문자열로 읽어오기
--io.write(a)

for count = 1, math.huge do
	local line = io.read("L") -- 라인을 읽고
	if line == nil then
		break
	end
	io.write(string.format("%6d ", count), line) -- 현재 라인수와 라인의 내용을 출력하라
end

print("\n-------------The Complete I/O Model-------------")
-- Simple I/O Model 은 간단한 파일조작에는 편리하지만, 고급 파일조작에는 충분하지 않다.
-- io.open 함수를 사용하면 C 함수의 fopen 과 유사한 작업을 할 수 있다.
-- r : 읽기, w : 쓰기, a : 추가, b : 바이너리 파일 열기
-- io.open 함수는 새로운 파일스트림을 반환한다. 에러가 발생한 경우 nil을 반환한다.
print(io.open("non-existent-file", "r"))
print(io.open("/etc/passwd", "w"))
-- assert(r, message) : r이 true면 에러가 발생하지 않고, r이 false면 에러 메세지(message)를 발생시키며 프로그램을 중단한다.
-- assert(io.open("/etc/passwd", "w")) : 에러 발생시 에러메세지를 띄우기 위해 이와같은 형식으로 사용하게 된다.

-- 파일 열고 닫기 기본 예시
-- local f = assert(io.open(filename, "r"))
-- local t = f:read("a")
-- f:close()

-- io.stderr:write(message) : 에러메세지 전달

-- @ Simple model 에서 사용하던 io.input 과 io.output 는 Complete model과 섞여서 사용이 가능하다.
-- local temp = io.input() -- 현재 스트림 저장
-- io.input("newinput") -- 새로운 스트림 설정
--               (어떤 작업 수행)
-- io.input():close() -- 현재 스트림 닫기
-- io.input(temp) -- 저장된 스트림 복원

-- for in 확인

print("\n-------------Other Operations on Files-------------")
-- io.tmpfile : 임시 파일의 스트림을 반환한다
-- io.flush : 현재의 출력 스트림을 flush 한다
-- f:flush : 스트림 f 에 대해 flush 한다
-- setvbuf : 버퍼링 모드를 설정한다. "no" : 버퍼링 없음, "full" : 꽉 차면 flush, "line" : 새로운 라인이 되었을 때 flush

-- io.stderr : 대부분의 시스템에서 표준 에러 스트림은 버퍼링 되지 않는다.
-- io.stdout : 반면, 표준 출력 스트림은 라인모드로 버퍼링 된다. 그러므로, 라인이 완성되지 않았을 때 내용을 출력하고 싶다면, flush가 이루어져야한다.

-- seek : 파일에서 현재 위치를 설정하거나 얻을 수 있다. "set" : 파일 시작으로부터의 오프셋, "cur" : 현재 위치로부터의 오프셋, "end" : 파일 끝으로부터의 오프셋
-- file:seek() : 현재위치 반환 ("cur"이 디폴트임)
-- file:seek("set") : 파일 시작위치로 이동
-- file:seek("end") : 파일 종료위치로 이동하고 사이즈 반환

-- os.rename : 파일이름 변경 (io테이블이 아니라 os테이블이라는 것 주의)
-- os.remove : 파일 삭제

print("\n-------------Other System Calls-------------")
-- os.exit : 프로그램 종료
-- os.getenv : 환경변수 획득
print(os.getenv("path"))
-- os.execute : 시스템 커맨드 실행 (C의 system 함수와 유사)
-- io.popen : 시스템커맨드를 실행하고, 커맨드의 출력(또는 입력)을 스트림과 연결하여 해당 스트림을 반환한다. (쉽게 말해, 커맨드의 결과를 스트림으로 받아볼수 있다)
local f = io.popen("dir /B", "r") -- 시스템 커맨드를 실행하고 읽기모드로 스트림을 받아올것
local dir = {}
for entry in f:lines() do -- lines iterator를 이용하여
	print(entry) -- 각 값을 한개씩 출력
end
-- 더 향상된 OS접근을 위해서, 라이브러리 사용을 권장 (LuaFileSystem, luaposix 등)




-- end of chapter