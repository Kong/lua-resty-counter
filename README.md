Name
====

lua-resty-counter - Lock-free counter for OpenResty.

![Build Status](https://travis-ci.com/kong/lua-resty-counter.svg?branch=master) ![luarocks](https://img.shields.io/luarocks/v/kong/lua-resty-counter?color=%232c3e67)

Table of Contents
=================

- [Description](#description)
- [Status](#status)
- [API](#api)
- [TODO](#todo)
- [Copyright and License](#copyright-and-license)
- [See Also](#see-also)


Description
===========

When number of workers increase, the penalty of acquiring a lock becomes noticable.
This library implements a lock-free counter that does incrementing operation in worker's Lua VM.
Each worker then sync its local counter to a shared dict timely.


[Back to TOC](#table-of-contents)

Status
========

Production

API
========

## counter.new

**syntax**: *c, err = counter.new(shdict_name, sync_interval?, init_ttl?)*

Create a new counter instance. Take first argument as the shared dict name in
string. And an optional second argument as interval to sync local state to
shared dict in number. If second argument is omitted, local counter will not be
synced automatically, user are responsible to call `counter:sync` on each worker.
The optional init_ttl argument specifies expiration time (in seconds) of the value
since the time it is initialized. The time resolution is 0.001 seconds. If init_ttl
takes the value 0 (which is the default), then the item will never expire.

[Back to TOC](#table-of-contents)

## counter.sync

**syntax**: *ok = counter:sync()*

Sync current worker's local counter to shared dict. Not needed if a counter is
created with `sync_interval` not set to `nil`.

[Back to TOC](#table-of-contents)

## counter.incr

**syntax**: *counter:incr(key, step?)*

Increase counter of key `k` with a step of `step`. If `step` is omitted, it's
default to `1`.

[Back to TOC](#table-of-contents)

## counter.reset

**syntax**: *newval, err, forcible? = counter:reset(key, number, init_ttl?)*

Reset the counter in shdict with a decrease of `number`. This function is a wrapper of
`ngx.shared.DICT:incr(key, -number, number, init_ttl)`, please refer to
[lua-nginx-module doc](https://github.com/openresty/lua-nginx-module#ngxshareddictincr)
for return values.

[Back to TOC](#table-of-contents)

## counter.get

**syntax**: *value = counter:get(key)*

Get the value of counter from shared dict.

[Back to TOC](#table-of-contents)

## counter.get_keys

**syntax**: *keys = counter:get_keys(max_count?)*

Get the keys of counters in shared dict. This function is a wrapper of
`ngx.shared.DICT:get_keys`, please refer to
[lua-nginx-module doc](https://github.com/openresty/lua-nginx-module#ngxshareddictget_keys)
for return values.

[Back to TOC](#table-of-contents)


TODO
====

[Back to TOC](#table-of-contents)


Copyright and License
=====================

This module is licensed under the Apache 2.0 license.

Copyright (C) 2019, Kong Inc.

All rights reserved.

[Back to TOC](#table-of-contents)

See Also
========
* [lua-nginx-module](https://github.com/openresty/lua-nginx-module)

[Back to TOC](#table-of-contents)
