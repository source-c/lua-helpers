addPkgPath = function(path)
    package.path = path .. '/?.lua;' .. package.path
    package.cpath = path .. '/?.so;' .. package.cpath
end

function read_mounts()
    -- read /proc/mounts and retrun array of strings
    local file = io.open('/proc/mounts', 'r')
    local result = {}
    local index = 0
    local line

    repeat
        line = file:read()
        if line then
            table.insert(result,
                (table.concat(split(line, " "), ",", 1, 3)))
        end
    until (not line)
    file:close()

    -- contains "from,to,type"
    return result
end

function find_mounts(fstype, from, _)
    -- returns FIRST! found item in list if FROM is NULL
    -- returns LAST! found item in list if FROM is matched
    -- returns NULL otherwise
    local list = read_mounts()

    local r = {}

    for i in iterate(list) do
        local t = split(i, ",")
        if t[3] == fstype then
        	if from and t[1] ~= from then
        		break
        	end
		table.insert(r,t[2])
        end
    end

    return r
end

