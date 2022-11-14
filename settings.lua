data:extend({
  {
    type = "bool-setting",
    name = "tlst-new-task-on-confirm",
    setting_type = "runtime-per-user",
    default_value = false,
  },
  {
    type = "string-setting",
    name = "tlst-show-active-task",
    setting_type = "runtime-per-user",
    allowed_values = { "off", "force", "private" },
    default_value = "off",
  },
  {
    type = "bool-setting",
    name = "tlst-new-tasks-in-progress",
    setting_type = "runtime-per-user",
    default_value = false,
  },
  { type = "bool-setting", name = "tlst-new-tasks-at-top", setting_type = "runtime-per-user", default_value = false },
})
