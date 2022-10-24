-- CH.14 Data Structures
-- Lua의 테이블은 어떤 데이터 구조의 일종이 아니다.
-- 테이블은 우리가 익히 아는 그 데이터 구조 그 자체이며, 다른 언어가 제공하는 모든 데이터 구조를 효율적으로 표현할 수 있다.
-- 테이블은 모든 유형에 대한 직접 접근을 제공하므로, 검색을 구현할 필요가 없다.
-- 테이블을 효율적으로 사용하기 위해서는 시간이 걸리지만, 여기서는 일반적인 데이터 구조를 구현하는 방법과, 몇가지 예시를 살펴본다.

print("\n-------------Arrays-------------")
-- 배열을 어떤 인덱스로 만들어도 상관없지만, 인덱스 1 부터 시작하는 것이 Lua의 관습이다.
-- Lua의 라이브러리들은 전부 이 관습에 따라 만들어져 있다.

print("\n-------------Matrices and Multi-Dimensional Arrays-------------")
-- 테이블로 행렬을 구현하는 두가지 방법
-- 1. 테이블의 테이블을 이용하는 방법
-- 명시적을 각 행을 선언해야한다.
row1 = {3}
row2 = {4}
a = {row1, row2}
print(a[1][1], a[2][1])

-- 2. 테이블의 인덱스가 각 행/열을 나타내도록 수학적으로 구조화하는 방법
local mt = {} -- create the matrix
N = 3; M = 3
for i = 1, N do
	local aux = (i - 1) * M
	for j = 1, M do
		mt[aux + j] = 0
	end
end

-- nil 값은 0으로 취급하여 값이 존재하는 행열의 연산만 수행하여 sparse matrix의 행렬곱을 구하는 방법
function mult (a, b)
	local c = {} -- resulting matrix
		for i = 1, #a do
			local resultline = {} -- will be 'c[i]'
			for k, va in pairs(a[i]) do -- 'va' is a[i][k]
				for j, vb in pairs(b[k]) do -- 'vb' is b[k][j]
					local res = (resultline[j] or 0) + va * vb
					resultline[j] = (res ~= 0) and res or nil
				end
			end
			c[i] = resultline
		end
	return c
end
print("\n-------------Linked Lists-------------")
-- linked list의 구현
list = {next = list, value = 1}
list = {next = list, value = 2}
list = {next = list, value = 3}
print(list, list.value)
print(list.next, list.next.value)
print(list.next.next, list.next.next.value)

print("\n-------------Queues and Double-Ended Queues-------------")
-- Double-Ended Queues의 구현
function listNew () -- 새로운 큐 생성
	return {first = 0, last = -1}
end
function pushFirst (list, value) -- 첫번째에 넣기
	local first = list.first - 1
	list.first = first
	list[first] = value
end
function pushLast (list, value) -- 마지막에 넣기
	local last = list.last + 1
	list.last = last
	list[last] = value
end
function popFirst (list) -- 첫번째에서 꺼내기
	local first = list.first
	if first > list.last then error("list is empty") end
	local value = list[first]
	list[first] = nil -- to allow garbage collection
	list.first = first + 1
	return value
end
function popLast (list) -- 마지막에서 꺼내기
	local last = list.last
	if list.first > last then error("list is empty") end
	local value = list[last]
	list[last] = nil -- to allow garbage collection
	list.last = last - 1
	return value
end
-- 본 구조는 first와 last에서 계속 증가하는 구조를 갖고 있지만,
-- 64비트 정수로 인덱싱할 경우 초당 천만번씩 30000만년 동안 가동이 가능하다.

print("\n-------------Reverse Tables-------------")
-- 리버스 테이블이란, 본래의 테이블의 값과 키를 서로 교환한 테이블을 말한다.
-- 키로 검색이나 할당이 용이하지 않을 때, 리버스 테이블을 생성하여
-- 값으로 검색하여 키를 찾는다.
days = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
revDays = {} -- 리버스 테이블 생성
for k,v in pairs(days) do
	revDays[v] = k
end

print("\n-------------Sets and Bags-------------")
reserved = { -- set의 구현 (set에 단어가 존재하는지 확인하는 테이블)
 ["while"] = true, ["if"] = true,
 ["else"] = true, ["do"] = true,
}
function Set (list) -- list의 value로부터 set을 생성하는 함수
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

-- bag의 구현
function insert (bag, element) -- bag에 element를 삽입하고 그 수를 1 증가시킨다
	bag[element] = (bag[element] or 0) + 1
end
function remove (bag, element) -- bag에 element를 꺼내고하고 그 수를 1 감소시킨다
	local count = bag[element]
	bag[element] = (count and count > 1) and count - 1 or nil
end

print("\n-------------String Buffers-------------")
-- Java나 다른 언어에서도 그렇지만, Lua도 문자열 변수가 불변값이므로,
-- .. 를 이용한 문자열 결합등의 처리는 문자열의 길이가 길어질 때 성능저하로 이어진다.
local buff = ""
for line in io.lines() do
	buff = buff .. line .. "\n" -- 비효율적
end
-- Java에서는 이런 것을 방지하기 위해서, String Buffer등의 클래스를 제공한다.
-- Lua에서는 테이블에 먼저 문자열을 삽입하고, table.concat() 함수를 사용함으로써 동일한 효과를 낼 수 있다.
local t = {}
for line in io.lines() do
	t[#t + 1] = line .. "\n"
end
t[#t + 1] = ""
local s = table.concat(t)

print("\n-------------Graphs-------------")
-- 그래프란 노드와 엣지로 이루어진 구조를 말한다.
-- 각 노드는 엣지로 연결되며, 엣지는 방향이 있을 수도 있고 없을 수도 있고, 가중치가 있을 수도 있고 없을 수도 있다.
-- 방향성과 가중치의 유무에 따라 그래프의 종류가 달라진다.
-- 각 노드에서 다른 노드로 연결되는 경로를 탐색할수도 있고, 최적의 경로를 구할수도 있다.

-- graph : key -> 노드명, value -> 노드
-- node : key -> 노드명, value -> 인접노드
-- adj : key -> 노드, value -> boolean

local function name2node (graph, name) -- name을 넣으면 그래프에서 node를 반환한다. 존재하지 않는 name일 경우, 노드를 새로 생성한다.
	local node = graph[name]
	if not node then
		-- node does not exist; create a new one
		node = {name = name, adj = {}}
		graph[name] = node
	end
	return node
end
function readgraph () -- 텍스트 파일의 각 라인으로부터 노드의 연결정보를 읽어들인다
	local graph = {}
	for line in io.lines() do
		-- split line in two names
		local namefrom, nameto = string.match(line, "(%S+)%s+(%S+)")
		-- find corresponding nodes
		local from = name2node(graph, namefrom)
		local to = name2node(graph, nameto)
		-- adds 'to' to the adjacent set of 'from'
		from.adj[to] = true
	end
	return graph
end
-- curr : 현재노드, to : 목적지노드, path : 경로테이블(key -> #, value -> node), visited : 방문했던 노드테이블(key -> 노드, value -> boolean)
function findpath (curr, to, path, visited) -- curr부터 to까지의 경로를 탐색하여, 경로가 담긴 노드테이블(path랑 같은 형태)을 반환
	path = path or {}
	visited = visited or {}
	if visited[curr] then -- node already visited?
		return nil -- no path here
	end
	visited[curr] = true -- mark node as visited
	path[#path + 1] = curr -- add it to path
	if curr == to then -- final node?
		return path
	end
	-- try all adjacent nodes
	for node in pairs(curr.adj) do
		local p = findpath(node, to, path, visited) -- 재귀호출
		if p then return p end
	end
	table.remove(path) -- remove node from path
end

-- end of chapter