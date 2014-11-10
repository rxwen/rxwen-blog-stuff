enable_debug = true
function debug_message(msg,title,log_type)
    if not enable_debug then
        return
    end
    log_type = log_type or "notify-send"
    title = title or "awesome_debugging"
    if log_type == "syslog" then
        io.popen('printf "'..string.gsub(msg,'["]','\\%1')..'" | logger')
    elseif log_type == "notify-send" then
        io.popen('notify-send "awesome debug" "'
            ..string.gsub(msg,'["]','\\%1')..'"')
    else
        io.popen('notify-send "awesome debug" "'
            ..log_type..' is not a known log method"')
    end
end
