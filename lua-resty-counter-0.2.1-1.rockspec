package = "lua-resty-counter"
version = "0.2.1-1"
source = {
   url = "git+https://github.com/Kong/lua-resty-counter.git",
   tag = "v0.2.1"
}
description = {
   summary = "lua-resty-counter - Lock-free counter for OpenResty.",
   detailed = "When number of workers increase, the penalty of acquiring a lock becomes noticable. This library implements a lock-free counter that does incrementing operation in worker's Lua VM. Each worker then sync its local counter to a shared dict timely.",
   homepage = "https://github.com/Kong/lua-resty-counter",
   license = "Apache"
}
build = {
   type = "builtin",
   modules = {
      ["resty.counter"] = "lib/resty/counter.lua"
   }
}
