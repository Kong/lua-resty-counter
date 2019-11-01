# vim:set ft= ts=4 sw=4 et fdm=marker:

use Test::Nginx::Socket::Lua 'no_plan';
use Cwd qw(cwd);


my $pwd = cwd();

our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;$pwd/lib/?/init.lua;;";
    lua_shared_dict counters 1M;
};

workers(4);
run_tests();

__DATA__
=== TEST 1: Sync counter
--- http_config eval: $::HttpConfig
--- config
    location =/t {
        content_by_lua_block {
            local counter = require("resty.counter")
            local c = counter.new("counters", 0.01)
            c:incr("key1")
            ngx.sleep(0.02)
            local v, err = c:get("key1")
            ngx.say(v)
            if err then
                ngx.log(ngx.ERR, err)
            end
        }
    }
--- request
    GET /t
--- response_body_like
1
--- no_error_log
[error]

=== TEST 2: Sync counter
--- http_config eval: $::HttpConfig
--- config
    location =/t {
        content_by_lua_block {
            local counter = require("resty.counter")
            local c = counter.new("counters", 0.01)
            c:incr("key1")
            res = ngx.location.capture("/t2")
            ngx.say(res.status)
            res = ngx.location.capture("/t2")
            ngx.say(res.status)
            res = ngx.location.capture("/t2")
            ngx.say(res.status)
            ngx.sleep(0.02)
            local v, err = c:get("key1")
            ngx.say(v)
            if err then
                ngx.log(ngx.ERR, err)
            end
        }
    }
    location /t2 {
        content_by_lua_block {
            local counter = require("resty.counter")
            local c = counter.new("counters", 0.01)
            c:incr("key1")
            
        }
    }
--- request
    GET /t
--- response_body_like
200
200
200
4
--- no_error_log
[error]

=== TEST 3: Reset counter
--- http_config eval: $::HttpConfig
--- config
    location =/t {
        content_by_lua_block {
            local counter = require("resty.counter")
            local c = counter.new("counters", 0.01)
            c:incr("key3")
            ngx.sleep(0.02)
            c:reset("key3", 1)
            ngx.sleep(0.02)
            local v, err = c:get("key3")
            ngx.say(v)
            if err then
                ngx.log(ngx.ERR, err)
            end
        }
    }
--- request
    GET /t
--- response_body_like
0
--- no_error_log
[error]

=== TEST 3: Reset counter and start counting again
--- http_config eval: $::HttpConfig
--- config
    location =/t {
        content_by_lua_block {
            local counter = require("resty.counter")
            local c = counter.new("counters", 0.01)
            c:incr("key3")
            ngx.sleep(0.01)
            c:reset("key3", 1)
            ngx.sleep(0.01)
            c:incr("key3")
            ngx.sleep(0.01)
            local v, err = c:get("key3")
            ngx.say(v)
            if err then
                ngx.log(ngx.ERR, err)
            end
        }
    }
--- request
    GET /t
--- response_body_like
1
--- no_error_log
[error]


=== TEST 4: Manually sync counter
--- http_config eval: $::HttpConfig
--- config
    location =/t {
        content_by_lua_block {
            local counter = require("resty.counter")
            local c = counter.new("counters")
            c:incr("key3")
            ngx.sleep(0.01)
            local v, err = c:get("key3")
            ngx.say(v)
            if err then
                ngx.log(ngx.ERR, err)
            end
            local ok = c:sync()
            ngx.say(ok)
            local v, err = c:get("key3")
            ngx.say(v)
            if err then
                ngx.log(ngx.ERR, err)
            end
        }
    }
--- request
    GET /t
--- response_body_like
nil
true
1
--- no_error_log
[error]