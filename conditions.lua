-- Initialize variables
local CURRENT_CONDITION = 0  -- Default to DRY
local SAVE_ENABLED = false   -- Default to not saving between sessions
local runway_wnd = nil       -- Store window reference globally

-- Add dataref access
dataref("current_friction", "sim/weather/region/runway_friction", "writable")

-- Add condition definitions with enhanced descriptions
local CONDITIONS = {
    [0] = {name = "DRY", desc = "Normal runway conditions - Standard braking performance and handling characteristics", coef = "1.00"},
    -- Wet conditions
    [1] = {name = "WET Light", desc = "Slightly wet surface - Minor reduction in braking effectiveness, exercise normal caution", coef = "0.85"},
    [2] = {name = "WET Medium", desc = "Wet surface with reduced braking - Increased stopping distance, firm brake pressure needed", coef = "0.70"},
    [3] = {name = "WET Maximum", desc = "Very wet with significantly reduced braking - Considerable increase in stopping distance, potential for hydroplaning at high speeds", coef = "0.55"},
    -- Standing Water
    [4] = {name = "Standing Water Light", desc = "Shallow puddles present - Early hydroplaning possible above 100 knots, directional control becomes sensitive", coef = "0.45"},
    [5] = {name = "Standing Water Medium", desc = "Significant puddles with high hydroplaning risk - Use reduced landing speeds, expect poor braking effectiveness", coef = "0.35"},
    [6] = {name = "Standing Water Maximum", desc = "Deep water with severe hydroplaning risk - Consider alternate runway, extreme caution required during landing roll", coef = "0.25"},
    -- Snow conditions
    [7] = {name = "SNOW Light", desc = "Light snow coverage - Reduced friction, careful control inputs needed, watch for snow banks near runway edges", coef = "0.40"},
    [8] = {name = "SNOW Medium", desc = "Moderate snow with significantly reduced friction - Steering effectiveness decreased, plan for longer stopping distance", coef = "0.30"},
    [9] = {name = "SNOW Maximum", desc = "Heavy snow coverage - Very poor braking action, consider wind effects on loose snow, significant stopping distance increase", coef = "0.20"},
    -- Ice conditions
    [10] = {name = "ICE Light", desc = "Patches of ice present - Unpredictable braking performance, careful rudder inputs required", coef = "0.15"},
    [11] = {name = "ICE Medium", desc = "Significant ice coverage - Very limited braking action, extreme caution during turn-off", coef = "0.10"},
    [12] = {name = "ICE Maximum", desc = "Complete ice coverage - Minimal effective braking, risk of complete directional control loss", coef = "0.05"},
    -- Snow and Ice
    [13] = {name = "SNOW/ICE Light", desc = "Light snow over ice - Very poor friction, unpredictable surface changes, exercise extreme caution", coef = "0.12"},
    [14] = {name = "SNOW/ICE Medium", desc = "Moderate snow over ice - Severe braking limitations, high risk of directional control loss", coef = "0.08"},
    [15] = {name = "SNOW/ICE Maximum", desc = "Heavy snow over ice - Most hazardous condition, consider runway closure conditions, extreme risk", coef = "0.04"}
}

-- Save last condition to file
function save_condition()
    if SAVE_ENABLED then
        local file = io.open(SCRIPT_DIRECTORY .. "custom_conditions.cfg", "w")
        if file then
            file:write(tostring(CURRENT_CONDITION))
            file:close()
        end
    end
end

-- Save persistence setting
function save_persistence_setting()
    local file = io.open(SCRIPT_DIRECTORY .. "custom_conditions_persistence.cfg", "w")
    if file then
        file:write(tostring(SAVE_ENABLED))
        file:close()
    end
end

-- Load persistence setting
function load_persistence_setting()
    local file = io.open(SCRIPT_DIRECTORY .. "custom_conditions_persistence.cfg", "r")
    if file then
        local value = file:read("*all")
        file:close()
        SAVE_ENABLED = value == "true"
    end
end

-- Load last condition from file
function load_condition()
    if SAVE_ENABLED then
        local file = io.open(SCRIPT_DIRECTORY .. "custom_conditions.cfg", "r")
        if file then
            local value = tonumber(file:read("*all"))
            file:close()
            if value and CONDITIONS[value] then
                update_runway_condition(value)
            end
        end
    end
end

if not SUPPORTS_FLOATING_WINDOWS then
    logMsg("imgui not supported by your FlyWithLua version")
    return
end

-- Function to update runway condition
function update_runway_condition(value)
    CURRENT_CONDITION = value
    current_friction = value
    set("sim/weather/region/runway_friction", value)
    save_condition()
    
    -- Debug output
    logMsg(string.format("Set runway friction to: %s (%s)", tostring(value), CONDITIONS[value].name))
end

function build_runway_window(runway_wnd, x, y)
    imgui.TextUnformatted("Custom Conditions v1.4")
    imgui.TextUnformatted("You can set these with Real Weather enabled")
    imgui.TextUnformatted("")
    
    -- Set text wrapping based on window width (subtract a small margin)
    imgui.PushTextWrapPos(imgui.GetWindowWidth() - 20)
    
    -- Current condition display
    imgui.TextUnformatted(string.format("Current: %s (Friction: %s)", 
        CONDITIONS[CURRENT_CONDITION].name,
        CONDITIONS[CURRENT_CONDITION].coef))
    imgui.TextUnformatted(CONDITIONS[CURRENT_CONDITION].desc)
    
    imgui.PopTextWrapPos()
    
    imgui.TextUnformatted("")
        
    -- DRY condition
    local selected = (CURRENT_CONDITION == 0)
    local changed = imgui.RadioButton("DRY", selected)
    if changed then
        update_runway_condition(0)
    end
    
    imgui.TextUnformatted("")
    imgui.TextUnformatted("WET Conditions:")
    
    -- WET conditions
    selected = (CURRENT_CONDITION == 1)
    changed = imgui.RadioButton("Light##wet", selected)
    if changed then
        update_runway_condition(1)
    end
    
    imgui.SameLine()
    selected = (CURRENT_CONDITION == 2)
    changed = imgui.RadioButton("Medium##wet", selected)
    if changed then
        update_runway_condition(2)
    end
    
    imgui.SameLine()
    selected = (CURRENT_CONDITION == 3)
    changed = imgui.RadioButton("Maximum##wet", selected)
    if changed then
        update_runway_condition(3)
    end
    
    imgui.TextUnformatted("")
    imgui.TextUnformatted("Standing Water Conditions:")
    
    selected = (CURRENT_CONDITION == 4)
    changed = imgui.RadioButton("Light##water", selected)
    if changed then
        update_runway_condition(4)
    end
    
    imgui.SameLine()
    selected = (CURRENT_CONDITION == 5)
    changed = imgui.RadioButton("Medium##water", selected)
    if changed then
        update_runway_condition(5)
    end
    
    imgui.SameLine()
    selected = (CURRENT_CONDITION == 6)
    changed = imgui.RadioButton("Maximum##water", selected)
    if changed then
        update_runway_condition(6)
    end
    
    imgui.TextUnformatted("")
    imgui.TextUnformatted("Snow Conditions:")
    
    selected = (CURRENT_CONDITION == 7)
    changed = imgui.RadioButton("Light##snow", selected)
    if changed then
        update_runway_condition(7)
    end
    
    imgui.SameLine()
    selected = (CURRENT_CONDITION == 8)
    changed = imgui.RadioButton("Medium##snow", selected)
    if changed then
        update_runway_condition(8)
    end
    
    imgui.SameLine()
    selected = (CURRENT_CONDITION == 9)
    changed = imgui.RadioButton("Maximum##snow", selected)
    if changed then
        update_runway_condition(9)
    end
    
    imgui.TextUnformatted("")
    imgui.TextUnformatted("Ice Conditions:")
    
    selected = (CURRENT_CONDITION == 10)
    changed = imgui.RadioButton("Light##ice", selected)
    if changed then
        update_runway_condition(10)
    end
    
    imgui.SameLine()
    selected = (CURRENT_CONDITION == 11)
    changed = imgui.RadioButton("Medium##ice", selected)
    if changed then
        update_runway_condition(11)
    end
    
    imgui.SameLine()
    selected = (CURRENT_CONDITION == 12)
    changed = imgui.RadioButton("Maximum##ice", selected)
    if changed then
        update_runway_condition(12)
    end
    
    imgui.TextUnformatted("")
    imgui.TextUnformatted("Snowy and Icy Conditions:")
    
    selected = (CURRENT_CONDITION == 13)
    changed = imgui.RadioButton("Light##snowice", selected)
    if changed then
        update_runway_condition(13)
    end
    
    imgui.SameLine()
    selected = (CURRENT_CONDITION == 14)
    changed = imgui.RadioButton("Medium##snowice", selected)
    if changed then
        update_runway_condition(14)
    end
    
    imgui.SameLine()
    selected = (CURRENT_CONDITION == 15)
    changed = imgui.RadioButton("Maximum##snowice", selected)
    if changed then
        update_runway_condition(15)
    end

    -- Settings section
    imgui.TextUnformatted("")
    imgui.TextUnformatted("")
    local persist_changed, persist_new = imgui.Checkbox("Load chosen conditions on next X-Plane startup", SAVE_ENABLED)

    imgui.PushTextWrapPos(imgui.GetWindowWidth() - 20)
    imgui.TextUnformatted("If un-checked, X-plane will load default conditions.")
    imgui.PopTextWrapPos()
    
    if persist_changed then
        SAVE_ENABLED = persist_new
        save_persistence_setting()
        if not SAVE_ENABLED then
            -- Remove saved condition file when disabling persistence
            os.remove(SCRIPT_DIRECTORY .. "custom_conditions.cfg")
        end
    end
    
    imgui.TextUnformatted("")
    
end

-- Function to toggle window visibility
function custom_conditions_toggle_window()
    if runway_wnd then
        -- If window exists, destroy it
        float_wnd_destroy(runway_wnd)
        runway_wnd = nil
    else
        -- Create new window if it doesn't exist
        runway_wnd = float_wnd_create(500, 550, 1, true)
        float_wnd_set_title(runway_wnd, "Custom Conditions v1.4")
        float_wnd_set_imgui_builder(runway_wnd, "build_runway_window")
    end
end

-- Create commands
create_command("FlyWithLua/RunwayConditions/toggle", "Toggle Custom Conditions Window",
    "custom_conditions_toggle_window()", "", "")

-- Add macro to plugins menu
add_macro("Custom Conditions", "custom_conditions_toggle_window()")

-- Load persistence setting first
load_persistence_setting()
-- Then load condition if persistence is enabled
load_condition()