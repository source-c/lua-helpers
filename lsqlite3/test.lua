--[[
      Basic test to check the lsqlite3 library
  ]]--

local sqlite3 = require("lsqlite3")

local width = 80
local function line(pref, suff)
    pref = pref or ''
    suff = suff or ''
    if #pref > 0 then pref = (pref..' >') end
    if #suff > 0 then suff = ('< '..suff) end
    local len = width - 2 - string.len(pref) - string.len(suff)
    print(pref .. string.rep('-', len) .. suff)
end

local db, vm
local assert_, assert = assert, function (test)
    if (not test) then
        error(db:errmsg(), 2)
    end
end

line(sqlite3.version())

os.remove('test.db')
db = sqlite3.open('test.db')

line(nil, 'db:exec')
db:exec('CREATE TABLE TESTT(a, b)')

line(nil, 'prepare')
vm = db:prepare('INSERT INTO TESTT VALUES(?, :bork)')
assert(vm, db:errmsg())
assert(vm:bind_parameter_count() == 2)
assert(vm:bind_values(2, 4) == sqlite3.OK)
assert(vm:step() == sqlite3.DONE)
assert(vm:reset() == sqlite3.OK)
assert(vm:bind_names{ 'pepe', bork = 'nino' } == sqlite3.OK)
assert(vm:step() == sqlite3.DONE)
assert(vm:reset() == sqlite3.OK)
assert(vm:bind_names{ bork = 'susi' } == sqlite3.OK)
assert(vm:step() == sqlite3.DONE)
assert(vm:reset() == sqlite3.OK)
assert(vm:bind_names{ 1 } == sqlite3.OK)
assert(vm:step() == sqlite3.DONE)
assert(vm:finalize() == sqlite3.OK)

line("SELECT * FROM TESTT", 'db:exec')

assert(db:exec('SELECT * FROM TESTT', function (ud, ncols, values, names)
    --table.setn(values, 2)
    print(table.unpack(values))
    return sqlite3.OK
end) == sqlite3.OK)

line("SELECT * FROM TESTT", 'db:prepare')

vm = db:prepare('SELECT * FROM TESTT')
assert(vm, db:errmsg())
print(vm:get_unames())
while (vm:step() == sqlite3.ROW) do
    print(vm:get_uvalues())
end
assert(vm:finalize() == sqlite3.OK)



line('UDF', 'scalar')

local function do_query(sql)
    local r
    local vm = db:prepare(sql)
    assert(vm, db:errmsg())
    print('====================================')
    print(vm:get_unames())
    print('------------------------------------')
    r = vm:step()
    while (r == sqlite3.ROW) do
        print(vm:get_uvalues())
        r = vm:step()
    end
    assert(r == sqlite3.DONE)
    assert(vm:finalize() == sqlite3.OK)
    print('====================================')
end

local function udf1_scalar(ctx, v)
    local ud = ctx:user_data()
    ud.r = (ud.r or '')
    if #ud.r > 0 then ud.r = (ud.r..'.') end
    ud.r = (ud.r or '') .. tostring(v)
    ctx:result_text(ud.r)
end

db:create_function('udf1', 1, udf1_scalar, { })
do_query('SELECT udf1(a) FROM TESTT')


line('UDF', 'aggregate')

local function udf2_aggregate(ctx, ...)
    local ud = ctx:get_aggregate_data()
    if (not ud) then
        ud = {}
        ctx:set_aggregate_data(ud)
    end
    ud.r = (ud.r or 0) + 2
end

local function udf2_aggregate_finalize(ctx, v)
    local ud = ctx:get_aggregate_data()
    ctx:result_number(ud and ud.r or 0)
end

db:create_aggregate('udf2', 1, udf2_aggregate, udf2_aggregate_finalize, { })
do_query('SELECT udf2(a) FROM TESTT')

if (true) then
    line(nil, '100 insert exec')
    db:exec('DELETE FROM TESTT')
    local t = os.time()
    for i = 1, 100 do
        db:exec('INSERT INTO TESTT VALUES('..i..', '..(i * 2 * -1^i)..')')
    end
    print('elapsed: '..(os.time() - t))
    do_query('SELECT COUNT(*) FROM TESTT')

    line(nil, '100000 insert exec T')
    db:exec('DELETE FROM TESTT')
    local t = os.time()
    db:exec('BEGIN')
    for i = 1, 100000 do
        db:exec('INSERT INTO TESTT VALUES('..i..', '..(i * 2 * -1^i)..')')
    end
    db:exec('COMMIT')
    print('elapsed: '..(os.time() - t))
    do_query('SELECT COUNT(*) FROM TESTT')

    line(nil, '100000 insert prepare/bind T')
    db:exec('DELETE FROM TESTT')
    local t = os.time()
    local vm = db:prepare('INSERT INTO TESTT VALUES(?, ?)')
    db:exec('BEGIN')
    for i = 1, 100000 do
        vm:bind_values(i, i * 2 * -1^i)
        vm:step()
        vm:reset()
    end
    vm:finalize()
    db:exec('COMMIT')
    print('elapsed: '..(os.time() - t))
    do_query('SELECT COUNT(*) FROM TESTT')

end

line(nil, "db:close")

assert(db:close() == sqlite3.OK)

line(sqlite3.version(), "version")

os.remove('test.db')

