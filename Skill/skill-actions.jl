#
# actions called by the main callback()
# provide one function for each intent, defined in the Snips Console.
#
# ... and link the function with the intent name as shown in config.jl
#
# The functions will be called by the main callback function with
# 2 arguments:
# * MQTT-Topic as String
# * MQTT-Payload (The JSON part) as a nested dictionary, with all keys
#   as Symbols (Julia-style)
#
"""
function waterAction(topic, payload)

    Switch on irrigation.
"""
function waterAction(topic, payload)

    # log:
    Snips.printLog("action waterAction() started.")

    # ignore, if not responsible (other device):
    #
    onoff = Snips.isOnOffMatched(payload, DEVICE_NAME, siteId = "any")
    if !(onoff in [:on, :off])
        return false
    end


    # ROOMs are not yet supported -> only ONE Fire  in assistent possible.
    #
    # get my name from config.ini:
    #
    if !Snips.isConfigValid(INI_DURATION, regex = r"[0-9]+") ||
        !Snips.isConfigValid(INI_REPEATS, regex = r"[0-9]+") ||
        !Snips.isConfigValid(INI_SHELLY)
        Snips.publishEndSession(:error_ini)
        return true
    end

    duration = parse(Int, Snips.getConfig(INI_DURATION))
    repeats = parse(Int, Snips.getConfig(INI_REPEATS))
    ip = Snips.getConfig(INI_SHELLY)

    if onoff == :on
        doIrrigation(ip, duration, repeats)
        Snips.publishEndSession(""" $(Snips.langText(:start_irrigation)) $repeats $(Snips.langText(:times)) $duration $(Snips.langText(:minutes))""")
    else
        endIrrigation(ip)
        Snips.publishEndSession(:end_irrigation)
    end

    return true
end
