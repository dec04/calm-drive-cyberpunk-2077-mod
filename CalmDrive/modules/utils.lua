miscUtils = {}

function miscUtils.deepcopy(origin)
	local orig_type = type(origin)
    local copy
    if orig_type == 'table' then
        copy = {}
        for origin_key, origin_value in next, origin, nil do
            copy[miscUtils.deepcopy(origin_key)] = miscUtils.deepcopy(origin_value)
        end
        setmetatable(copy, miscUtils.deepcopy(getmetatable(origin)))
    else
        copy = origin
    end
    return copy
end

function miscUtils.distanceVector(from, to)
    return math.sqrt((to.x - from.x)^2 + (to.y - from.y)^2 + (to.z - from.z)^2)
end

function miscUtils.indexValue(table, value)
    local index={}
    for k,v in pairs(table) do
        index[v]=k
    end
    return index[value]
end

function miscUtils.has_value(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function miscUtils.getIndex(tab, val)
    local index = nil
    for i, v in ipairs(tab) do
		if v == val then
			index = i
		end
    end
    return index
end

function miscUtils.removeItem(tab, val)
    table.remove(tab, miscUtils.getIndex(tab, val))
end

function miscUtils.isSameInstance(a, b)
    if a == nil or b == nil then return false end
	return Game['OperatorEqual;IScriptableIScriptable;Bool'](a, b)
end

function miscUtils.showNewContact(journalQ, title, name, duration)
    local notificationData = gameuiGenericNotificationData.new()

    local userData = QuestUpdateNotificationViewData.new()
    userData.title = title
    userData.text = name
    userData.animation = "notification_newContactAdded"
    userData.soundEvent = "QuestUpdatePopup"
    userData.soundAction = "OnOpen"
    notificationData.time = duration
    notificationData.widgetLibraryItemName = "notification_NewContactAdded"
    notificationData.notificationData = userData
    journalQ:AddNewNotificationData(notificationData)
end

function miscUtils.spendMoney(amount)
    local tdbid = TweakDBID.new("Items.money")
    local moneyId = gameItemID.FromTDBID(tdbid)
    Game.GetTransactionSystem():RemoveItem(Game.GetPlayer(), moneyId, amount)
end

function miscUtils.payBribe(pm)
    local stars = EnumInt(Game.GetScriptableSystemsContainer():Get("PreventionSystem"):GetHeatStage())
    if stars == 1 then
        miscUtils.spendMoney(pm.settings.price1)
    elseif stars == 2 then
        miscUtils.spendMoney(pm.settings.price2)
    elseif stars == 3 then
        miscUtils.spendMoney(pm.settings.price3)
    elseif stars == 4 then
        miscUtils.spendMoney(pm.settings.price4)
    end
end

function miscUtils.disablePrevention()
    local this = Game.GetScriptableSystemsContainer():Get("PreventionSystem")

    if not this:IsChasingPlayer() then
        return
    end
    this.systemDisabled = false
    this:WhipeBlinkData()
    this:ChangeAgentsAttitude(EAIAttitude.AIA_Neutral)
    this:WakeUpAllAgents(false)
    this:WhipeHitNPC()
    this:DespawnAllPolice()
    this:RemovePlayerFromSecuritySystemBlacklist()
    this:CancelAllDelayedEvents()
    this.isHidingFromPolice = false
    this.generalPercent = 0
    if this:SetHeatStage(EPreventionHeatStage.Heat_0) then
        this:OnHeatChanged()
    end
    for _, veh in ipairs(this.vehicles) do
        if this:IsVehicleValid(veh) then
            Game.GetPreventionSpawnSystem():JoinTraffic(veh)
        end
    end

    local playergroup = Game.GetPlayer():GetAttitudeAgent():GetAttitudeGroup()
    Game.GetAttitudeSystem():SetAttitudeGroupRelationPersistent("police", playergroup, EAIAttitude.AIA_Neutral)
end

return miscUtils