#
# API function goes here, to be called by the
# skill-actions:
#
function doIrrigation(ip, duration, repeats)

    @async spawnIrrigation(ip, duration, repeats)
end


function spawnIrrigation(ip, duration, repeats)

    Snips.printDebug("spawnIrrigation() started")

    sleeptime = duration * 60
    for i in (1:repeats)
        if Snips.switchShelly1(ip, :timer; timer = sleeptime)
            Snips.printLog("Irrigation started for $i of $repeats repeats")
        else
            Snips.printLog("cloud not start irrigation with device at $ip")
            Snips.publishSay(:error_on)
        end
        sleep(sleeptime)
        # Snips.switchShelly1(ip, :off)
        Snips.printLog("Irrigation stopped for $i of $repeats repeats")
        sleep(sleeptime)
    end
end
