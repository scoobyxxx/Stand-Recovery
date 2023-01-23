local version = "1.2.1"
local root = menu.my_root()

local update_button = root:action("Update Script", {}, "Update the script to the latest version", function()
    async_http.init("raw.githubusercontent.com", "4d72526f626f74/Stand-Recovery/main/Recovery.lua", function(body, headers, status_code)
        if status_code == 200 then
            local file = io.open(filesystem.scripts_dir() .. SCRIPT_RELPATH, "wb")
            file:write(body)
            file:close()

            util.restart_script()
        end
    end)
    async_http.dispatch()
end)

update_button.visible = false

async_http.init("raw.githubusercontent.com", "4d72526f626f74/Stand-Recovery/main/Version", function(body, headers, status_code)
    if status_code == 200 then
        body = body:gsub("%s+", "")
        if body ~= version then
            update_button.visible = true
            util.toast("New version available")
        end
    end
end)
async_http.dispatch()

util.keep_running()
util.require_natives(1672190175)

util.toast("WARNING: All features are considered risky and may result in a ban. Use at your own risk.")

-- dbase = facility
-- businesshub = bunker

local items = {
    settings = {
        root = nil
    },
    tools = {
        root = nil
    },
    presets = {
        root = nil,
        nightclub = {
            root = nil,
            choice = nil,
            afk = nil,
            first_nightclub = nil,
            second_nightclub = nil,
        },
        arcade = {
            root = nil,
            choice = nil,
            afk = nil,
            first_arcade = nil,
            second_arcade = nil,
        },
        autoshop = {
            root = nil,
            choice = nil
        },
        agency = {
            root = nil,
            choice = nil,
            afk = nil,
            first_agency = nil,
            second_agency = nil,
        },
        hangar = {
            root = nil,
            choice = nil,
            afk = nil,
            first_hangar = nil,
            second_hangar = nil,
        },
        facility = {
            root = nil,
            choice = nil,
            afk = nil,
            first_facility = nil,
            second_facility = nil,
        }
    },
    custom = {
        root = nil,
        nightclub = {
            root = nil
        },
        arcade = {
            root = nil
        },
        autoshop = {
            root = nil
        },
        agency = {
            root = nil
        },
        hangar = {
            root = nil
        },
        facility = {
            root = nil
        },
    },
    dax_mission = {
        root = nil,
    },
    casino_figures = {
        root = nil
    },
    heists = {
        root = nil,
        casino = {
            root = nil
        },
        cayo_perico = {
            root = nil
        }
    }
}

local settings = {
    ownership_check = true,
    verbose = false
}

local stats = {
    nightclub = util.joaat("mp" .. util.get_char_slot() .. "_prop_nightclub_value"),
    arcade = util.joaat("mp" .. util.get_char_slot() .. "_prop_arcade_value"),
    autoshop = util.joaat("mp" .. util.get_char_slot() .. "_prop_auto_shop_value"),
    agency = util.joaat("mp" .. util.get_char_slot() .. "_prop_fixer_hq_value"),
    hangar = util.joaat("mp" .. util.get_char_slot() .. "_prop_hangar_value"),
    office = util.joaat("mp" .. util.get_char_slot() .. "_prop_office_value"),
    bunker = util.joaat("mp" .. util.get_char_slot() .. "_prop_businesshub_value"), -- might not be correct
    facility = util.joaat("mp" .. util.get_char_slot() .. "_prop_defuncbase_value"),
    nightclub_owned = util.joaat("mp" .. util.get_char_slot() .. "_nightclub_owned"),
    arcade_owned = util.joaat("mp" .. util.get_char_slot() .. "_arcade_owned"),
    autoshop_owned = util.joaat("mp" .. util.get_char_slot() .. "_auto_shop_owned"),
    agency_owned = util.joaat("mp" .. util.get_char_slot() .. "_fixer_hq_owned"),
    hangar_owned = util.joaat("mp" .. util.get_char_slot() .. "_hangar_owned"),
    office_owned = util.joaat("mp" .. util.get_char_slot() .. "_office_owned"),
    bunker_owned = util.joaat("mp" .. util.get_char_slot() .. "_businesshub_owned"), -- might not be correct
    facility_owned = util.joaat("mp" .. util.get_char_slot() .. "_dbase_owned")
}

local afk_meta = setmetatable(
    {
        nc = {
            locations = {}, 
            offset = 0.05, 
            ragdoll_timer = 1
        },
        arcade = {
            locations = {},
            offset = 0.05,
            ragdoll_timer = 1
        },
        autoshop = {
            locations = {},
            offset = 0.05,
            ragdoll_timer = 1
        },
        hangar = {
            locations = {},
            offset = 0.05,
            ragdoll_timer = 1
        },
        facility = {
            locations = {},
            offset = 0.05,
            ragdoll_timer = 1
        },
    }, 
    {}
)

local function SIMULATE_CONTROL_KEY(key, times, control=0, delay=300)
    for i = 1, times do
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(control, key, 1)
        util.yield(delay)
    end

    util.yield(100)
end

local function MOVE_CURSOR(x, y, delay=300, autoclick=false)
    PAD.SET_CURSOR_POSITION(x, y)
    util.yield(delay)

    if autoclick then
        SIMULATE_CONTROL_KEY(201, 1)
    end
end

function afk_meta:add_nightclub(x, y, name, id, purchase)
    local location = {x=x, y=y, name=name, id=id, purchase=purchase}
    table.insert(self.nc.locations, location)
end

function afk_meta:purchase_nightclub(name, notify=false)
    if nofify then
        util.toast("Purchasing nightclub: " .. name)
    end

    for key, value in pairs(self.nc.locations) do
        if value.name == name then
            value.purchase()
            break
        end
    end

    if notify then
        util.toast("Nightclub purchased: " .. name)
    end
end

-- add locations for nightclubs
afk_meta:add_nightclub(0.69, 0.58, "La Mesa", 1, function()
    -- purchase the nightclub
    local xptr, yptr = memory.alloc(4), memory.alloc(4)
    GRAPHICS.GET_ACTUAL_SCREEN_RESOLUTION(xptr, yptr)
    local x, y = tonumber(memory.read_int(xptr)), tonumber(memory.read_int(yptr))

    local purchase = function(offsets=nil)
        offsets = offsets or {selection=0, first_buy=0, second_buy=0, third_buy=0}
        MOVE_CURSOR(0.69, 0.58, 300, true) -- select the nightclub
        MOVE_CURSOR(0.30, 0.73, 300, true) -- press the first buy button
        MOVE_CURSOR(0.30, 0.93, 300, true) -- press the second buy button
        MOVE_CURSOR(0.78, 0.91, 300, true) -- press the third buy button
        SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
        SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
        util.yield(1500) -- wait for transaction to complete
        PED.SET_PED_TO_RAGDOLL(players.user_ped(), afk_meta.nc.ragdoll_timer, afk_meta.nc.ragdoll_timer, 2, 0, 0, 0) -- ragdoll to close browser
    end

    purchase()
end)

afk_meta:add_nightclub(0.644, 0.51, "Mission Row", 2, function()
    -- purchase the nightclub
    local xptr, yptr = memory.alloc(4), memory.alloc(4)
    GRAPHICS.GET_ACTUAL_SCREEN_RESOLUTION(xptr, yptr)
    local x, y = tonumber(memory.read_int(xptr)), tonumber(memory.read_int(yptr))

    local purchase = function(offsets=nil)
        offsets = offsets or {selection=0, first_buy=0, second_buy=0, third_buy=0}
        MOVE_CURSOR(0.64, 0.51, 300, true) -- select the nightclub
        MOVE_CURSOR(0.30, 0.73, 300, true) -- press the first buy button
        MOVE_CURSOR(0.30, 0.93, 300, true) -- press the second buy button
        MOVE_CURSOR(0.78, 0.91, 300, true) -- press the third buy button
        SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
        SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
        util.yield(1500) -- wait for transaction to complete
        PED.SET_PED_TO_RAGDOLL(players.user_ped(), afk_meta.nc.ragdoll_timer, afk_meta.nc.ragdoll_timer, 2, 0, 0, 0) -- ragdoll to close browser
    end

    purchase()
end)

afk_meta:add_nightclub(0.479, 0.54, "Vespucci Canals", 10, function()
    -- purchase the nightclub
    local xptr, yptr = memory.alloc(4), memory.alloc(4)
    GRAPHICS.GET_ACTUAL_SCREEN_RESOLUTION(xptr, yptr)
    local x, y = tonumber(memory.read_int(xptr)), tonumber(memory.read_int(yptr))

    local purchase = function(offsets=nil)
        offsets = offsets or {selection=0, first_buy=0, second_buy=0, third_buy=0}
        MOVE_CURSOR(0.479, 0.54, 300, true) -- select the nightclub
        MOVE_CURSOR(0.30, 0.73, 300, true) -- press the first buy button
        MOVE_CURSOR(0.30, 0.93, 300, true) -- press the second buy button
        MOVE_CURSOR(0.78, 0.91, 300, true) -- press the third buy button
        SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
        SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
        util.yield(1500) -- wait for transaction to complete
        PED.SET_PED_TO_RAGDOLL(players.user_ped(), afk_meta.nc.ragdoll_timer, afk_meta.nc.ragdoll_timer, 2, 0, 0, 0) -- ragdoll to close browser
    end

    purchase()
end)

function afk_meta:purchase_arcade(name, notify=false)
    if nofify then
        util.toast("Purchasing arcade: " .. name)
    end

    for key, value in pairs(self.arcade.locations) do
        if value.name == name then
            value.purchase()
            break
        end
    end

    if notify then
        util.toast("Arcade purchased: " .. name)
    end
end

function afk_meta:add_arcade(x, y, name, id, purchase)
    local location = {x=x, y=y, name=name, id=id, purchase=purchase}
    table.insert(self.arcade.locations, location)
end

afk_meta:add_arcade(0.0, 0.0, "La Mesa", 6, function()
    local purchase = function(offsets=nil)
        offsets = offsets or {selection=0, first_buy=0, second_buy=0, third_buy=0}
        MOVE_CURSOR(0.687, 0.48, 300, true) -- select the arcade
        MOVE_CURSOR(0.30, 0.78, 300, true) -- press the first buy button
        MOVE_CURSOR(0.30, 0.92, 300, true) -- press the second buy button
        MOVE_CURSOR(0.78, 0.91, 300, true) -- press the third buy button
        SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
        SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
        util.yield(1500) -- wait for transaction to complete
        PED.SET_PED_TO_RAGDOLL(players.user_ped(), afk_meta.arcade.ragdoll_timer, afk_meta.arcade.ragdoll_timer, 2, 0, 0, 0) -- ragdoll to close browser
    end

    purchase()
end)

afk_meta:add_arcade(0.0, 0.0, "Davis", 3, function()
    local purchase = function(offsets=nil)
        offsets = offsets or {selection=0, first_buy=0, second_buy=0, third_buy=0}
        MOVE_CURSOR(0.593, 0.67, 300, true) -- select the arcade
        MOVE_CURSOR(0.30, 0.81, 300, true) -- press the first buy button
        MOVE_CURSOR(0.30, 0.92, 300, true) -- press the second buy button
        MOVE_CURSOR(0.78, 0.91, 300, true) -- press the third buy button
        SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
        SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
        util.yield(1500) -- wait for transaction to complete
        PED.SET_PED_TO_RAGDOLL(players.user_ped(), afk_meta.arcade.ragdoll_timer, afk_meta.arcade.ragdoll_timer, 2, 0, 0, 0) -- ragdoll to close browser
    end

    purchase()
end)

afk_meta:add_arcade(0.0, 0.0, "Eight Bit", 4, function()
    local purchase = function(offsets=nil)
        offsets = offsets or {selection=0, first_buy=0, second_buy=0, third_buy=0}
        MOVE_CURSOR(0.54, 0.27, 300, true) -- select the arcade
        MOVE_CURSOR(0.30, 0.81, 300, true) -- press the first buy button
        MOVE_CURSOR(0.30, 0.92, 300, true) -- press the second buy button
        MOVE_CURSOR(0.78, 0.91, 300, true) -- press the third buy button
        SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
        SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
        util.yield(1500) -- wait for transaction to complete
        PED.SET_PED_TO_RAGDOLL(players.user_ped(), afk_meta.arcade.ragdoll_timer, afk_meta.arcade.ragdoll_timer, 2, 0, 0, 0) -- ragdoll to close browser
    end

    purchase()
end)

function afk_meta:purchase_autoshop(name, notify=false)
    if nofify then
        util.toast("Purchasing autoshop: " .. name)
    end

    for key, value in pairs(self.autoshop.locations) do
        if value.name == name then
            value.purchase()
            break
        end
    end

    if notify then
        util.toast("Autoshop purchased: " .. name)
    end
end

function afk_meta:add_autoshop(x, y, name, id, purchase)
    local location = {x=x, y=y, name=name, id=id, purchase=purchase}
    table.insert(self.autoshop.locations, location)
end

afk_meta:add_autoshop(0.0, 0.0, "La Mesa", 1, function()
    local purchase = function(offsets=nil)
        offsets = offsets or {selection=0, first_buy=0, second_buy=0, third_buy=0}
        MOVE_CURSOR(0.687, 0.455, 300, true) -- select the autoshop
        MOVE_CURSOR(0.30, 0.75, 300, true) -- press the first buy button
        MOVE_CURSOR(0.30, 0.92, 300, true) -- press the second buy button
        MOVE_CURSOR(0.78, 0.94, 300, true) -- press the third buy button
        SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
        SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
        util.yield(1500) -- wait for transaction to complete
        PED.SET_PED_TO_RAGDOLL(players.user_ped(), afk_meta.autoshop.ragdoll_timer, afk_meta.autoshop.ragdoll_timer, 2, 0, 0, 0) -- ragdoll to close browser
    end

    purchase()
end)

afk_meta:add_autoshop(0.0, 0.0, "Mission Row", 1, function()
    local purchase = function(offsets=nil)
        offsets = offsets or {selection=0, first_buy=0, second_buy=0, third_buy=0}
        MOVE_CURSOR(0.66, 0.49, 300, true) -- select the autoshop
        MOVE_CURSOR(0.30, 0.75, 300, true) -- press the first buy button
        MOVE_CURSOR(0.30, 0.92, 300, true) -- press the second buy button
        MOVE_CURSOR(0.78, 0.94, 300, true) -- press the third buy button
        SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
        SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
        util.yield(1500) -- wait for transaction to complete
        PED.SET_PED_TO_RAGDOLL(players.user_ped(), afk_meta.autoshop.ragdoll_timer, afk_meta.autoshop.ragdoll_timer, 2, 0, 0, 0) -- ragdoll to close browser
    end

    purchase()
end)

afk_meta:add_autoshop(0.0, 0.0, "Burton", 1, function()
    local purchase = function(offsets=nil)
        offsets = offsets or {selection=0, first_buy=0, second_buy=0, third_buy=0}
        MOVE_CURSOR(0.585, 0.32, 300, true) -- select the autoshop
        MOVE_CURSOR(0.30, 0.75, 300, true) -- press the first buy button
        MOVE_CURSOR(0.30, 0.92, 300, true) -- press the second buy button
        MOVE_CURSOR(0.78, 0.94, 300, true) -- press the third buy button
        SIMULATE_CONTROL_KEY(176, 1) -- press enter to purchase
        SIMULATE_CONTROL_KEY(201, 1, 2) -- confirm purchase
        util.yield(1500) -- wait for transaction to complete
        PED.SET_PED_TO_RAGDOLL(players.user_ped(), afk_meta.autoshop.ragdoll_timer, afk_meta.autoshop.ragdoll_timer, 2, 0, 0, 0) -- ragdoll to close browser
    end

    purchase()
end)

function afk_meta:open_internet(is_afk_loop, filter)
    is_afk_loop = is_afk_loop or false

    while menu.is_open() do
        if is_afk_loop then
            util.toast("[Recovery] Close Stand menu to start AFK loop")
        end
        util.yield()
    end

    local xptr, yptr = memory.alloc(4), memory.alloc(4)
    GRAPHICS.GET_ACTUAL_SCREEN_RESOLUTION(xptr, yptr)
    local x, y = tonumber(memory.read_int(xptr)), tonumber(memory.read_int(yptr))

    SIMULATE_CONTROL_KEY(27, 1) -- open phone
    SIMULATE_CONTROL_KEY(173, 2) -- scroll down
    SIMULATE_CONTROL_KEY(176, 1) -- select internet
    MOVE_CURSOR(0.25, 0.70, 300, true) -- mazebank hyperlink
    MOVE_CURSOR(0.5, 0.83, 300, true) -- enter mazebank button
    
    switch x do
        case 1920:
            if filter == "nightclub" then MOVE_CURSOR(0.78, 0.28) end -- nightclub filter
            if filter == "arcade" then MOVE_CURSOR(0.86, 0.28) end -- arcade filter
            if filter == "autoshop" then MOVE_CURSOR(0.94, 0.28) end -- autoshop filter
            if filter == "facility" then MOVE_CURSOR(0.70, 0.28) end -- facility filter
            break
        case 1680:
            if filter == "nightclub" then MOVE_CURSOR(0.78 - afk_meta.nc.offset, 0.28) end -- nightclub filter
            if filter == "arcade" then MOVE_CURSOR(0.86 - afk_meta.arcade.offset, 0.28) end -- arcade filter
            if filter == "autoshop" then MOVE_CURSOR(0.94 - afk_meta.autoshop.offset, 0.28) end -- autoshop filter
            if filter == "facility" then MOVE_CURSOR(0.70 - afk_meta.facility.offset, 0.28) end -- facility filter
            break
        case 1600:
            if y == 1024 then
                if filter == "nightclub" then MOVE_CURSOR(0.78 - (afk_meta.nc.offset + 0.01), 0.28) end -- nightclub filter
                if filter == "arcade" then MOVE_CURSOR(0.86 - (afk_meta.arcade.offset + 0.01), 0.28) end -- arcade filter
                if filter == "autoshop" then MOVE_CURSOR(0.94 - (afk_meta.autoshop.offset + 0.01), 0.28) end -- autoshop filter
                if filter == "facility" then MOVE_CURSOR(0.70 - (afk_meta.facility.offset + 0.01), 0.28) end -- facility filter
            end

            if y == 900 then
                if filter == "nightclub" then MOVE_CURSOR(0.78, 0.28) end -- nightclub filter
                if filter == "arcade" then MOVE_CURSOR(0.86, 0.28) end -- arcade filter
                if filter == "autoshop" then MOVE_CURSOR(0.94, 0.28) end -- autoshop filter
                if filter == "facility" then MOVE_CURSOR(0.70, 0.28) end -- facility filter
            end
            break
        case 1440:
            if filter == "nightclub" then MOVE_CURSOR(0.78 - afk_meta.nc.offset, 0.28) end -- nightclub filter
            if filter == "arcade" then MOVE_CURSOR(0.86 - afk_meta.arcade.offset, 0.28) end -- arcade filter
            if filter == "autoshop" then MOVE_CURSOR(0.94 - afk_meta.autoshop.offset, 0.28) end -- autoshop filter
            if filter == "facility" then MOVE_CURSOR(0.70 - afk_meta.facility.offset, 0.28) end -- facility filter
            break
        case 1366:
            if filter == "nightclub" then MOVE_CURSOR(0.78, 0.28) end -- nightclub filter
            if filter == "arcade" then MOVE_CURSOR(0.86, 0.28) end -- arcade filter
            if filter == "autoshop" then MOVE_CURSOR(0.94, 0.28) end -- autoshop filter
            if filter == "facility" then MOVE_CURSOR(0.70, 0.28) end -- facility filter
            break
        case 1360:
            if filter == "nightclub" then MOVE_CURSOR(0.78, 0.28) end -- nightclub filter
            if filter == "arcade" then MOVE_CURSOR(0.86, 0.28) end -- arcade filter
            if filter == "autoshop" then MOVE_CURSOR(0.94, 0.28) end -- autoshop filter
            if filter == "facility" then MOVE_CURSOR(0.70, 0.28) end -- facility filter
            break
        case 1280: 
            if y == 1024 then
                if filter == "nightclub" then MOVE_CURSOR(0.78 - (afk_meta.nc.offset * 3), 0.28) end -- nightclub filter
                if filter == "arcade" then MOVE_CURSOR(0.86 - (afk_meta.arcade.offset * 3), 0.28) end -- arcade filter
                if filter == "autoshop" then MOVE_CURSOR(0.94 - (afk_meta.autoshop.offset * 3), 0.28) end -- autoshop filter
                if filter == "facility" then MOVE_CURSOR(0.70 - (afk_meta.facility.offset * 3), 0.28) end -- facility filter
            end

            if y == 960 then
                if filter == "nightclub" then MOVE_CURSOR(0.78 - (afk_meta.nc.offset * 2.5), 0.28) end -- nightclub filter
                if filter == "arcade" then MOVE_CURSOR(0.86 - (afk_meta.arcade.offset * 2.5), 0.28) end -- arcade filter
                if filter == "autoshop" then MOVE_CURSOR(0.94 - (afk_meta.autoshop.offset * 2.5), 0.28) end -- autoshop filter
                if filter == "facility" then MOVE_CURSOR(0.70 - (afk_meta.facility.offset * 2.5), 0.28) end -- facility filter
            end

            if y == 800 then
                if filter == "nightclub" then MOVE_CURSOR(0.78 - afk_meta.nc.offset, 0.28) end -- nightclub filter
                if filter == "arcade" then MOVE_CURSOR(0.86 - afk_meta.arcade.offset, 0.28) end -- arcade filter
                if filter == "autoshop" then MOVE_CURSOR(0.94 - afk_meta.autoshop.offset, 0.28) end -- autoshop filter
                if filter == "facility" then MOVE_CURSOR(0.70 - afk_meta.facility.offset, 0.28) end -- facility filter
            end

            if y == 768 then
                if filter == "nightclub" then MOVE_CURSOR(0.78 - (afk_meta.nc.offset / 2), 0.28) end -- nightclub filter
                if filter == "arcade" then MOVE_CURSOR(0.86 - (afk_meta.arcade.offset / 2), 0.28) end -- arcade filter
                if filter == "autoshop" then MOVE_CURSOR(0.94 - (afk_meta.autoshop.offset / 2), 0.28) end -- autoshop filter    
                if filter == "facility" then MOVE_CURSOR(0.70 - (afk_meta.facility.offset / 2), 0.28) end -- facility filter
            end

            if y == 720 then
                if filter == "nightclub" then MOVE_CURSOR(0.78, 0.28) end -- nightclub filter
                if filter == "arcade" then MOVE_CURSOR(0.86, 0.28) end -- arcade filter
                if filter == "autoshop" then MOVE_CURSOR(0.94, 0.28) end -- autoshop filter 
                if filter == "facility" then MOVE_CURSOR(0.70, 0.28) end -- facility filter
            end
            break
        case 1176:
            if filter == "nightclub" then MOVE_CURSOR(0.78, 0.28) end -- nightclub filter
            if filter == "arcade" then MOVE_CURSOR(0.86, 0.28) end -- arcade filter
            if filter == "autoshop" then MOVE_CURSOR(0.94, 0.28) end -- autoshop filter
            if filter == "facility" then MOVE_CURSOR(0.70, 0.28) end -- facility filter
            break
        case 1152:
            if filter == "nightclub" then MOVE_CURSOR(0.78 - (afk_meta.nc.offset * 2.5), 0.28) end -- nightclub filter
            if filter == "arcade" then MOVE_CURSOR(0.86 - (afk_meta.arcade.offset * 2.5), 0.28) end -- arcade filter
            if filter == "autoshop" then MOVE_CURSOR(0.94 - (afk_meta.autoshop.offset * 2.5), 0.28) end -- autoshop filter
            if filter == "facility" then MOVE_CURSOR(0.70 - (afk_meta.facility.offset * 2.5), 0.28) end -- facility filter
            break
        case 1024:
            if filter == "nightclub" then MOVE_CURSOR(0.78 - (afk_meta.nc.offset * 2.5), 0.28) end -- nightclub filter
            if filter == "arcade" then MOVE_CURSOR(0.86 - (afk_meta.arcade.offset * 2.5), 0.28) end -- arcade filter
            if filter == "autoshop" then MOVE_CURSOR(0.94 - (afk_meta.autoshop.offset * 2.5), 0.28) end -- autoshop filter
            if filter == "facility" then MOVE_CURSOR(0.70 - (afk_meta.facility.offset * 2.5), 0.28) end -- facility filter
            break
        case 800:
            if filter == "nightclub" then MOVE_CURSOR(0.78 - (afk_meta.nc.offset * 2.5), 0.28) end -- nightclub filter
            if filter == "arcade" then MOVE_CURSOR(0.86 - (afk_meta.arcade.offset * 2.5), 0.28) end -- arcade filter
            if filter == "autoshop" then MOVE_CURSOR(0.94 - (afk_meta.autoshop.offset * 2.5), 0.28) end -- autoshop filter
            if filter == "facility" then MOVE_CURSOR(0.70 - (afk_meta.facility.offset * 2.5), 0.28) end -- facility filter
            break
        default: 
            util.toast("Unsupported resolution: " .. x .. "x" .. y)
    end

    SIMULATE_CONTROL_KEY(201, 1) -- select filter
end

local property_ids = {
    nightclubs = {
        ["La Mesa"] = 1,
        ["Mission Row"] = 2,
        ["Strawberry"] = 3,
        ["West Vinewood"] = 4,
        ["Cypress Flats"] = 5,
        ["LSIA"] = 6,
        ["Elysian Island"] = 7,
        ["Downtown Vinewood"] = 8,
        ["Del Perro"] = 9,
        ["Vespucci Canals"] = 10
    },
    arcades = {
        ["Davis"] = 3,
        ["Eight Bit"] = 4,
        ["Insert Coin - Rockford Hills"] = 5,
        ["La Mesa"] = 6
    },
    autoshops = {
        ["La Mesa"] = 1,
        ["Strawberry"] = 2,
        ["Burton"] = 3,
        ["Rancho"] = 4,
        ["Mission Row"] = 5
    },
    agencies = {
        ["Hawick"] = 1,
        ["Rockford Hills"] = 2,
        ["Little Seoul"] = 3,
        ["Vespucci Canals"] = 4
    },
    hangars = {
        ["LSIA 1"] = 1,
        ["LSIA A17"] = 2,
        ["Fort Zancudo Hangar A2"] = 3,
        ["Fort Zancudo Hangar 3497"] = 4,
        ["Fort Zancudo Hangar 3499"] = 5
    },
    bunkers = {
        
    },
    facilities = {
        ["Grand Senora Desert"] = 1,
        ["Route 68"] = 2,
        ["Sandy Shores"] = 3,
        ["Mount Gordo"] = 4,
        ["Paleto Bay"] = 5,
        ["Fort Zancudo"] = 6,
        ["Ron Alternates Wind Farm"] = 8,
        ["Land Act Reservoir"] = 9
    }
}

local options = {
    "50,000,000", "100,000,000", "150,000,000", "200,000,000",
    "250,000,000", "300,000,000", "350,000,000", "400,000,000",
    "450,000,000", "500,000,000", "550,000,000", "600,000,000",
    "650,000,000", "700,000,000", "750,000,000", "800,000,000", 
    "850,000,000", "900,000,000", "950,000,000","1,000,000,000"
}

local function convert_value(value)
    switch value do
        case "50,000,000": return 50000000 break
        case "100,000,000": return 100000000 break
        case "150,000,000": return 150000000 break
        case "200,000,000": return 200000000 break
        case "250,000,000": return 250000000 break
        case "300,000,000": return 300000000 break
        case "350,000,000": return 350000000 break
        case "400,000,000": return 400000000 break
        case "450,000,000": return 450000000 break
        case "500,000,000": return 500000000 break
        case "550,000,000": return 550000000 break
        case "600,000,000": return 600000000 break
        case "650,000,000": return 650000000 break
        case "700,000,000": return 700000000 break
        case "750,000,000": return 750000000 break
        case "800,000,000": return 800000000 break
        case "850,000,000": return 850000000 break
        case "900,000,000": return 900000000 break
        case "950,000,000": return 950000000 break
        case "1,000,000,000": return 1000000000 break
        case "Maximum": return (2 << 30) - 1 break
        default: return (2 << 30) - 1 break
    end
end

local function is_owned(stat)
    local pOwned = memory.alloc_int()
    if STATS.STAT_GET_INT(stat, pOwned, -1) then
        local prop_id = memory.read_int(pOwned)
        if settings.verbose then util.toast("Stat Value: " .. prop_id) end
        return prop_id > 0
    else
        if settings.verbose then util.toast("Reading stat failed") end
    end

    return false
end

local function tunable(value)
    return memory.script_global(262145 + value)
end

local function get_owned_property(property)
    local ptr = memory.alloc(4)
    local table = nil
    local stat = nil

    switch property do
        case "Nightclub":
            table = property_ids.nightclubs
            stat = stats.nightclub_owned
            break
        case "Arcade":
            table = property_ids.arcades
            stat = stats.arcade_owned
            break
        case "Autoshop":
            table = property_ids.autoshops
            stat = stats.autoshop_owned
            break
        case "Agency":
            table = property_ids.agencies
            stat = stats.agency_owned
            break
        case "Hangar":
            table = property_ids.hangars
            stat = stats.hangar_owned
            break
        case "Bunker":
            table = property_ids.bunkers
            stat = stats.bunker_owned
            break
        case "Facility":
            table = property_ids.facilities
            stat = stats.facility_owned
            break
    end

    if table ~= nil and stat ~= nil then
        if STATS.STAT_GET_INT(stat, ptr, -1) then
            local prop_id = memory.read_int(ptr)
            if prop_id > 0 then
                for name, id in pairs(table) do
                    if id == prop_id then
                        return name
                    end
                end
            end
        end
    end

    return nil
end

local function get_property_names(property)
    switch property do
        case "Nightclub":
            local names = {}
            for name, id in pairs(property_ids.nightclubs) do
                table.insert(names, name)
            end
            return names
            break
        case "Arcade": return {} break
        case "Autoshop": return {} break
        case "Agency": return {} break
        case "Hangar": return {} break
        case "Facility": return {} break
        default: return {} break
    end
end

local function can_make_purchase(amount)
    local wallet = players.get_wallet(players.user())
    local bank = players.get_bank(players.user())

    if wallet ~= nil and bank ~= nil then
        return (wallet + bank) >= amount
    end

    return false
end

local show_usage = {
    agency = os.time(),
    hangar = os.time(),
    facility = os.time(),
}

local globals = {
    nightclub_prices = {
        ["La Mesa"] = tunable(24838),
        ["Mission Row"] = tunable(24843),
        ["Vespucci Canals"] = tunable(24845)
    },
    arcade_prices = {
        ["La Mesa"] = tunable(28441),
        ["Davis"] = tunable(28439),
        ["Eight Bit"] = tunable(28444)
    },
    autoshop_prices = {
        ["La Mesa"] = tunable(31246),
        ["Mission Row"] = tunable(31248),
        ["Burton"] = tunable(31249)
    }
}

local nc_owned = get_owned_property("Nightclub")
local nc_options = {
    first = {"La Mesa", "Mission Row", "Vespucci Canals"},
    second = {"Vespucci Canals", "Mission Row", "La Mesa"}
}

local arcade_owned = get_owned_property("Arcade")
local arcade_options = {
    first = {"La Mesa", "Davis", "Eight Bit"},
    second = {"Eight Bit", "Davis", "La Mesa"}
}

local autoshop_owned = get_owned_property("Autoshop")
local autoshop_options = {
    first = {"La Mesa", "Mission Row", "Burton"},
    second = {"Burton", "Mission Row", "La Mesa"}
}

local hangar_owned = get_owned_property("Hangar")
local hangar_options = {
    first = {"Fort Zancudo A2", "Fort Zancudo 3497", "Fort Zancudo 3499"},
    second = {"Fort Zancudo 3499", "Fort Zancudo 3497", "Fort Zancudo A2"}
}

local facility_owned = get_owned_property("Facility")
local facility_options = {
    first = {"Land Act Reservoir", "Ron Alternates Wind Farm", "Fort Zancudo"},
    second = {"Fort Zancudo", "Ron Alternates Wind Farm", "Land Act Reservoir"}
}

local agency_owned = get_owned_property("Agency")
local agency_options = {
    first = {"Hawick", "Rockford Hills", "Little Seoul"},
    second = {"Little Seoul", "Rockford Hills", "Hawick"}
}

local usage_timer = 20

items.settings.root = root:list("Settings", {}, "Settings for the script")
items.tools.root = root:list("Tools", {}, "Tools for unlocking arcades and autoshops on mazebank foreclosure")
root:divider("Recovery", "Recovery")
items.presets.root = root:list("Presets", {}, "Preset values for convenience", function() util.show_corner_help("If you haven\'t unlocked arcades and autoshops on mazebank foreclosure yet then AFK money loop will not work properly") end)
items.custom.root = root:list("Custom", {}, "Customisable values for fine-tuning to your own liking")

items.settings.root:toggle("Disable Ownership Check", {}, "Disable ownership check for properties (useful if you own a property but are falsely told you don\'t)", function(state) settings.ownership_check = state end)
items.settings.root:toggle("Verbose", {}, "Show verbose output (not fully implemented yet)", function(state) settings.verbose = state end)
items.presets.root:divider("MazeBank Properties", "MazeBank Properties")
items.presets.nightclub.root = items.presets.root:list("Nightclub", {}, "Preset values for nightclub")
items.presets.arcade.root = items.presets.root:list("Arcade", {}, "Preset values for arcade")
items.presets.autoshop.root = items.presets.root:list("Autoshop", {}, "Preset values for autoshop")
items.presets.hangar.root = items.presets.root:list("Hangar", {}, "Preset values for hangar")
items.presets.facility.root = items.presets.root:list("Facility", {}, "Preset values for facility")
items.presets.root:divider("Dynasty8Executive Properties", "Dynasty8Executive Properties")
items.presets.agency.root = items.presets.root:list("Agency", {}, "Preset values for agency")

items.presets.nightclub.root:divider("Settings", "Settings")
items.presets.nightclub.choice = items.presets.nightclub.root:list_select("Money", {}, "The nightclub trade-in price", options, 1, function(index) end)

items.tools.root:action("Unlock Arcades On MazeBank", {}, "Unlocks arcades", function()
    local current_pos = ENTITY.GET_ENTITY_COORDS(players.user_ped(), true)
    local lester_blip = HUD.GET_NEXT_BLIP_INFO_ID(77)
    local casino_blip = HUD.GET_NEXT_BLIP_INFO_ID(804)

    if HUD.DOES_BLIP_EXIST(lester_blip) == 0 or HUD.DOES_BLIP_EXIST(casino_blip) == 0 then
        util.toast("[Recovery]: Failed to find blip(s)")
        return
    end

    local lester_coords = HUD.GET_BLIP_COORDS(lester_blip)
    local casino_coords = HUD.GET_BLIP_COORDS(casino_blip)

    ENTITY.SET_ENTITY_COORDS(players.user_ped(), casino_coords.x, casino_coords.y, casino_coords.z, true, true, true, true)
    PAD.SET_CONTROL_VALUE_NEXT_FRAME(0, 51, 1)
    ENTITY.SET_ENTITY_COORDS(players.user_ped(), lester_coords.x, lester_coords.y, lester_coords.z, true, true, true, true)
    util.yield(500)
    menu.trigger_commands("skipcutscene")
    util.yield(100)
    ENTITY.SET_ENTITY_COORDS(players.user_ped(), current_pos.x, current_pos.y, current_pos.z, true, true, true, true)

    util.toast("[Recovery]: Unlocked arcades")
end)

items.tools.root:action("Unlock Autoshops On MazeBank", {}, "Unlock Autoshops", function()
    local pos = v3.new(778.99708076172, -1867.5257568359, 28.296264648438)
    ENTITY.SET_ENTITY_COORDS(players.user_ped(), pos.x, pos.y, pos.z, true, true, true, true)
end)

items.presets.nightclub.root:action("Buy Nightclub", {}, "Automatically purchases a nightclub", function()
    local nc = nc_options.first[math.random(#nc_options.first)]
    local value = convert_value(options[items.presets.nightclub.choice.value])

    while nc == nc_owned do
        nc = nc_options.first[math.random(#nc_options.first)]
        util.yield()
    end

    local price = memory.read_int(globals.nightclub_prices[nc])

    if not can_make_purchase(price) then
        util.toast("[Recovery]: You need $" .. price .. " to purchase " .. nc .. " nightclub")
        return
    end

    value = (value + price) * 2
    if nc == "La Mesa" then value = value - 400000 end

    if not STATS.STAT_SET_INT(stats.nightclub, value, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set nightclub trade-in price")
        return
    end

    while menu.is_open() do
        util.toast("[Recovery]: Close Stand menu to continue")
        util.yield()
    end

    afk_meta:open_internet(false, "nightclub")
    afk_meta:purchase_nightclub(nc)

    nc_owned = get_owned_property("Nightclub")
end)

items.presets.nightclub.root:action("Set Value", {}, "Sets nightclub trade-in price to the preset you have picked", function()
    local value = convert_value(options[items.presets.nightclub.choice.value])
    if not STATS.STAT_SET_INT(stats.nightclub, value, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set nightclub trade-in price")
        return
    end
    util.toast("[Recovery]: Set nightclub trade-in price to " .. options[items.presets.nightclub.choice.value])
end)

items.presets.nightclub.root:divider("AFK Money Loop", "AFK Money Loop")
items.presets.nightclub.first_nightclub = items.presets.nightclub.root:list_select("First Nightclub", {}, "First nightclub to purchase", nc_options.first, "1", function(index) end)
items.presets.nightclub.second_nightclub = items.presets.nightclub.root:list_select("Second Nightclub", {}, "Second nightclub to purchase", nc_options.second, "1", function(index) end)
items.presets.nightclub.root:toggle_loop("Modify Value $1.07B", {}, "Modify the value to $1.07B", function()
    STATS.STAT_SET_INT(stats.nightclub, (2 << 30) - 1, true)
end)

items.presets.nightclub.root:toggle_loop("AFK Loop", {}, "Nightclub AFK money loop", function()
    local afk_loop =  menu.ref_by_rel_path(items.presets.nightclub.root, "AFK Loop")
    local first_nc_name = nc_options.first[tonumber(items.presets.nightclub.first_nightclub.value)]
    local second_nc_name = nc_options.second[tonumber(items.presets.nightclub.second_nightclub.value)]

    if first_nc_name == nc_owned then
        util.show_corner_help("You already own " .. nc_owned .. " choose another nightclub")
        afk_loop.value = false
        return
    end

    if first_nc_name == second_nc_name then
        util.show_corner_help("First and second nightclub cannot be the same, choose another nightclub")
        afk_loop.value = false
        return
    end

    if not afk_loop.value then return end

    afk_meta:open_internet(true, "nightclub")
    afk_meta:purchase_nightclub(first_nc_name)
    util.yield(1000)
    afk_meta:open_internet(true, "nightclub")
    afk_meta:purchase_nightclub(second_nc_name)
    util.yield(1000)

    nc_owned = get_owned_property("Nightclub")
end)

items.presets.arcade.root:divider("Settings", "Settings")
items.presets.arcade.choice = items.presets.arcade.root:list_select("Money", {}, "The arcade trade-in price", options, 1, function() end)
items.presets.arcade.root:action("Buy Arcade", {}, "Automatically buys an arcade for you", function()
    local arcade = arcade_options.first[math.random(#arcade_options.first)]
    local value = convert_value(options[items.presets.arcade.choice.value])

    if value < 0 then
        util.toast("[Recovery]: Negative values is not allowed")
        return
    end

    while arcade == arcade_owned do
        arcade = arcade_options.first[math.random(#arcade_options.first)]
        util.yield()
    end

    local price = memory.read_int(globals.arcade_prices[arcade])
    value = (value + price) * 2
    value = value - (255000 * 2)
    
    if not can_make_purchase(price) then
        util.toast("[Recovery]: You need $" .. price .. " to purchase " .. arcade .. " arcade")
        return
    end

    if not STATS.STAT_SET_INT(stats.arcade, value, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set arcade trade-in price")
        return
    end

    while menu.is_open() do
        util.toast("[Recovery]: Close Stand menu to continue")
        util.yield()
    end

    afk_meta:open_internet(false, "arcade")
    afk_meta:purchase_arcade(arcade)

    arcade_owned = get_owned_property("Arcade")
end)

items.presets.arcade.root:action("Set Value", {}, "Sets arcade trade-in price to the preset you have picked", function()
    local value = convert_value(options[items.presets.arcade.choice.value])
    if not STATS.STAT_SET_INT(stats.arcade, value, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set arcade trade-in price")
        return
    end
    util.toast("[Recovery]: Set arcade trade-in price to " .. options[items.presets.arcade.choice.value])
end)

items.presets.arcade.root:divider("AFK Money Loop", "AFK Money Loop")
items.presets.arcade.first_arcade = items.presets.arcade.root:list_select("First Arcade", {}, "The first arcade you want to use", arcade_options.first, 1, function() end)
items.presets.arcade.second_arcade = items.presets.arcade.root:list_select("Second Arcade", {}, "The second arcade you want to use", arcade_options.second, 1, function() end)
items.presets.arcade.root:toggle_loop("Modify Value $1.07B", {}, "Modify the value to $1.07B", function() STATS.STAT_SET_INT(stats.arcade, (2 << 30) - 1, true) end)

items.presets.arcade.root:toggle_loop("AFK Loop", {}, "Arcade AFK money loop", function()
    local afk_loop = menu.ref_by_rel_path(items.presets.arcade.root, "AFK Loop")
    local first_arcade = arcade_options.first[items.presets.arcade.first_arcade.value]
    local second_arcade = arcade_options.second[items.presets.arcade.second_arcade.value]

    if first_arcade == arcade_owned then
        util.show_corner_help("You already own " .. first_arcade .. " choose another arcade")
        afk_loop.value = false
        return
    end

    if first_arcade == second_arcade then
        util.show_corner_help("First and second arcade cannot be the same, choose another arcade")
        afk_loop.value = false
        return
    end

    if not afk_loop.value then return end

    afk_meta:open_internet(true, "arcade")
    afk_meta:purchase_arcade(first_arcade)
    util.yield(1000)
    afk_meta:open_internet(true, "arcade")
    afk_meta:purchase_arcade(second_arcade)
    util.yield(1000)

    arcade_owned = get_owned_property("Arcade")
end)

items.presets.autoshop.root:divider("Settings", "Settings")
items.presets.autoshop.choice = items.presets.autoshop.root:list_select("Money", {}, "The autoshop trade-in price", options, 1, function() end)
items.presets.autoshop.root:action("Set Value", {}, "Sets autoshop trade-in price to the preset you have picked", function()
    local value = convert_value(options[items.presets.autoshop.choice.value])
    if not STATS.STAT_SET_INT(stats.autoshop, value, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set autoshop trade-in price")
        return
    end
    util.toast("[Recovery]: Set autoshop trade-in price to " .. options[items.presets.autoshop.choice.value])
end)

items.presets.autoshop.root:action("Buy Autoshop", {}, "Automatically buys an autoshop for you", function()
    local autoshop = autoshop_options.first[math.random(#autoshop_options.first)]
    local value = convert_value(options[items.presets.autoshop.choice.value])

    if value < 0 then
        util.toast("[Recovery]: Negative values are not allowed")
        return
    end

    while autoshop == autoshop_owned do
        autoshop = autoshop_options.first[math.random(#autoshop_options.first)]
        util.yield()
    end

    local price = memory.read_int(globals.autoshop_prices[autoshop])

    if not can_make_purchase(price) then
        util.toast("[Recovery]: You need $" .. price .. " to purchase " .. autoshop .. " autoshop")
        return
    end

    value = (value + price) * 2
    switch autoshop do
        case "Mission Row":
            value = value - (160000 * 2)
            break
        case "Burton":
            value = value + (80000 * 2)
            break
    end

    if not STATS.STAT_SET_INT(stats.autoshop, value, true) then
        util.toast("[Recovery]: Failed to set autoshop trade-in price")
        return
    end

    while menu.is_open() do
        util.toast("[Recovery]: Close Stand menu to continue")
        util.yield()
    end

    afk_meta:open_internet(false, "autoshop")
    afk_meta:purchase_autoshop(autoshop)

    autoshop_owned = get_owned_property("Autoshop")
end)

items.presets.autoshop.root:divider("AFK Money Loop", "AFK Money Loop")
items.presets.autoshop.first_autoshop = items.presets.autoshop.root:list_select("First Autoshop", {}, "The first autoshop you want to use", autoshop_options.first, 1, function() end)
items.presets.autoshop.second_autoshop = items.presets.autoshop.root:list_select("Second Autoshop", {}, "The second autoshop you want to use", autoshop_options.second, 1, function() end)
items.presets.autoshop.root:toggle_loop("Modify Value $1.07B", {}, "Modify the value to $1.07B", function() STATS.STAT_SET_INT(stats.autoshop, (2 << 30) - 1, true) end)
items.presets.autoshop.root:toggle_loop("AFK Loop", {}, "Autoshop AFK money loop", function()
    local afk_loop = menu.ref_by_rel_path(items.presets.autoshop.root, "AFK Loop")
    local first_autoshop = autoshop_options.first[tonumber(items.presets.autoshop.first_autoshop.value)]
    local second_autoshop = autoshop_options.second[tonumber(items.presets.autoshop.second_autoshop.value)]

    if first_autoshop == autoshop_owned then
        util.show_corner_help("You already own " .. first_autoshop .. " choose another autoshop")
        afk_loop.value = false
        return
    end

    if first_autoshop == second_autoshop then
        util.show_corner_help("First and second autoshop cannot be the same, choose another autoshop")
        afk_loop.value = false
        return
    end

    if not afk_loop.value then return end

    afk_meta:open_internet(true, "autoshop")
    afk_meta:purchase_autoshop(first_autoshop)
    util.yield(1000)
    afk_meta:open_internet(true, "autoshop")
    afk_meta:purchase_autoshop(second_autoshop)
    util.yield(1000)

    autoshop_owned = get_owned_property("Autoshop")
end)

items.presets.hangar.root:divider("Settings", "Settings")
items.presets.hangar.choice = items.presets.hangar.root:list_select("Money", {}, "The hangar trade-in price", options, 1, function() end)
items.presets.hangar.root:toggle_loop("Enable", {}, "Enable the preset value for your hangar", function()
    local ref = menu.ref_by_rel_path(items.presets.hangar.root, "Enable")
    local value = convert_value(options[items.presets.hangar.choice.value])

    if settings.ownership_check then
        if not is_owned(stats.hangar_owned) then
            ref.value = false
            util.toast("[Recovery]: You do not own a hangar")
            return
        end
    end

    if not STATS.STAT_SET_INT(stats.hangar, ((value - 645000) * 2) + 4500000, true) then
        menu.ref_by_rel_path(items.presets.hangar.root, "Enable").value = false
        util.toast("[Recovery]: Failed to set hangar trade-in price")
    end

    if show_usage.hangar - os.time() <= 0 then
        show_usage.hangar = os.time() + usage_timer
        util.show_corner_help("Goto mazebank foreclosure website and purchase a new hangar to get the money")
    end
end)

items.presets.hangar.root:divider("AFK Money Loop", "AFK Money Loop")
items.presets.hangar.root:toggle_loop("Modify Value $1.07B", {}, "Modify the value to $1.07B", function() STATS.STAT_SET_INT(stats.hangar, (2 << 30) - 1, true) end)
items.presets.hangar.root:toggle_loop("AFK Loop", {}, "Hangar AFK money loop", function()
    local afk_loop = menu.ref_by_rel_path(items.presets.hangar.root, "AFK Loop")
    afk_loop.value = false
    util.toast("[Recovery]: Hangar AFK loop is not yet implemented")
end)

items.presets.facility.root:divider("Settings", "Settings")
items.presets.facility.choice = items.presets.facility.root:list_select("Money", {}, "The facility trade-in price", options, 1, function() end)
items.presets.facility.root:toggle_loop("Enable", {}, "Enable the preset value for your facility", function()
    local ref = menu.ref_by_rel_path(items.presets.facility.root, "Enable")
    local value = convert_value(options[items.presets.facility.choice.value])

    if settings.ownership_check then
        if not is_owned(stats.facility_owned) then
            ref.value = false
            util.toast("[Recovery]: You do not own a facility")
            return
        end
    end

    if not STATS.STAT_SET_INT(stats.facility, (value * 2) + 4500000, true) then
        menu.ref_by_rel_path(items.presets.facility.root, "Enable").value = false
        util.toast("[Recovery]: Failed to set facility trade-in price")
    end

    if show_usage.facility - os.time() <= 0 then
        show_usage.facility = os.time() + usage_timer
        util.show_corner_help("Goto mazebank foreclosure website and purchase a new facility to get the money")
    end
end)

items.presets.facility.root:divider("AFK Money Loop", "AFK Money Loop")
items.presets.facility.root:toggle_loop("Modify Value $1.07B", {}, "Modify the value to $1.07B", function() STATS.STAT_SET_INT(stats.facility, (2 << 30) - 1, true) end)
items.presets.facility.root:toggle_loop("AFK Loop", {}, "Facility AFK money loop", function()
    local afk_loop = menu.ref_by_rel_path(items.presets.facility.root, "AFK Loop")
    afk_loop.value = false
    util.toast("[Recovery]: Facility AFK loop is not yet implemented")
end)

items.presets.agency.root:divider("Settings", "Settings")
items.presets.agency.choice = items.presets.agency.root:list_select("Money", {}, "The agency trade-in price", options, 1, function() end)
items.presets.agency.root:toggle_loop("Enable", {}, "Enable the preset value for your agency", function()
    local ref = menu.ref_by_rel_path(items.presets.agency.root, "Enable")
    local value = convert_value(options[items.presets.agency.choice.value])
    
    if settings.ownership_check then
        if not is_owned(stats.agency_owned) then
            ref.value = false
            util.toast("[Recovery]: You do not own an agency")
            return
        end
    end

    if not STATS.STAT_SET_INT(stats.agency, ((value - 897500) * 2) + 4500000, true) then
        menu.ref_by_rel_path(items.presets.agency.root, "Enable").value = false
        util.toast("[Recovery]: Failed to set agency trade-in price")
    end

    if show_usage.agency - os.time() <= 0 then
        show_usage.agency = os.time() + usage_timer
        util.show_corner_help("Goto dynasty8executive website and purchase a new agency to get the money")
    end
end)

items.presets.agency.root:divider("AFK Money Loop", "AFK Money Loop")
items.presets.agency.root:toggle_loop("Modify Value $1.07B", {}, "Modify the value to $1.07B", function() STATS.STAT_SET_INT(stats.agency, (2 << 30) - 1, true) end)
items.presets.agency.root:toggle_loop("AFK Loop", {}, "Agency AFK money loop", function()
    local afk_loop = menu.ref_by_rel_path(items.presets.agency.root, "AFK Loop")
    afk_loop.value = false
    util.toast("[Recovery]: Agency AFK loop is not yet implemented")
end)

items.custom.root:divider("MazeBank Properties", "MazeBank Properties")
items.custom.nightclub.root = items.custom.root:list("Nightclub", {}, "Customisable values for nightclub")
items.custom.arcade.root = items.custom.root:list("Arcade", {}, "Customisable values for arcade")
items.custom.autoshop.root = items.custom.root:list("Autoshop", {}, "Customisable values for autoshop")
items.custom.hangar.root = items.custom.root:list("Hangar", {}, "Customisable values for hangar")
items.custom.facility.root = items.custom.root:list("Facility", {}, "Customisable values for facility")
items.custom.root:divider("Dynasty8Executive Properties", "Dynasty8Executive Properties")
items.custom.agency.root = items.custom.root:list("Agency", {}, "Customisable values for agency")

items.custom.nightclub.root:text_input("Money", {"nightclubvalue"}, "The nightclub trade-in price", function(value) 
    if settings.ownership_check then
        if not is_owned(stats.nightclub_owned) then
            util.toast("[Recovery]: You do not own a nightclub")
            return
        end
    end

    value = tonumber(value)

    if not STATS.STAT_SET_INT(stats.nightclub, (value * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set nightclub trade-in price")
    end
end, "0")

items.custom.nightclub.root:action("Buy Nightclub", {}, "Automatically purchases a new nightclub", function()
    local nc = nc_options.first[math.random(#nc_options.first)]
    local value = tonumber(menu.ref_by_rel_path(items.custom.nightclub.root, "Money").value)

    if value < 0 then
        util.toast("[Recovery]: Negative values are not allowed")
        return
    end

    while nc == nc_owned do
        nc = nc_options.first[math.random(#nc_options.first)]
    end

    local price = memory.read_int(globals.nightclub_prices[nc])
    
    if not can_make_purchase(price) then
        util.toast("[Recovery]: You do not have enough money to purchase a new nightclub")
        return
    end

    value = (value + price) * 2
    if nc == "La Mesa" then value = value - 400000 end

    if not STATS.STAT_SET_INT(stats.nightclub, value, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set nightclub trade-in price")
        return
    end

    while menu.is_open() do
        util.toast("[Recovery]: Close Stand menu to continue")
        util.yield()
    end

    afk_meta:open_internet(false, "nightclub")
    afk_meta:purchase_nightclub(nc)

    nc_owned = get_owned_property("Nightclub")
end)

items.custom.arcade.root:text_input("Money", {"arcadevalue"}, "The arcade trade-in price", function(value) 
    if settings.ownership_check then
        if not is_owned(stats.arcade_owned) then
            util.toast("[Recovery]: You do not own an arcade")
            return
        end
    end

    value = tonumber(value)

    if not STATS.STAT_SET_INT(stats.arcade, ((value - 255000) * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set arcade trade-in price")
    end
end, "0")

items.custom.arcade.root:action("Buy Arcade", {}, "Automatically buys an arcade for you", function()
    local arcade = arcade_options.first[math.random(#arcade_options.first)]
    local value = tonumber(menu.ref_by_rel_path(items.custom.arcade.root, "Money").value)

    if value < 0 then
        util.toast("[Recovery]: Negative values is not allowed")
        return
    end

    while arcade == arcade_owned do
        arcade = arcade_options.first[math.random(#arcade_options.first)]
        util.yield()
    end

    local price = memory.read_int(globals.arcade_prices[arcade])
    value = (value + price) * 2
    value = value - (255000 * 2)
    
    if not can_make_purchase(price) then
        util.toast("[Recovery]: You do not have enough money to purchase a new arcade")
        return
    end

    if not STATS.STAT_SET_INT(stats.arcade, value, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set arcade trade-in price")
        return
    end

    while menu.is_open() do
        util.toast("[Recovery]: Close Stand menu to continue")
        util.yield()
    end

    afk_meta:open_internet(false, "arcade")
    afk_meta:purchase_arcade(arcade)

    arcade_owned = get_owned_property("Arcade")
end)

items.custom.autoshop.root:text_input("Money", {"autoshopvalue"}, "The autoshop trade-in price", function(value) 
    if settings.ownership_check then
        if not is_owned(stats.autoshop_owned) then
            util.toast("[Recovery]: You do not own an autoshop")
            return
        end
    end

    value = tonumber(value)

    if not STATS.STAT_SET_INT(stats.autoshop, (value * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set autoshop trade-in price")
    end
end, "0")

items.custom.autoshop.root:action("Buy Autoshop", {}, "Automatically buys an autoshop for you", function()
    local autoshop = autoshop_options.first[math.random(#autoshop_options.first)]
    local value = tonumber(menu.ref_by_rel_path(items.custom.autoshop.root, "Money").value)

    if value < 0 then
        util.toast("[Recovery]: Negative values are not allowed")
        return
    end

    while autoshop == autoshop_owned do
        autoshop = autoshop_options.first[math.random(#autoshop_options.first)]
        util.yield()
    end

    local price = memory.read_int(globals.autoshop_prices[autoshop])
    
    if not can_make_purchase(price) then
        util.toast("[Recovery]: You do not have enough money to purchase a new autoshop")
        return
    end

    value = (value + price) * 2
    switch autoshop do
        case "Mission Row":
            value = value - (160000 * 2)
            break
        case "Burton":
            value = value + (80000 * 2)
            break
    end

    if not STATS.STAT_SET_INT(stats.autoshop, value, true) then
        util.toast("[Recovery]: Failed to set autoshop trade-in price")
        return
    end

    while menu.is_open() do
        util.toast("[Recovery]: Close Stand menu to continue")
        util.yield()
    end

    afk_meta:open_internet(false, "autoshop")
    afk_meta:purchase_autoshop(autoshop)

    autoshop_owned = get_owned_property("Autoshop")
end)

items.custom.hangar.root:text_input("Money", {"hangarvalue"}, "The hangar trade-in price", function(value) 
    if settings.ownership_check then
        if not is_owned(stats.hangar_owned) then
            util.toast("[Recovery]: You do not own a hangar")
            return
        end
    end

    value = tonumber(value)

    if not STATS.STAT_SET_INT(stats.hangar, ((value - 255000) * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set hangar trade-in price")
    end

    util.show_corner_help("Goto mazebank foreclosure website and purchase a new hangar to get the money")
end, "0")

items.custom.hangar.root:toggle_loop("Enable", {}, "", function()
    local ref = menu.ref_by_rel_path(items.custom.hangar.root, "Enable")
    local value = tonumber(menu.ref_by_rel_path(items.custom.hangar.root, "Money").value)
    
    if settings.ownership_check then
        if not is_owned(stats.hangar_owned) then
            ref.value = false
            util.toast("[Recovery]: You do not own a hangar")
            return
        end
    end

    if not STATS.STAT_SET_INT(stats.hangar, ((value - 255000) * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set hangar trade-in price")
    end

    if show_usage.hangar - os.time() <= 0 then
        show_usage.hangar = os.time() + 15
        util.show_corner_help("Goto mazebank foreclosure website and purchase a new hangar to get the money")
    end
end)

items.custom.facility.root:text_input("Money", {"facilityvalue"}, "The facility trade-in price", function(value) 
    if settings.ownership_check then
        if not is_owned(stats.facility_owned) then
            util.toast("[Recovery]: You do not own a facility")
            return
        end
    end

    value = tonumber(value)

    if not STATS.STAT_SET_INT(stats.facility, (value * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set facility trade-in price")
    end

    util.show_corner_help("Goto mazebank foreclosure website and purchase a new facility to get the money")
end, "0")

items.custom.facility.root:toggle_loop("Enable", {}, "", function()
    local ref = menu.ref_by_rel_path(items.custom.facility.root, "Enable")
    local value = tonumber(menu.ref_by_rel_path(items.custom.facility.root, "Money").value)
    
    if settings.ownership_check then
        if not is_owned(stats.facility_owned) then
            ref.value = false
            util.toast("[Recovery]: You do not own a facility")
            return
        end
    end

    if not STATS.STAT_SET_INT(stats.facility, (value * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set facility trade-in price")
    end

    if show_usage.facility - os.time() <= 0 then
        show_usage.facility = os.time() + 15
        util.show_corner_help("Goto mazebank foreclosure website and purchase a new facility to get the money")
    end
end)

items.custom.agency.root:text_input("Money", {"agencyvalue"}, "The agency trade-in price", function(value) 
    if settings.ownership_check then
        if not is_owned(stats.agency_owned) then
            util.toast("[Recovery]: You do not own an agency")
            return
        end
    end

    value = tonumber(value)

    if not STATS.STAT_SET_INT(stats.agency, ((value - 645000) * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set agency trade-in price")
    end

    util.show_corner_help("Goto mazebank foreclosure website and purchase a new agency to get the money")
end, "0")

items.custom.agency.root:toggle_loop("Enable", {}, "", function()
    local ref = menu.ref_by_rel_path(items.custom.agency.root, "Enable")
    local value = tonumber(menu.ref_by_rel_path(items.custom.agency.root, "Money").value)
    
    if settings.ownership_check then
        if not is_owned(stats.agency_owned) then
            ref.value = false
            util.toast("[Recovery]: You do not own an agency")
            return
        end
    end

    if not STATS.STAT_SET_INT(stats.agency, ((value - 645000) * 2) + 4500000, true) then
        ref.value = false
        util.toast("[Recovery]: Failed to set agency trade-in price")
    end

    if show_usage.agency - os.time() <= 0 then
        show_usage.agency = os.time() + 15
        util.show_corner_help("Goto dynasty8executive website and purchase a new agency to get the money")
    end
end)

items.dax_mission.root = root:list("Dax Missions", {"daxmissions"}, "Make easy money from the new dax missions added during Drugs Wars update")
items.dax_mission.root:divider("Help", "How to use this menu")
items.dax_mission.root:action("How To Use", {}, "", function()
    util.show_corner_help("Check 'enable cash boost' option and start one of the new dax missions (if you haven't completed the first mission the 'Start Mission' will automatically start the first mission for you, the R on the map at sandy shores), once the mission has started you need to kill yourself immediately to fail the mission and you will recieve $1,000,000, take too long to kill yourself during the mission and you won\'t get any money")
end)

items.dax_mission.root:divider("Compatible Missions", "Compatible Missions")
items.dax_mission.root:readonly("First Dose 1 - Welcome to the Troupe")
items.dax_mission.root:readonly("First Dose 2 - Designated Driver")

items.dax_mission.root:divider("Options", "Recovery options using Dax Mission")
items.dax_mission.root:action("Make $1M - First Dose 1", {}, "Automatically starts First Dose 1 - Welcome to the Troupe mission and causes the mission to fail making you $1M", function()
    local ped = PLAYER.PLAYER_PED_ID()
    ENTITY.SET_ENTITY_COORDS(ped, 1394.4620361328, 3598.4528808594, 34.990489959717)
    util.yield(200)
    SIMULATE_CONTROL_KEY(51, 1)
    util.yield(1500)
    SIMULATE_CONTROL_KEY(188, 1, 2)
    SIMULATE_CONTROL_KEY(201, 1)
    SIMULATE_CONTROL_KEY(188, 1, 2)
    SIMULATE_CONTROL_KEY(201, 1)
    SIMULATE_CONTROL_KEY(201, 1, 2)
    util.yield(6000)
    memory.write_float(tunable(0), 5000.0)
    menu.trigger_commands("suicide")
    util.yield(3000)
    menu.trigger_commands("suicide")
    util.yield(3000)
    menu.trigger_commands("suicide")
    util.yield(4500)
    SIMULATE_CONTROL_KEY(201, 10)
end)

items.dax_mission.root:toggle_loop("Enable Cash Boost", {}, "", function()
    local cash = tunable(0)
    local ref = menu.ref_by_rel_path(items.dax_mission.root, "Enable RP Boost")
    
    if not ref.value then
        memory.write_float(cash, 5000.0) -- setting this value higher causes you to get no money (1m is the limit)
    end
end)

items.dax_mission.root:toggle_loop("Enable RP Boost", {}, "", function()
    local cash = tunable(0)
    local rp = tunable(1)
    local ref = menu.ref_by_rel_path(items.dax_mission.root, "Enable Cash Boost")
    
    memory.write_float(rp, 2000.0)
    if ref.value then
        memory.write_float(cash, 500.0)
    end
end)

items.casino_figures.root = root:list("Casino Figures", {"casinofigures"}, "Changes the amount of money you recieve from 1 figure to $200,000")
items.casino_figures.root:toggle_loop("Enable", {}, "Drops figures that give you $200,000", function()
    local cash = tunable(27123)

    memory.write_int(cash, 200000)
    menu.trigger_commands("rp" .. players.get_name(players.user()) .. " on")
end, function()
    local cash = tunable(27123)

    memory.write_int(cash, 1000)
    menu.trigger_commands("rp" .. players.get_name(players.user()) .. " off")
end)

items.casino_figures.root:toggle("Disable RP", {}, "Disables RP from casino figures", function(state)
    local rp = tunable(1)

    if state then
        memory.write_float(rp, 0)
    else
        memory.write_float(rp, 1.0)
    end
end)

items.heists.root = root:list("Heists", {"heists"}, "Heist recovery options")
items.heists.casino = items.heists.root:list("Casino Heist", {"casinoheist"}, "Casino Heist recovery options")
items.heists.cayo_perico = items.heists.root:list("Cayo Perico Heist", {"cayopericoheist"}, "Cayo Perico Heist recovery options")

items.heists.root.visible = false