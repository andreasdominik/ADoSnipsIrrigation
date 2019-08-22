#
# API function goes here, to be called by the
# skill-actions:
#

IRRIGATION_STATUS = :off

function doIrrigation(ip, durations, offs)

    global IRRIGATION_STATUS = :on
    @async spawnIrrigation(ip, durations, offs)
end


function spawnIrrigation(ip, durations, offs)

    Snips.printDebug("spawnIrrigation() started")
    Snips.printDebug("offs: $offs, durations: $durations, STATUS: $IRRIGATION_STATUS")

    for duration in durations
        if IRRIGATION_STATUS == :on
            if Snips.switchShelly1(ip, :on)
                Snips.printLog("Irrigation started for $duration minutes")
                sleep(duration * 60)
                Snips.switchShelly1(ip, :off)
                Snips.printLog("Irrigation stopped")
            else
                Snips.printLog("cloud not start irrigation with device at $ip")
                Snips.publishSay(:error_on)
            end
            sleep(offs * 60)
        end
    end
end

function endIrrigation(ip)

    Snips.switchShelly1(ip, :off)
    global IRRIGATION_STATUS = :off
    Snips.printLog("Irrigation stopped by command!")
end
