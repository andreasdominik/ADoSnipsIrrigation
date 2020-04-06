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

#
# link between actions and intents:
# intent is linked to action{Funktion}
# the action is only matched, if
#   * intentname matches and
#   * if the siteId matches, if site is  defined in config.ini
#     (such as: "switch TV in room abc").
#
# Language-dependent settings:
#
if LANG == "de"
    Snips.registerIntentAction("ADoSnipsOnOffDE", waterAction)
    # Snips.registerIntentAction("ADoSnipsIrrigationDE", waterAction)
else
    Snips.registerIntentAction("pleaseOnOffEN", waterAction)
end

Snips.registerTriggerAction("ADoSnipsIrrigation", triggerIrrigation)
