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
    Snips.printLog("action waterAction() started by ON/OFF intent.")

    # ignore, if not responsible (other device):
    #
    onoff = Snips.isOnOffMatched(payload, DEVICE_NAME, siteId = "any")
    if !(onoff in [:on, :off])
        return false
    end


    msg = :dunno
    if onoff == :on
        msg = runWaterActionOn()
    else
        msg = runWaterActionOff()
    end
    Snips.publishEndSession(msg)
    return false
end



"""
function waterOnAction(topic, payload)

    Switch on irrigation.
"""
function waterOnAction(topic, payload)

    # log:
    Snips.printLog("action waterOnAction() started.")

    msg = runWaterActionOn()
    Snips.publishEndSession(msg)
    return false
end


"""
function waterOffAction(topic, payload)

    Switch off irrigation.
"""
function waterOffAction(topic, payload)

    # log:
    Snips.printLog("action waterOffAction() started.")

    msg = runWaterActionOff()
    Snips.publishEndSession(msg)
    return false
end


function runWaterActionOn()

    # re-read the config.ini (in case params have changed):
    #
    Snips.readConfig("$APP_DIR")

    if !checkAllConfig()
        return :error_ini
    end

    durations = [parse(Int,x) for x in Snips.getConfig(INI_DURATION)]
    offs = parse(Int, Snips.getConfig(INI_OFF))
    ip = Snips.getConfig(INI_SHELLY)

    doIrrigation(ip, durations, offs)
    msg = Snips.langText(:start_irrigation)
    msg = "$msg $(length(durations)) $(Snips.langText(:rounds)):"
    for (i, minutes) in enumerate(durations)
        Snips.printDebug("$i of $(length(durations))")
        if i == length(durations)
            msg = "$msg $(Snips.langText(:and)) "
        end
        msg = "$msg $minutes  $(Snips.langText(:minutes))"
    end

    return msg
end

function runWaterActionOff()

    if !checkAllConfig()
        return :error_ini
    end

    ip = Snips.getConfig(INI_SHELLY)
    endIrrigation(ip)

    return :end_irrigation
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

    durations = [parse(Int,x) for x in Snips.getConfig(INI_DURATION)]
    offs = parse(Int, Snips.getConfig(INI_OFF))
    ip = Snips.getConfig(INI_SHELLY)

    Snips.printDebug("Irrigation sequence started!")
    if command == "start"
        doIrrigation(ip, durations, offs)
    elseif command == "end"
        endIrrigation(ip)
    else
        Snips.printLog("ERROR: Unknown command for triggerIrrigation: $command")
    end

    return false
end


function checkAllConfig()

    return Snips.isInConfig(Symbol(INI_DURATION)) &&
           Snips.isConfigValid(INI_OFF, regex = r"[0-9]+") &&
           Snips.isConfigValid(INI_SHELLY)
end
