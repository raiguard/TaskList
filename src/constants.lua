local constants = {}

constants.task_status = {
  not_started = { color = "black", label = { "gui.tlst-status-not-started" } },
  in_progress_critical = { color = "red", label = { "gui.tlst-status-in-progress-critical" } },
  in_progress_high = { color = "yellow", label = { "gui.tlst-status-in-progress-high" } },
  in_progress_low = { color = "green", label = { "gui.tlst-status-in-progress-low" } },
  paused = { color = "white", label = { "gui.tlst-status-paused" } },
}
local i = 0
for _, status_info in pairs(constants.task_status) do
  i = i + 1
  status_info.index = i
end

return constants
