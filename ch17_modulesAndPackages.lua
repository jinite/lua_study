-- CH.17 Modules and Packages

-- Lua에서 모듈은 require함수를 통해 로드되어 테이블로서 반환된다.
-- 모든 표준 라이브러리는 모듈이다.
local m = require "math"
print(m.sin(3.14))

-- 그러나, stand-alone interpreter는 모든 표준 라이브러리 다음과 같은 형식으로 미리 읽어들인다.
math = require "math"

-- 모듈이 테이블을 이용하는 가장 큰 이점은, 다른 테이블과 동일한 형식으로 모듈을 조작할 수 있다는 것이다.
-- 또한, Lua에서의 모듈은 변수와 같이 취급할 수 있다.

-- 모듈을 불러오기 : local mod = require "mod"
-- 모듈의 특정함수만 불러오기 : local f = require "mod".foo

print("\n-------------The Function require-------------")
-- require 함수의 이런 중요한 역할에도 불구하고, 이 함수는 일반 함수이고, 다른 함수와 동일한 규칙을 적용받는다.
-- 그러므로 다음과 같이 사용하는 것도 가능하다.
-- local m = require('math')
-- local modname = 'math'
-- local m = require(modname)

-- require 함수의 첫번째 작업은 package.loaded 테이블에서 이미 해당 모듈이 로드되었는지 확인하는 작업이다.
-- 만약 기존에 require함수에 의해 로드된적이 있는 모듈이라면, 새로 로드하지 않고 기존의 값을 가져온다.
-- 모듈이 아직 로드된적이 없다면, 모듈이름으로 Lua파일을 검색한다(package.path기반).
-- 해당 파일을 찾으면, loadfile로 로드한다.
-- 그리고 loadfile함수가 리턴한 결과는 loader이다.
-- ※loader : loadfile로 읽혀진 청크를 실행하는 능력을 가진 함수 (모듈을 로드하는 능력을 가진 함수) (--> 청크를 그대로 함수화 시킨것)
-- 해당 파일이 없을 경우, 해당 이름을 가진 C라이브러리를 검색한다(package.cpath기반).
-- C라이브러리를 찾으면, 저수준 함수인 package.loadlib함수를 통해 luaopen_modname이라는 C함수를 로드한다.
-- 이 경우, loader는 loadlib의 리턴값이자, Lua로 표현되는 C함수인 luaopen_modname이다.

-- loader파일이 어떤 경로를 통해서 생성이 되든, require함수는 이제 loader를 갖게 되고, 모듈을 로드하기 위해서,
-- 두개의 인자(모듈 이름, loader를 획득한 파일명)를 전달하면서 loader함수를 실행한다.(대부분의 모듈은 이 인자들을 무시한다)
-- 만약, loader가 어떤 값을 리턴한다면, require함수는 이 값을 리턴하고, package.loaded테이블에 저장한다. (package.loaded 테이블에 저장되기 위해선 모듈명과 테이블 참조값이 필요)
-- 만약, loader가 아무 값도 리턴하지 않고, 여전히 package.loaded에 해당 모듈이 없으면, require 함수는 해당 모듈이 true를 반환한 것처럼 행동한다.
-- 이렇게 보완하게 되면, 리턴값이 존재하는 모듈과 동일하게 package.loaded테이블에 등록되므로, 값을 리턴하지 않는 loader도 다시 실행되지 않게 된다.
-- 동일한 모듈을 다시한번더 불러오고 싶다면, package.loaded.modname = nil 과 같이 모듈을 테이블에서 제거해주면 된다.

for a, b in pairs(package.loaded) do -- 모든 로드된 모듈 확인
	print(a,b)
end

-- require함수에 대한 가장 흔한 불만은 모듈 자체에 인수를 전달할 수 없다는 것이다.
-- 모듈에 인수를 전달할 수 없다는 것은, 모듈의 초기값을 세팅할 수 없다는 것이다.
-- 그러므로, 모듈 내부에 초기화를 담당하는 함수를 명시적으로 정의하여 사용한다. 만약 초기화 함수가 모듈 자체를 리턴한다면 다음과 같은 코드도 가능하다.
-- local mod = require "mod".init(0, 0)
-- require를 사용한 경우, 어떠한 경우에도 동일한 모듈이 package.loaded테이블 상에 중복으로 할당되는 경우는 없으므로,
-- 서로다른 값으로의 초기화로 인한 충돌을 회피하고 싶다면, 이것은 전적으로 프로그래머에 달려있다.

--- 모듈이름 충돌의 회피방법
-- Lua 기반 모듈 -> 일반적으로 파일이름을 변경하는 것으로 해결해야 함
-- C기반 모듈 -> require에서 제공하는 하이픈의 특수기능을 이용하여 해결 : luaopen_modname 함수의 경우, 모듈이름 modname-v1, modname-v2 등으로 하나의 모듈을 중복로드 가능

--- 경로검색
-- 함수 require가 사용하는 패스는 전형적인 패스와는 조금 다르다.
-- 전형적인 패스는 찾고자하는 파일을 검색할수 있는 디렉토리의 리스트지만, Lua가 가동되고 있는 추상 플래폼인 ISO C는 디렉토리의 개념이 없다.
-- 그러므로 Lua가 사용하는 패스는 template의 리스트이다. 각 template는 모듈이름을 파일이름으로 변환하기위한 대안책을 구체화하고 있다.
-- template란 다음과 같이 생겼다.(; 구분자, ? require에서 전달받은 모듈명이 들어가는 곳)
-- ?;?.lua;c:\windows\?;/usr/local/lua/?/?.lua

-- 여기서 만약, require "sql"을 호출하면 다음의 경로가 호출된다.
-- sql
-- sql.lua
-- c:\windows\sql
-- /usr/local/lua/sql/sql.lua

-- package.path : require 함수가 Lua파일을 검색할 때 사용하는 경로 template가 저장된 변수
-- 모듈 package가 초기화 될 때, package.path는 다음의 우선순위로 template를 참조한다.
-- 환경변수 LUA_PATH_5_3 -> 환경변수 LUA_PATH -> 컴파일된 정의된 기본경로

-- 환경변수에서 마지막에 ;; 를 사용하게 되면, 마지막 경로가 기본경로로 설정된다. -- 검증필요

-- package.cpath : require 함수가 C코드를 참조할 때 사용하는 하는 변수. package.path와 동일한 방식으로 동작한다.
-- 참조하는 환경변수 : LUA_CPATH_5_3, LUA_CPATH
-- POXIS에서의 template : ./?.so;/usr/local/lib/lua/5.2/?.so
-- WINDOWS에서의 template : .\?.dll;C:\Program Files\Lua502\dll\?.dll

print(package.path)
print(package.cpath)

-- package.searchpath : 라이브러리를 검색하는 모든 규칙을 인코딩한다. 모듈의 이름과 경로를 얻어서, 여기에 설명된 규칙에 따라 파일을 검색한다.
-- package.searchpath("X", path) : X 모듈에 대해서, path template에 따라 파일을 검색하고 결과를 반환한다. (성공시 파일경로 반환, 실패시 nil과 파일경로반환)
print(package.searchpath("dofiletest",package.path))


--- Searcher
-- 실제적으로 require는 위에서 설명한 것 보다 좀더 복잡하게 구성되어있다.
-- Lua파일을 검색하고 C라이브러리를 검색하는 것은 seacher라는 개념의 두가지 사례일 뿐이다.
-- ※searcher : 모듈이름을 취하고 해당 모듈의 loader를 반환하는 단순 함수 (찾지 못할 시 nil반환)
-- ※package.searchers : require가 사용하는 searcher의 배열

for a, b in pairs(package.searchers) do -- 모든 searcher 리스트 확인
	print(a,b)
end

-- 모듈을 찾을 때, require 함수는 각 searcher 에 모듈명을 넘기고 nil이 아닌 loader를 반환할 때까지 반복한다.
-- 만약 적절한 loader가 반환되지 않을 시, 에러를 발생시킨다.
-- package.searchers 같은 리스트를 사용하는 것은 require함수가 모듈을 검색할 때 유연성을 제공한다.
-- 특정한 파일형식의 모듈을 읽고 loader를 반환할 때, 단순히 package.searchers에 특정한 형식에 대한 searcher를 추가해 두기만하면 된다.

-- package.searchers 의 기본설정
-- [1] preload searcher
-- [2] searcher for Lua files
-- [3] searcher for C libraries
-- [4] a function relavent only for submodules

-- preload searcher는 모듈을 읽어들이는 임의의 함수의 정의를 허용한다.
-- ※package.preload : preload searcher가 모듈 이름과 그에 해당하는 loader 함수를 검색하기 위해 사용하는 테이블
-- 모듈이름을 검색할 때, 이 searcher는 단순하게 package.preload테이블에 해당 모듈 이름이 존재하는지 확인한다.
-- 만약 거기서 loader 함수를 찾는다면, loader 함수를 반환한다. 그렇지않으면, nil을 반환한다.
-- 그러므로, 이 searcher는 일반적이지 않은 상황을 다룰 때 사용하는 기본 메소드 이다.
-- 예를들어, Lua에 정적으로 연결된 C라이브러리가 그 luaopen_함수를 package.preload테이블에 등록할 수 있다.
-- 이를통해, 사용자가 해당 모듈을 요구할 때는, 해당 로더를 특정하여 불러 올 수 있다.

print("\n-------------The Basic Approach for Writing Modules in Lua-------------")
--- 1. 모듈 구성방법 1 (베이직)
-- 모듈은 일반적으로 다음과 같이 구성 가능하다.
-- local M = {} -- 테이블을 선언후
-- M.asdf = function () -- 함수 정의후
-- return M -- 테이블을 리턴한다.

-- 모듈안에서 local 선언되지 않으면, 전역값이 되므로 외부에서 접근이 가능하다.
-- 그러므로, private 함수로 사용하고 싶다면, local을 사용하면 된다.
-- local asdf2 = function()

--- 2. 모듈 구성방법 2 (리턴을 없애는 법)
-- loader함수는 16장에서 설명한 것 처럼 다변수 함수로 취급되나, require 함수에 의해 발생하고 실행된 로더함수는 위에서 설명한 것처럼,
-- 전달하는 인자(모듈 이름, loader를 획득한 파일명)가 이미 정해져 있다.
-- 그러므로 아래와 같은 방식으로, 리턴을 하지 않고도 모듈을 package.loaded 테이블에 직접 등록할 수 있다.
-- local M = {}
-- package.loaded[...] = M
-- 하지만, 일반적으로 마지막에 리턴을 사용하는 것이 읽기쉬운 코드를 구성하는 것에 도움이 된다.

--- 3. 모듈 구성방법 3 (험수 리스트 작성)
-- private으로 사용할 함수와 private으로 사용하지 않을 함수를 둘다 local로 선언하여
-- 최후에 내보낼 함수만 테이블에 리스트로 내보내는 것.
-- local a = function ()
-- local b = function ()
-- return {a = a, b = b}

print("\n-------------Submodules and Packages-------------")
-- Lua에서는 모듈명의 계층구조를 나타내기위해 구분자로 .을 사용한다.
-- 예를 들어 mod.sub이라는 모듈은 mod의 하위 모듈이다.
-- package는 트리구조로 구성된 모듈의 집합을 의미하고 이것은 Lua의 배포단위이다.

-- require 함수가 mod.sub이라는 모듈이름을 입력받게 되면,
-- package.loaded테이블을 쿼리하여, 현재 모듈이 등록되어있는지 확인한다.
-- 그 다음, preload searcher 사용하는 package.preload테이블을 쿼리하여, 해당 모듈명이 존재하는지 확인한다.
-- 여기까지에서, mod.sub이라는 모듈이름은 .을 구분자로 보지 않고, 단순히 모듈이름에 지나지 않는다.

-- 하지만, package.searchers가 파일을 검색하는 단계로 들어가게 되면,
-- 여기서부터, require함수는 .을 시스템의 디렉토리 구분자로 해석하게 된다. (POSIX 는 슬래쉬, WINDOWS는 역슬래쉬)
-- 예를 들어, package.path가 다음의 template를 참조하고 있다면,
-- ./?.lua;/usr/local/lua/?.lua;/usr/local/lua/?/init.lua
-- require가 모듈명 mod.sub에 대해서 접근하려고 시도하는 파일은, 아래와 같다.
-- ./mod/sub.lua
-- /usr/local/lua/mod/sub.lua
-- /usr/local/lua/mod/sub/init.lua

-- Lua가 사용하는 디렉토리 구분기호는 컴파일타임에 구성되고, 어떤 문자열이든 가능하다.
-- 만약, 계층적 디렉토리를 갖지 않는 시스템이라면 / 대신에 _를 사용하여 서브모듈을 포현할 수 있다.

-- C라이브러리의 모듈의 초기화 함수는 luaopen_modname과 같은 이름 형식을 갖는데 서브모듈의 경우에는 luaopen_mod.sub과 같은 이름의 함수를 만들 수 없으므로,
-- luaopen_mod_sub과 같은 함수명이 된다.

-- Lua는 C 서브모듈을 위한 추가적인 searcher를 제공한다.
-- Lua나 C파일의 하위모듈까지 검색하여 찾을 수 없는 경우, package.searchers의 4번째 searcher가 동작한다.
-- 이 searcher는 다시 C라이브러리에서 검색을 수행한다.
-- 만약 mod.sub.sub2가 있다고 할 때, 먼저 mod라는 이름의 C라이브러리(mod.dll등)를 가져오고, 
-- 그 안에 정의된, luaopen_mod_sub_sub2함수에 접근한다.

-- 동일한 package내에서 Lua의 서브모듈은 모듈간에 직접적인 연관성을 갖지 않는다.
-- 즉, 어떤 모듈을 읽어왔다고 해서, 다른 모듈이 자동적으로 읽혀지지는 않는다.
-- 물론, 하나의 모듈 안에서 다른 모듈의 내용을 읽어와서 사용하는 것은 개발자의 자유이다.

-- end of chapter