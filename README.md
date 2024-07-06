# GrandMA2 Speed Master to Resolume Speed and BPM Sync
This MA2 plugin is designed to sync the value of a GrandMA2 SpeedMaster to Resolume as Speedmaster and as BPM.
The plugin was developed to always keep the Resolume visuals and effects (which rely on the Resolume BPM rather) in sync with the effects running on MA.


## Installation:
### 1) Copy files to the MA2 Plugin directory
download and copy the files:
- ResolumeSpeedAndBBPMSync.xml
- ResolumeSpeedAndBBPMSync.lua

from this repository into the plugin directory (e.g., on a USB-Drive: gma2/plugins/)

### 2) Prepare fixtures and Resolume
Follow the [Resolume Guide](https://resolume.com/support/en/dmx-shortcuts) to set up DMX Input and DMX shortcuts in Resolume.

In MA2, add fixtures to your patch and map it according to the Resolume guide above:
|Name|FixtureType|Resolume Function|Note|
| -------- | ------- | -------- | ------- |
|resolumeSpeedMaster|Generic Dimmer|Composition Speed ("S" Slider in header)||
|resolumeBPM|Generic Dimmer 16 bit|Composition Tempocontroller Tempo(BPM)|check "16-bit" and specify range to be from 20 to 500|

### 3) Import and configure plugin
Right click in a empty plugin slot in the Plugin pool in MA2 -> import -> select ResolumeSpeedAndBBPMSync

After importing, adjust the variables in the Configuration block.
```
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
```

Enable "Execute on Load", press Save, exit the Plugin and call the plugin from the pool.

### 4) Create trigger
I like to have the possibility to enable/disable the sync; therefore, therefor the plugin is not starting automatically.
To start the plugin, execute the command:
```
LUA "startResolumeSpeedSync()"
```
To stop the plugin, execute:
```
LUA "StopResolumeSpeedSync = true"
```

I just created a executor button with 2 empty cues and setting the above commands as cmd for the cues.


