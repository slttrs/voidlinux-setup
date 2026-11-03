function Linemode:size_and_btime()
    local btime = math.floor(self._file.cha.btime or 0)
    local size = self._file:size()
    if btime == 0 then
        btime = ""
    elseif os.date("%Y", btime) == os.date("%Y") then
        btime = os.date("%b %d %H:%M", btime)
    else
        btime = os.date("%b %d  %Y", btime)
    end
    return string.format("%s %s", size and ya.readable_size(size) or "-", btime)
end
