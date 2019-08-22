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


    # re-read the config.ini (in case params have changed):
    #
    if onoff == :on
        Snips.readConfig("$APP_DIR")
    end

    # get my name from config.ini:
    #
    if !checkAllConfig()
        Snips.publishEndSession(:error_ini)
        return false
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

    return false
end




"""
    triggerIrrigation(topic, payload)

The trigger must have the following JSON format:
    {
      "target" : "qnd/trigger/andreasdominik:ADoSnipsIrrigation",
      "origin" : "ADoSnipsScheduler",
      "sessionId": "1234567890abcdef",
      "siteId" : "default",
      "time" : "timeString",
      "trigger" : {
        "command" : "start"
      }
    }

    Commands "start" or "end" will be executed with the api.
"""
function triggerIrrigation(topic, payload)

    Snips.printLog("action triggerIrrigation() started.")
    Snips.printDebug("Trigger: $payload")

    # text if trigger is complete:
    #
    payload isa Dict || return false
    haskey( payload, :trigger) || return false
    trigger = payload[:trigger]

    haskey(trigger, :command) || return false
    trigger[:command] isa AbstractString || return false
    command = trigger[:command]

    # re-read the config.ini (in case params have changed):
    #
    if command == "start"
        Snips.readConfig("$APP_DIR")
    end

    # get device params from config.ini:
    #
    if !checkAllConfig()
        Snips.printLog("ERROR: Cannot read config values for triggerIrrigation!")
        return false
    end

    duration = parse(Int, Snips.getConfig(INI_DURATION))
    repeats = parse(Int, Snips.getConfig(INI_REPEATS))
    ip = Snips.getConfig(INI_SHELLY)

    Snips.printDebug("repeats: $repeats, duration: $duration, STATUS: $IRRIGATION_STATUS")
    if command == "start"
        doIrrigation(ip, duration, repeats)
    elseif command == "end"
        endIrrigation(ip)
    else
        Snips.printLog("ERROR: Unknown command for triggerIrrigation: $command")
    end

    return false
end


function checkAllConfig()

    return Snips.isConfigValid(INI_DURATION, regex = r"[0-9]+") &
           Snips.isConfigValid(INI_REPEATS, regex = r"[0-9]+") &
           Snips.isConfigValid(INI_SHELLY)
end
