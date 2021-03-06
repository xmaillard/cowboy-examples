-module(upload_handler).
-export([init/3, handle/2, terminate/2]).

init({tcp, http}, Req, _Opts) ->
    {ok, Req, undefined_state}.

handle(Req, State) ->
    {Result, Req2} = acc_multipart(Req, []),
    io:format("~p", [Result]),
    {ok, Req3} = cowboy_http_req:reply(200, [], term_to_binary(Result), Req2),
    {ok, Req3, State}.

terminate(_Req, _State) ->
    ok.

acc_multipart(Req, Acc) ->
    {Result, Req2} = cowboy_http_req:multipart_data(Req),
    acc_multipart(Req2, Acc, Result).

acc_multipart(Req, Acc, {headers, Headers}) ->
    acc_multipart(Req, [{Headers, []}|Acc]);
acc_multipart(Req, [{Headers, BodyAcc}|Acc], {body, Data}) ->
    acc_multipart(Req, [{Headers, [Data|BodyAcc]}|Acc]);
acc_multipart(Req, [{Headers, BodyAcc}|Acc], end_of_part) ->
    acc_multipart(Req, [{Headers, list_to_binary(lists:reverse(BodyAcc))}|Acc]);
acc_multipart(Req, Acc, eof) ->
    {lists:reverse(Acc), Req}.
