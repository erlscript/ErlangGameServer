-module(connector_app).
-behaviour(application).

-include("connector.hrl").

-export([start/2, stop/1]).

start(_Type, _StartArgs) ->
    {ok,[[PortString]]} = init:get_argument(port),
    Port = erlang:list_to_integer(PortString),
    case ranch:start_listener(connector, 
                                   2000, 
                                   ranch_tcp, 
                                   [{port,Port},{active, once}, {packet,2},{reuseaddr,true}], 
                                   connector, 
                                   []) of
        {ok,_ } -> pass;
        {error, {already_started, _}} -> pass;
        RanchError -> error_logger:error_msg("Cannot start ranch with Error: ~p",RanchError)
    end,
    case connector_sup:start_link() of
        {ok, Pid} ->
            error_logger:info_msg("Connector started on node ~p, listening on port ~p", [erlang:node(),Port]),
            {ok, Pid};
        Error ->
            Error
    end.

stop(State) ->
    error_logger:info_msg( "Connector stopped at node ~p", [erlang:node()]),
    State.


