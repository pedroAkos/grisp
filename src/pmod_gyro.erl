-module(pmod_gyro).

-behaviour(gen_server).

% API
-export([start_link/1]).

% Callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([code_change/3]).
-export([terminate/2]).

-include("pmod_gyro.hrl").

%--- API -----------------------------------------------------------------------

start_link(Slot) ->
    gen_server:start_link(?MODULE, Slot, []).

%--- Callbacks -----------------------------------------------------------------

init(Slot) ->
    verify_device(Slot),
    {ok, Slot}.

handle_call(Request, From, _State) -> error({unknown_request, Request, From}).

handle_cast(Request, _State) -> error({unknown_cast, Request}).

handle_info(Info, _State) -> error({unknown_info, Info}).

code_change(_OldVsn, State, _Extra) -> {ok, State}.

terminate(_Reason, _State) -> ok.

%--- Internal ------------------------------------------------------------------

verify_device(Slot) ->
    case grisp_spi:send_recv(Slot, <<?RW_READ:1, ?MS_SAME:1, ?WHO_AM_I:6>>, 1, 1) of
        <<?DEVID>> -> ok;
        Other      -> error({device_mismatch, {who_am_i, Other}})
    end.
