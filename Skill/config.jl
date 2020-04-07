# DO NOT CHANGE THE FOLLOWING 3 LINES UNLESS YOU KNOW
# WHAT YOU ARE DOING!
# set CONTINUE_WO_HOTWORD to true to be able to chain
# commands without need of a hotword in between:
#
const CONTINUE_WO_HOTWORD = true
const DEVELOPER_NAME = "andreasdominik"
Snips.setDeveloperName(DEVELOPER_NAME)
Snips.setModule(@__MODULE__)

#
# language settings:
# Snips.LANG in QnD(Snips) is defined from susi.toml or set
# to "en" if no susi.toml found.
# This will override LANG by config.ini if a key "language"
# is defined locally:
#
if Snips.isConfigValid(:language)
    Snips.setLanguage(Snips.getConfig(:language))
end
# or LANG can be set manually here:
# Snips.setLanguage("fr")
#
# set a local const with LANG:
#
const LANG = Snips.getLanguage()
#
# END OF DO-NOT-CHANGE.


# Slots:
# Name of slots to be extracted from intents:
#
const SLOT_DEVICE = "device"
const DEVICE_NAME = "irrigation"

# name of entry in config.ini:
#
const INI_DURATION = "duration"
const INI_OFF = "off_time"
const INI_SHELLY = "ip"

Snips.registerIntentAction("ADoSnipsOnOff", waterAction)
Snips.registerIntentAction("IrrigationOn", waterOnAction)
Snips.registerIntentAction("IrrigationOff", waterOffAction)
Snips.registerTriggerAction("ADoSnipsIrrigation", triggerIrrigation)
