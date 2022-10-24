-- CH.12 Date and Time

-- Lua에서는 standard C에서 제공하는 기능정도만을 제공하지만 이것만으로도 많은 것들을 할 수 있다.
-- 첫번째 표현방식은 epoch라고 불리는 기준시각(Jan01, 1970, 0:00 UTC)을 기준으로 초를 계산하는 시간 계산법 (타임존 상관없이 지구상의 한지점을 기준으로 시간을 계산)
-- 두번째 표현방식은 테이블을 이용하는 것이다.
--  year 연도, month 월, day 해당월의 일수, hour 시각, min 분, sec 초
--  wday 해당주의 일수, yday 해당년의 일수, isdst daylight saving time 적용여부
-- Lua에서 사용하는 date 테이블은 타임존에 관한 필드는 존재하지 않는다.

print("\n-------------The Function os.time-------------")

os.time() -- 출력값 : epoch time (타임존과 상관없이 Jan01, 1970, 0:00 UTC 를 기준으로 흘러간 초)
os.time({year=2015, month=8, day=15}) -- 출력값 : epoch time, 입력값 : 로컬타임의 date테이블 (year, month, day는 필수 필드이며 시간은 입력되지 않을경우 정오로 설정됨)

print("\n-------------The Function os.date-------------")

os.date("%c", os.time()) -- os.date : epoch time을 입력 받아서 local time을 형식에 맞게 출력한다.
os.date("*t", os.time()) -- *t를 사용하면 epoch time(os.time)을 local time으로 변환한 것을 date테이블로 출력받을 수 있다.
os.date("!%c", 0) -- !로 시작할 경우 epoch time을 입력 받아서 UTC 기준의 시각을 형식에 맞게 출력한다.

print("\n-------------Date-Time Manipulation-------------")
-- os.date : epoch time으로부터 테이블또는 문자열 생성 --> 테이블 생성시 모든 필드가 적절한 영역안의 값을 가지고 있다.
-- os.time : 로컬 date 테이블로 부터 epoch time 생성 --> 테이블의 값이 영역을 벗어나도 그에 맞게 epoch time이 생성된다.
-- 즉, 어떤 식으로 시간을 더하거나 빼도, 함수를 거치고 나면 적절한 시간으로 정규화되어 반환된다는 것이다.
-- 기존의 epoch time에 초를 직접 더해서 날짜를 계산하는 방식은 여러 문제를 발생시킬 수 있으므로, date 테이블을 이용한 정규화 방식을 권장한다.
-- 하지만, 날짜의 특성상 정규화 방식에도 인식과 어긋나는 결과가 발생할 수 있다.
-- 예를들어, 3월 31일의 한달뒤는 4월 31일이지만, 4월 31일은 존재하지 않으므로 5월 1일로 정규화된다. (틀리진 않았지만 불합리하게 느껴지는 정규화)
-- 이런 것들으 현실의 달력의 작동방식이 반영된 결과이므로, Lua와는 아무런 관련이 없다.

local t5_3 = os.time({year=2015, month=1, day=12})
local t5_2 = os.time({year=2011, month=12, day=16})
local d = os.difftime(t5_3, t5_2) -- os.difftime을 사용해서, 날짜의 시간간격을 초단위로 구할 수 있다.
-- 단순히 초를 빼서 계산하는 것과는 달리 os.difftime의 결과는 어떤 시스템에서도 보장된다. (?)

local x = os.clock()
local s = 0
for i = 1, 100000 do s = s + i end
print(string.format("elapsed time: %.2f\n", os.clock() - x)) -- os.clock을 사용해서 프로그램에서 사용된 cpu타임을 구할 수 있다.
-- os.difftime도 사용될 수 있으나, os.clock은 microsecond의 정확도를 가지고 있으므로(float형 반환), cpu타임에 대해선 os.clock이 권장된다.


print(s.hour)
-- end of chapter