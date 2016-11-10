

# elli_fileserve #

[![Build Status](https://travis-ci.org/elli-lib/elli_fileserve.svg?branch=master)](https://travis-ci.org/elli-lib/elli_fileserve)

*[`elli`][] middleware to serve static files.*

This middleware allows you to serve static files with [`elli`][] by mapping a
prefix to a local folder on your server. A prefix can be of arbritrary length,
the following are all valid prefixes: `<<"/">>`, `<<"/prefix">>`,
`<<"/some/longer/prefix/">>`, etc.

~~You can also drop in your own MIME/content types
by editing `priv/mime.types` before compiling.~~

Example config for serving local files in `/tmp` under `/prefix`, e.g.
`GET /prefix/some/file.txt` will serve `/tmp/some/file.txt`.

[`elli`]: https://github.com/knutin/elli

```erlang


-module(my_elli_stuff).
-export([start_link/0]).

start_link() ->
    FileserveConfig = [{prefix, <<"/prefix">>},
                       {path, <<"/tmp">>},
                       {charset, "utf-8"}],

    Config = [{mods, [{elli_fileserve, FileserveConfig}]}],

    elli:start_link([{callback, elli_middleware},
                     {callback_args, Config}]).


```


### <a name="Dynamic_prefixes_using_regex">Dynamic prefixes using regex</a> ###

If your prefix is dynamic, use regular expressions to match it. The following
example matches all pathes that contain `/assets` somewhere.

```erlang


FileserveConfig = [{prefix, {regex, <<".+/assets">>}},
                   {path, <<"/www">>}],


```
Resolves to:


<table><tr><th>Path</th><th>Result</th></tr><tr><td><code>/foo/assets/file.zip</code></td><td><code>/www/file.zip</code></td></tr><tr><td><code>/bar/assets/file.zip</code></td><td><code>/www/file.zip</code></td></tr><tr><td><code>/assets/file.zip</code></td><td><code>ignore</code></td></tr>
</table>



### <a name="TODO">TODO</a> ###
- Serve `index.html?` files for request paths ending with `/`, if available.
- Support file listing.


## Modules ##


<table width="100%" border="0" summary="list of modules">
<tr><td><a href="elli_fileserve.md" class="module">elli_fileserve</a></td></tr></table>
