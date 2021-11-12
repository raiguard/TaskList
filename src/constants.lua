local constants = {}

constants.description_color = { r = 0.8, g = 0.8, b = 0.8 }

constants.task_status = {
  not_started = { color = "black", label = { "gui.tlst-status-not-started" } },
  in_progress = { color = "green", label = { "gui.tlst-status-in-progress" } },
  in_progress_high = { color = "yellow", label = { "gui.tlst-status-in-progress-high" } },
  in_progress_critical = { color = "red", label = { "gui.tlst-status-in-progress-critical" } },
  paused = { color = "white", label = { "gui.tlst-status-paused" } },
}
local i = 0
for _, status_info in pairs(constants.task_status) do
  i = i + 1
  status_info.index = i
end

return constants
