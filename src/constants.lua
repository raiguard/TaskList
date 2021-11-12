local constants = {}

constants.task_status = {
  not_started = { color = "red", label = { "gui.tlst-status-not-started" }, index = 1 },
  in_progress_low = { color = "yellow", label = { "gui.tlst-status-in-progress-low" }, index = 2 },
  in_progress_high = { color = "green", label = { "gui.tlst-status-in-progress-high" }, index = 3 },
}

return constants
