-- 在公司时自动连接手机热点

local companyLocation = {
	latitude=34.644073486328,
	longitude=112.36500898008
}
local state = {
	lastRegion = nil
}

function setupLocations()
	hs.location.start()
    locationWatcher = hs.location.new()
	local regionsMap = {
		work = {
			latitude = companyLocation.latitude,
			longitude = companyLocation.longitude,
			radius = 100,
			notifyOnEntry = true,
			notifyOnExit = true,
			action = function()
				hs.alert("Welcome to company")
			end,
			exitAction = function()
				hs.alert("leave company")
			end
		}
	}
	-- local regions = {}
    -- for k, v in pairs(regionsMap) do
    --     v.identifier = k
    --     local region = v
    --     --region.action = nil
    --     table.insert(regions, region)
    -- end
	local statusActions = {
		didUpdateLocations = function(loc, locations, _)
            local region = locationWatcher:currentRegion()
            if(region ~= nil and region ~= state.lastRegion) then
                if(state.lastRegion ~= nil) then
                    hs.notify.show("Moved from " .. state.lastRegion .. " to " .. region, "", "")
                else
                    print("Starting location is " .. region, "", "")
                end
                regionsMap[region]["action"]()
                state.lastRegion = region
            end
        end,
		didChangeAuthorizationStatus = function(_, status, _)
            if(status ~= "authorized") then
                print("Location auth status: " .. status, "", "")
            end
        end,

        didStartMonitoringForRegion = function(loc, newRegion, _)
            print("Monitoring started for region " .. newRegion.identifier)
        end,

        didEnterRegion = function(loc, region, _)
            if (region.identifier ~= state.lastRegion) then
                hs.notify.show("Entered " .. region.identifier .. " from " .. state.lastRegion, "", "")
                regionsMap[region.identifier]["action"]()
                state.lastRegion = region.identifier
            end
        end,

        didExitRegion = function(loc, region, _)
            print("Left " .. region.identifier)
            local exitAction = regionsMap[region.identifier]["exitAction"]
            if(exitAction ~= nil) then
                exitAction()
            end
        end,

        monitoringDidFailForRegion = function(_, region, errorMsg)
            print("Monitoring failed for region " .. region.identifier, "", errorMsg)
        end,

        didFailWithError = function(_, errorMsg, _)
            print("Monitoring failed with error", "", errorMsg)
        end,
	}
	function watchLocation(loc, status, x, y)
        local action = statusActions[status]
        if(action ~= nil) then
            action(loc, x, y)
        else
            hs.alert(status)
        end
    end

    locationWatcher:callback(watchLocation)
    for _, m in pairs(regionsMap) do
        locationWatcher:addMonitoredRegion(m)
    end
    locationWatcher:startTracking()
end
setupLocations()

function connectHotspots()
		print("connectHotspots")
end

function disconnectHotspots()
	print("disconnectHotspots")
end

function caffeinateCallback(eventType)
	if (eventType == hs.caffeinate.watcher.screensDidSleep) then
		print("screensDidSleep")
	elseif (eventType == hs.caffeinate.watcher.screensDidWake) then
		print("screensDidWake")
	elseif (eventType == hs.caffeinate.watcher.screensDidLock) then
		print("screensDidLock")
		disconnectHotspots()
		--hs.audiodevice.defaultOutputDevice():setVolume(0)
	elseif (eventType == hs.caffeinate.watcher.screensDidUnlock) then
		print("screensDidUnlock")
		connectHotspots()
		--hs.audiodevice.defaultOutputDevice():setVolume(25)
	end
end

caffeinateWatcher = hs.caffeinate.watcher.new(caffeinateCallback)
caffeinateWatcher:start()

