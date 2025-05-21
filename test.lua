---@diagnostic disable: lowercase-global, undefined-field, redundant-value

script_name("TCP Helper Premium")
script_description('���������� �������� ��� ��������� ��������� | Arizona RP')
script_author("Legenda tg @mementomore4")
script_version("4.2")

require("lib.moonloader")
local sampev = require('samp.events')
local encoding = require('encoding')
local imgui = require("mimgui")
local inicfg = require('inicfg')
encoding.default = 'CP1251'
u8 = encoding.UTF8

function recode(text)
    return encoding.UTF8:decode(text)
end

function apply_custom_style()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    
    style.WindowPadding = imgui.ImVec2(15, 15)
    style.WindowRounding = 6.0
    style.FramePadding = imgui.ImVec2(5, 5)
    style.FrameRounding = 4.0
    style.ItemSpacing = imgui.ImVec2(12, 8)
    style.ItemInnerSpacing = imgui.ImVec2(8, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 15.0
    style.ScrollbarRounding = 9.0
    style.GrabMinSize = 5.0
    style.GrabRounding = 3.0
    
    colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
    colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ChildBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
    colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
    colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
    colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
    colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
    colors[clr.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00)
    colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31)
    colors[clr.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
    colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
    colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
    colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
    colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
    colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
end

apply_custom_style()

-- ������������
local config = {
    settings = {
        automsg = true,
        sound = true
    }
}

local config_path = getWorkingDirectory().."\\config\\TCP_Helper.ini"
local config_file = inicfg.load(config, config_path)

-- ���������
local renderWindow = imgui.new.bool(false)
local assistWindow = imgui.new.bool(false)
local settingsWindow = imgui.new.bool(false)
local my_name = "������ ��������"
local current_action = nil
local action_index = 1
local action_delay = 0
local current_player_id = nil
local lastgun = 0
local script_activated = false
local update_check_time = 0
local need_update_check = false

-- �����
local tcp_color = imgui.ImVec4(1.0, 0.4, 0.0, 1.0)
local btn_color = imgui.ImVec4(0.8, 0.3, 0.0, 1.0)
local btn_hover = imgui.ImVec4(1.0, 0.5, 0.0, 1.0)

-- ���� � �������� � ��� ��������
local LOGO_PATH = getWorkingDirectory() .. "\\moonloader\\resource\\tcp_logo.png"

-- �������� ���������� ��� ��������
if not doesDirectoryExist(getWorkingDirectory() .. "\\moonloader\\resource") then
    createDirectory(getWorkingDirectory() .. "\\moonloader\\resource")
end
-- �������� ��������
local tcp_logo
if doesFileExist(LOGO_PATH) then
    tcp_logo = imgui.CreateTextureFromFile(LOGO_PATH)
end
-- ������
local prison_data = {
    codes = {
        u8"10-1  - ���� ���������",
        u8"10-4  - �������",
        u8"10-6  - �����",
        u8"10-15 - ���������� ��������",
        u8"10-18 - ��������� ������������",
        u8"10-20 - ��� �������",
        u8"10-33 - ������� ������",
        u8"10-55 - ��������",
        u8"10-66 - ����",
        u8"10-77 - �����",
        u8"10-88 - ��",
        u8"10-99 - ��� ���������"
    },

    procedures = {
        u8"1. ����� ������������:",
        u8"   - �������",
        u8"   - ���������",
        u8"   - ����������",
        "",
        u8"2. �������������:",
        u8"   - 2+ ���������",
        u8"   - �������� ��������"
    },

    about = {
        u8"TCP Helper Premium v4.2",
        u8"�����: Legenda",
        u8"��������: t.me/mementomore4",
        "",
        u8"�����������:",
        u8"- ������� ���������",
        u8"- ������� ��������",
        u8"- ������ ���������� �����",
        u8"- ��������� ��� ����"
    },

    updates = {
        u8"��������� ����������:",
        u8"� ������� ����� �����������",
        u8"� ����������� ������� ��� ������",
        u8"� �������������� ����������� �������",
        u8"� ������� ���������� �����������",
        u8"� ���������� � ������",
        "",
        u8"������� ������: 4.2 (���������)",
        u8"��������� ����������: 4.3",
        u8"���� ������: ���� 2024",
        "",
        u8"������: ���������� ������"
    },

    history = {
        u8"������� ����������:",
        "",
        u8"������ 4.2 (�������):",
        u8"� ������� ��������� �������",
        u8"� ��������� ����� �������",
        u8"� ���������� ������ ���������",
        u8"� ����������� ������������������",
        u8"� ������� ��������� �������",
        "",
        u8"������ 4.1:",
        u8"� ��������� ������� �����������",
        u8"� ����� �� ���������",
        u8"� �������� ������ � �������",
        "",
        u8"������ 4.0:",
        u8"� ������ ���������� ����������",
        u8"� �������� ���������� �����",
        u8"� ������� ������� ��������",
        u8"� ��������� �������"
    }
}

-- ��������
local actions = {
    search = {
        {"me ������� �������� � �����"},
        {"do ������ ����������� ��������"},
        {"me �������� ����� {victim}"},
        {"do �������� �������� � �����"},
        {"do ����� ��������"}
    },
    cuff = {
        {"me ������� ���������"},
        {"do ��������� Peerless"},
        {"me �������� ��������� �� {victim}"},
        {"do ������ ����������"}
    }
}

-- �������
function checkUpdates()
    if script_activated then
        need_update_check = true
        update_check_time = os.clock()
    else
        sampAddChatMessage("{FF6600}[TCP Premium] {FFFFFF}������ �� �����������!", -1)
    end
end

function processUpdateCheck()
    if need_update_check and os.clock() - update_check_time >= 1.0 then
        sampAddChatMessage("{FF6600}[TCP Premium] {FFFFFF}�������� ����������...", -1)
        sampAddChatMessage("{FF6600}[TCP Premium] {FFFFFF}� ��� ����������� ��������� ������ �������!", -1)
        sampAddChatMessage("{FF6600}[TCP Premium] {FFFFFF}������� ������: {FF9900}4.2", -1)
        need_update_check = false
    end
end
function main()
    while not isSampAvailable() do wait(100) end
    while not sampIsLocalPlayerSpawned() do wait(100) end

    my_name = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
    registerCommands()
    loadConfig()

    -- ��������� �������
    script_activated = true
    sampAddChatMessage("{FF6600}[TCP Premium] {FFFFFF}������ ������� ��������!", -1)
    sampAddChatMessage("{FF6600}[TCP Premium] {FFFFFF}������: {FF9900}4.2 {FFFFFF}| �����: {00BFFF}Legenda", -1)
    sampAddChatMessage("{FF6600}[TCP Premium] {FFFFFF}������ �����������! ����������� {FF9900}/tcp {FFFFFF}��� �������� ����.", -1)

    while true do
        wait(0)
        processActions()
        checkWeaponChange()
        processUpdateCheck()
    end
end

function processActions()
    if not current_action or os.clock() < action_delay then return end
    
    local action = actions[current_action]
    if action_index <= #action then
        local text = action[action_index][1]
        local victim = current_player_id and sampGetPlayerNickname(current_player_id) or "������������"
        sampSendChat("/" .. text:gsub("{victim}", victim):gsub("{my_name}", my_name))
        action_index = action_index + 1
        action_delay = os.clock() + 1.5
    else
        current_action = nil
    end
end

function checkWeaponChange()
    local gun = getCurrentCharWeapon(PLAYER_PED)
    if gun == lastgun then return end
    
    if config.settings.automsg then
        if gun == 23 then
            sampSendChat("/do �� ����� ������������ TASER.")
            sampSendChat("/me ��������� ������")
        elseif gun == 22 then
            sampSendChat("/do � ������ Glock-17")
            sampSendChat("/me ������� ��������")
        elseif gun == 0 then
            sampSendChat("/me ������� ������")
        end
    end
    
    lastgun = gun
end

function startAction(action, player_id)
    if actions[action] then
        current_action = action
        action_index = 1
        action_delay = os.clock() + 1.0
        current_player_id = player_id
        return true
    end
    return false
end

function block_number()
    local x = getCharCoordinates(PLAYER_PED)
    if x > 300 then return "A" end
    if x > 200 then return "B" end
    if x > 100 then return "C" end
    return "D"
end

function loadConfig()
    if not doesFileExist(config_path) then
        inicfg.save(config, config_path)
    else
        config_file = inicfg.load(config, config_path)
    end
end

function saveConfig()
    inicfg.save(config, config_path)
end

function registerCommands()
    sampRegisterChatCommand('tcp', function()
        if script_activated then
            renderWindow[0] = not renderWindow[0]
        else
            sampAddChatMessage("{FF6600}[TCP Premium] {FFFFFF}������ �� �����������!", -1)
        end
    end)

    sampRegisterChatCommand('search', function(param)
        if not script_activated then
            sampAddChatMessage("{FF6600}[TCP Premium] {FFFFFF}������ �� �����������!", -1)
            return
        end
        local id = tonumber(param)
        if id and sampIsPlayerConnected(id) then
            startAction('search', id)
        else
            sampAddChatMessage("{FF6600}[TCP] {FFFFFF}�����������: /search [ID]", -1)
        end
    end)

    sampRegisterChatCommand('cuff', function(param)
        if not script_activated then
            sampAddChatMessage("{FF6600}[TCP Premium] {FFFFFF}������ �� �����������!", -1)
            return
        end
        local id = tonumber(param)
        if id and sampIsPlayerConnected(id) then
            startAction('cuff', id)
        else
            sampAddChatMessage("{FF6600}[TCP] {FFFFFF}�����������: /cuff [ID]", -1)
        end
    end)
end

-- ���������
local player_id = imgui.new.int(-1)

local mainFrame = imgui.OnFrame(function() return renderWindow[0] end, function(player)
    imgui.SetNextWindowSize(imgui.ImVec2(450, 500), imgui.Cond.FirstUseEver)
    imgui.Begin(u8'TCP Helper Premium v4.2', renderWindow)
    
    if tcp_logo then
        local logo_size = imgui.ImVec2(64, 64)
        local window_width = imgui.GetWindowWidth()
        local cursor_pos_x = (window_width - logo_size.x) * 0.5
        
        imgui.SetCursorPosX(cursor_pos_x)
        imgui.Image(tcp_logo, logo_size)
        imgui.Spacing()
    else
        local text = u8"TCP HELPER PREMIUM"
        local text_width = imgui.CalcTextSize(text).x
        imgui.SetCursorPosX((imgui.GetWindowWidth() - text_width) * 0.5)
        imgui.TextColored(tcp_color, text)
    end
    
    imgui.Separator()
    
    if imgui.BeginTabBar('MainTabs') then
        if imgui.BeginTabItem(u8'��������') then
            imgui.InputInt(u8'ID ������������', player_id)
            
            if player_id[0] ~= -1 and sampIsPlayerConnected(player_id[0]) then
                imgui.Text(u8'������: ' .. sampGetPlayerNickname(player_id[0]))
                
                imgui.PushStyleColor(imgui.Col.Button, btn_color)
                imgui.PushStyleColor(imgui.Col.ButtonHovered, btn_hover)
                
                if imgui.Button(u8'��������', imgui.ImVec2(-1, 40)) then
                    startAction('search', player_id[0])
                end
                
                if imgui.Button(u8'���������', imgui.ImVec2(-1, 40)) then
                    startAction('cuff', player_id[0])
                end
                
                imgui.PopStyleColor(2)
            else
                imgui.Text(u8'������� ID ������������')
            end
            
            imgui.Separator()
            
            if imgui.Button(u8'���������� ������', imgui.ImVec2(-1, 40)) then
                assistWindow[0] = true
            end
            
            imgui.EndTabItem()
        end
        
        if imgui.BeginTabItem(u8'����������') then
            if imgui.CollapsingHeader(u8'�������� ����') then
                for _, code in ipairs(prison_data.codes) do
                    imgui.Text(code)
                end
            end
            
            if imgui.CollapsingHeader(u8'���������') then
                for _, proc in ipairs(prison_data.procedures) do
                    imgui.Text(proc)
                end
            end
            
            imgui.EndTabItem()
        end
        
        if imgui.BeginTabItem(u8'� �������') then
            imgui.Spacing()
            for _, line in ipairs(prison_data.about) do
                imgui.Text(line)
            end
            imgui.Spacing()
            imgui.Text(u8"��� �����: t.me/mementomore4")
            imgui.EndTabItem()
        end

        if imgui.BeginTabItem(u8'����������') then
            imgui.BeginChild("UpdatesChild", imgui.ImVec2(0, 250), true)
            
            imgui.PushStyleColor(imgui.Col.Text, tcp_color)
            imgui.Text(u8"����� �������� TCP Helper")
            imgui.PopStyleColor()
            imgui.Separator()
            imgui.Spacing()
            
            if script_activated then
                imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.0, 1.0, 0.0, 1.0))
                imgui.Text(u8"������: �����������")
                imgui.PopStyleColor()
            else
                imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.0, 0.0, 1.0))
                imgui.Text(u8"������: �� �����������")
                imgui.PopStyleColor()
            end
            
            imgui.Text(u8"����������� ��������� ������: 4.2")
            imgui.Spacing()
            imgui.Separator()
            imgui.Spacing()
            
            for _, line in ipairs(prison_data.updates) do
                if line == "" then
                    imgui.Spacing()
                    else
                    imgui.Text(line)
                end
            end
            
            imgui.EndChild()
            
            imgui.BeginChild("HistoryChild", imgui.ImVec2(0, 150), true)
            for _, line in ipairs(prison_data.history) do
                if line == "" then
                    imgui.Spacing()
                else
                    imgui.Text(line)
                end
            end
            imgui.EndChild()
            
            if imgui.Button(u8'��������� ����������', imgui.ImVec2(-1, 30)) then
                checkUpdates()
            end
            
            imgui.EndTabItem()
        end
        
        imgui.EndTabBar()
    end
    
    imgui.End()
end)

-- ���� ���������
local assistFrame = imgui.OnFrame(function() return assistWindow[0] end, function(player)
    imgui.SetNextWindowSize(imgui.ImVec2(350, 250), imgui.Cond.FirstUseEver)
    imgui.Begin(u8'���������� ������', assistWindow)
    
    imgui.TextColored(tcp_color, u8"���������� ��������")
    imgui.Separator()
    
    imgui.PushStyleColor(imgui.Col.Button, btn_color)
    imgui.PushStyleColor(imgui.Col.ButtonHovered, btn_hover)
    
    if imgui.Button(u8'������ ������������ (10-18)', imgui.ImVec2(-1, 50)) then
        sampSendChat("/r 10-18! ��������� ������������ � ���� "..block_number())
        assistWindow[0] = false
    end
    
    if imgui.Button(u8'�������� � ����� (10-66)', imgui.ImVec2(-1, 50)) then
        sampSendChat("/r 10-66! ���� � ����� "..block_number().."!")
        assistWindow[0] = false
    end
    
    if imgui.Button(u8'����� ������������ (10-77)', imgui.ImVec2(-1, 50)) then
        sampSendChat("/r 10-77! ����� �� ����� "..block_number().."!")
        assistWindow[0] = false
    end
    
    imgui.PopStyleColor(2)
    
    if imgui.Button(u8'�������', imgui.ImVec2(-1, 30)) then
        assistWindow[0] = false
    end
    
    imgui.End()
end)
