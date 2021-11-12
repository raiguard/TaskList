local constants = {}

constants.task_status = {
  not_started = { color = "black", label = { "gui.tlst-status-not-started" } },
  in_progress_high = { color = "green", label = { "gui.tlst-status-in-progress-high" } },
  in_progress_low = { color = "yellow", label = { "gui.tlst-status-in-progress-low" } },
  paused = { color = "red", label = { "gui.tlst-status-paused" } },
}
local i = 0
for _, status_info in pairs(constants.task_status) do
  i = i + 1
  status_info.index = i
end

return constants
