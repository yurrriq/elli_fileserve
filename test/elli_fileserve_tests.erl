-module(elli_fileserve_tests).
-include_lib("eunit/include/eunit.hrl").

-define(TEST_DIR, (filename:absname(<<".">>))).
-define(TEST_FILE, (filename:basename(list_to_binary(?FILE)))).

handle_test() ->
    meck:new(elli_request),
    lists:foreach(fun test_for_prefix/1,
                  [<<"/prefix">>, <<"/prefix/">>, {regex, <<"^/p.+x/">>}]),
    lists:foreach(fun test_for_regex_prefix/1,
                  [<<".+/assets">>, <<".+/assets/">>, <<"/[^/]+/[^/]+/assets/">>]),
    meck:unload(elli_request).

test_for_prefix(Prefix) ->
    Config = [{path, ?TEST_DIR}, {prefix, Prefix}],

    meck:expect(elli_request, raw_path, 1, <<"/prefix/../file.ext">>),
    ?assertEqual({403, [], <<"Not Allowed">>}, elli_fileserve:handle(req, Config)),

    meck:expect(elli_request, raw_path, 1, <<"/prefix/non-existing-file.ext">>),
    ?assertEqual({404, [], <<"File Not Found">>}, elli_fileserve:handle(req, Config)),

    meck:expect(elli_request, raw_path, 1, <<"/prefix/", ?TEST_FILE/binary>>),
    ExpectedFile = filename:join([?TEST_DIR, ?TEST_FILE]),
    ?assertMatch({200, [{"Content-Length", _}], {file, ExpectedFile}},
                 elli_fileserve:handle(req, Config)),

    meck:expect(elli_request, raw_path, 1, <<"/other/prefix/file.ext">>),
    ?assertEqual(ignore, elli_fileserve:handle(req, Config)).


test_for_regex_prefix(Prefix) ->
    Config = [{path, ?TEST_DIR}, {prefix, {regex, Prefix}}],

    meck:expect(elli_request, raw_path, 1, <<"/deep/link/assets/", ?TEST_FILE/binary>>),
    ExpectedFile = filename:join([?TEST_DIR, ?TEST_FILE]),
    ?assertMatch({200, [{"Content-Length", _}], {file, ExpectedFile}},
                 elli_fileserve:handle(req, Config)).

mime_type_test() ->
    ?assertEqual("text/plain", elli_fileserve:mime_type(<<"/some/file.txt">>)),
    ?assertEqual(undefined, elli_fileserve:mime_type(<<"/no/file/extension">>)).


local_path_test_() ->
    [{"Should return file asked for",
      ?_assertEqual(<<"/test/css/main.css">>,
                    elli_fileserve:local_path([{path, <<"/test">>}],
                                              <<"css/main.css">>))},
     {"Should return default file on empty path",
      ?_assertEqual(<<"/test/index.xhtml">>,
                    elli_fileserve:local_path([{path, <<"/test">>},
                                               {default, <<"index.xhtml">>}],
                                              <<"">>))},
     {"Should return default file if asked for directory",
      ?_assertEqual(<<"/test/static/index.xhtml">>,
                    elli_fileserve:local_path([{path, <<"/test">>},
                                               {default, <<"index.xhtml">>}],
                                              <<"static/">>))},
     {"Should not allow 'parent directories' in path",
      ?_assertEqual(undefined,
                    elli_fileserve:local_path([{path, <<"/test/">>},
                                               {default, <<"index.xhtml">>}],
                                              <<"../">>))}].
