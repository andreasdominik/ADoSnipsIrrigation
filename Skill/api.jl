#
# API function goes here, to be called by the
# skill-actions:
#

IRRIGATION_STATUS = :off

function doIrrigation(ip, duration, repeats)

    global IRRIGATION_STATUS = :on
    @async spawnIrrigation(ip, duration, repeats)
end


function spawnIrrigation(ip, duration, repeats)

    Snips.printDebug("spawnIrrigation() started")
    Snips.printDebug("repeats: $repeats, duration: $duration, STATUS: $IRRIGATION_STATUS")

    sleeptime = duration * 60
    i = 0
    while (i < repeats) && (IRRIGATION_STATUS == :on)
        i += 1

        if Snips.switchShelly1(ip, :timer; timer = sleeptime)
            Snips.printLog("Irrigation started for $i of $repeats repeats")
        else
            Snips.printLog("cloud not start irrigation with device at $ip")
            Snips.publishSay(:error_on)
        end
        sleep(sleeptime)
        Snips.switchShelly1(ip, :off)
        Snips.printLog("Irrigation stopped for $i of $repeats repeats")
        sleep(sleeptime)
    end
end

function endIrrigation(ip)

    Snips.switchShelly1(ip, :off)
    global IRRIGATION_STATUS = :off
    Snips.printLog("Irrigation stopped by command!")
end
