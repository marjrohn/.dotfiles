require("git"):setup()

if os.execute('ps -a | grep nvim') then
	require("no-status"):setup()
else
	require("full-border"):setup()

	function Status:name()
		local h = self._current.hovered
		if not h then
			return ""
		end

		local linked = ""
		if h.link_to ~= nil then
			linked = "  " .. tostring(h.link_to)
		end

		return " " .. h.name:gsub("\r", "?", 1) .. linked
	end
end
