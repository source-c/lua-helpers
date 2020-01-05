addPkgPath = function(path)
    package.path = path .. '/?.lua;' .. package.path
    package.cpath = path .. '/?.so;' .. package.cpath
end

function split(s, delimiter)
    local result = {};
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match);
    end
    return result;
end

local function parse_boolean(v)
    if v == '1' or v == 'true' or v == 'TRUE' then
        return true
    elseif v == '0' or v == 'false' or v == 'FALSE' then
        return false
    else
        return nil
    end
end

local function toboolean(value) return value == 1 end

function join(sep, l)
    local len = #l
    if len == 0 then return "" end
    local s = l[1]
    for i = 2, len do s = s .. sep .. l[i] end
    return s
end

function chomp(s)
    return string.gsub(s, "\n$", "")
end

function print_table(t, l)
    -- Equivalent of the Perl's Data::Dumper or Python's/Clojure's pprint
    if l == nil then l = 0 end
    local a = string.rep("\t", l)
    l = l + 1
    for i, v in pairs(t) do
        if type(v) == "table" then
            print(a .. i)
            print_table(v, l)
        else
            print(a .. i, v)
        end
    end
    return true
end

function orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end

function iterate(collection)

    local index = 0
    local count = #collection

    -- The closure function is returned

    return function()
        index = index + 1

        if index <= count
        then
            -- return the current element of the iterator
            return collection[index]
        end
    end
end

function mktmpfile(name)
    if not name then
        name = os.tmpname()
    end
    return name
end
