-- Plugin: Sync BPM to resolume speedmaster and bpm
-- Author: Simon Kötting


-- Configuration block:
local speedFader = 'SpecialMaster 3.2' -- if changed, reload plugin engine to get new Handle
local resolumeBPM = '925' -- Change this to the appropriate fixture number
local resolumeSpeedMaster = '921' -- Change this to the appropriate fixture number

local speedexec = '115' -- Change this to the executor where the speed of the resolume fixtures should be stored. This executor will be created by the plugin
local speedexecpage = '18' -- Specify the page for the executor
local worldid = '42' -- Change this to set the world id, used to filter the output of the executor

local resolumeBPMFrom = 20 -- Range set in Resolume DMX Shortcut
local resolumeBPMTo = 500 -- Range set in Resolume DMX Shortcut

local executiondelay = 0.5 -- interval to check for changed Fader Value in seconds


-- Code block:
local lastBPM = -1 -- Variable to store the last BPM value
local speedmasterhandle = gma.show.getobj.handle(speedFader)

function doesNotExist(objectName)
    local handle = gma.show.getobj.handle(objectName)
    if handle ~= nil then
      return false
    else
      return true
    end
end

function initCheckExec()
    if doesNotExist('Exec ' ..speedexecpage.. '.' ..speedexec) then -- create executor if not exists
        gma.feedback('Not Exists')
        gma.cmd('BlindEdit on')
        if doesNotExist('Page ' ..speedexecpage ) then -- create page if not already exists
            gma.cmd('Store Page ' ..speedexecpage)
        end
        gma.cmd('Store Exec ' ..speedexecpage.. '.' ..speedexec)
        gma.cmd('Label Exec ' ..speedexecpage.. '.' ..speedexec.. ' "resolumespeedsync"')
        if doesNotExist('World ' ..worldid) then -- create world if not exists
            gma.cmd('Fixture ' ..resolumeBPM.. ' ' ..resolumeSpeedMaster)
            gma.cmd('Store World ' ..worldid)
            gma.cmd('Label World ' ..worldid.. ' "resolumespeed"')
        end
        gma.cmd('Assign World ' ..worldid.. ' Executor ' ..speedexecpage.. '.' ..speedexec)
        gma.cmd('Assign World ' ..worldid.. ' Sequence "resolumespeedsync"')
        gma.cmd('BlindEdit off')
    end
    gma.cmd('Go Executor ' ..speedexecpage.. '.' ..speedexec)
end

function setResolumeSpeedMaster(value)
    gma.cmd('Fixture ' .. resolumeSpeedMaster .. ' At ' .. tostring(value))
end

function setResolumeBPM(value)
    local resolumeBPMFixtureValue = -1
    if value <= resolumeBPMFrom then
        resolumeBPMFixtureValue = 0
    elseif value >= resolumeBPMTo then
        resolumeBPMFixtureValue = 255
    else
        resolumeBPMFixtureValue = (value - resolumeBPMFrom) * (100/(resolumeBPMTo - resolumeBPMFrom)) -- calculations as resolume Arena uses dmx value 0 as 20BPM - to work the range withing the DMX Shortcut Assignment have to be 20-225
    end
    gma.cmd('Fixture ' .. resolumeBPM .. ' At ' .. resolumeBPMFixtureValue)
end

function syncSpeedToResolume()
    -- Get current BPM
    local speedmasterState = gma.show.property.get(speedmasterhandle,1) -- percentage of fader (0-100)
    speedmasterState = speedmasterState:gsub('%%','')
    speedmasterState = tonumber(speedmasterState) 
    local speedmasterbpm = 225 * (speedmasterState / 100)

    -- Sync to Resolume if Value has changed
    if speedmasterbpm ~= lastBPM then
        gma.feedback('syncSpeedToResolume: Value changed')

        setResolumeSpeedMaster(speedmasterState)
        setResolumeBPM(speedmasterbpm)
        gma.cmd('Store Executor ' ..speedexecpage.. '.' ..speedexec.. ' /o')

        lastBPM = speedmasterbpm 
    end
end

function startResolumeSpeedSync()
    StopResolumeSpeedSync = false
    initCheckExec()
    while not StopResolumeSpeedSync do
        syncSpeedToResolume()
        gma.sleep(executiondelay)
    end
end
