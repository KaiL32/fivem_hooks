local table_insert = table.insert
local table_remove = table.remove
local hooks = {}
local map = {}
local map_reverse = {}

local function Remove(event, name)
    local map_event = map[event]
    if not map_event then return end
    local id = map_event[name]
    if not id then return end
    local event_hooks = hooks[event]
    local map_reverse_event = map_reverse[event]

    for n = id + 1, #event_hooks do
        local rmap = map_reverse_event[n]
        map[rmap[1]][rmap[2]] = n - 1
    end

    table_remove(event_hooks, id)
    local rmap = map_reverse_event[id]
    map[rmap[1]][rmap[2]] = nil
    table_remove(map_reverse_event, id)
end

local function Add(event, name, callback, order)
    Remove(event, name)
    local id
    local event_hooks = hooks[event]

    if event_hooks then
        local count = #event_hooks

        if order then
            if order > count then
                order = count
            end

            if order < 1 then
                order = 1
            end

            id = table_insert(event_hooks, order, callback)
        else
            id = count + 1
            event_hooks[id] = callback
        end
    else
        id = 1

        hooks[event] = {
            [id] = callback
        }
    end

    local map_event = map[event]

    if map_event then
        map_event[name] = id
    else
        map[event] = {
            [name] = id
        }
    end

    local map_reverse_event = map_reverse[event]

    if map_reverse_event then
        map_reverse_event[id] = {event, name}
    else
        map_reverse[event] = {
            [id] = {event, name}
        }
    end
end

local function Call(event, gamemode, a1, a2, a3, a4, a5, a6)
    local event_hooks = hooks[event]

    if event_hooks then
        for id = 1, #event_hooks do
            local callback = event_hooks[id]

            if callback then
                local r1, r2, r3, r4, r5, r6 = callback(a1, a2, a3, a4, a5, a6)
                if r1 ~= nil then return r1, r2, r3, r4, r5, r6 end
            end
        end
    end

    if gamemode then
        local gamemode_event_hook = gamemode[event]
        if gamemode_event_hook then return gamemode_event_hook(gamemode, a1, a2, a3, a4, a5, a6) end
    end
end

local function Run(name, ...)
    return Call(name, nil, ...)
end

local function Set(event, name, any)
    if any == nil then
        return Remove(event, name)
    else
        return Add(event, name, any)
    end
end

hook = {
    Table = hooks,
    Map = map,
    MapReverse = map_reverse,
    Add = Add,
    Remove = Remove,
    Set = Set,
    Call = Call,
    Run = Run,
}