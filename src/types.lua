-- This file is never required by anything, and exists purely for the language server to determine types

-- This is just a typedef, think of it like a struct
global = {
  next_task_id = 1,
  --- @type PlayerTable[]
  players = {},
  --- @type table<number, Task>
  tasks = {},
}

--- @class PlayerTable
--- @field flags table<string, boolean>
--- @field guis table
