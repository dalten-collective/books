/-  *books, rpc=json-rpc
/+  eth=ethereum, ethio, default-agent, dbug, books
::
|%
+$  versioned-state  
  $%  state-zero
  ==
::
+$  card  card:agent:gall
--
::
%-  agent:dbug
::
=|  state-zero
=*  state  -
::
^-  agent:gall
=<
  |_  =bowl:gall
  +*  this  .
      def   ~(. (default-agent this %|) bowl)
      bot   ~(. +> bowl)
  ++  on-init
    ^-  (quip card _this)
    =?    node-url
        =(~ node-url)
      'https://mainnet.infura.io/v3/d43cb0b443194c9e8d1ccfa41c0f7b2c'
    ::
    %-  (slog leaf+"%books-online" ~)
    `this
  ::
  ++  on-save
    ^-  vase
    !>(state)
  ::
  ++  on-load
    |=  ole=vase
    =/  old=versioned-state  !<(versioned-state ole)
    |-
    ?-    -.old
        %0  `this(state old)
    ==
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?>  =(our.bowl src.bowl)
    ?+    mark  (on-poke:def mark vase)
        %books-page
      =/  shyt=page  !<(page vase)
      =^  cards  state
        (con-page:bot shyt)
      [cards this]
    ==
  ::
  ++  on-arvo
    |=  [=wire sign=sign-arvo]
    ::~&  >  [%wire wire %sign-arvo sign]
    ?+    wire  `this
        [%iris %rpc %request ~]
      ?+    sign  `this
          [%iris %http-response *]
        ?.  ?=([%finished *] client-response.sign)  `this
        ~&  >>  response-header.client-response.sign
        ?~  fife=full-file.client-response.sign
          ((slog leaf+"%empty-rpc-data" ~) `this)
        ?.  =('application/json' type.u.fife)  `this
        ~&  >>>  ?~  mame=(de-json:html `@t`q.data.u.fife)  "no response"
                 ?.  ?=([%o p=*] u.mame)  "no object"
                 ?~  don=(~(get by `(map @t json)`p.u.mame) 'result')  "no result"
                 (parse-hex-result:rpc:eth u.don)
        ~&  >>   q.data.u.fife
        `this
      ==
    ==  
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ~&  >>>  wire
    ~&  >>  sign
    `this
  ++  on-watch  on-watch:def
  ++  on-leave  on-leave:def
  ++  on-peek   on-peek:def
  ++  on-fail   on-fail:def
  --
  ::
|_  bol=bowl:gall
++  con-page
  |=  con=page
  |^
  ?-    -.con
      %watch-wallet    (con-wal con)
      %watch-contract  (con-con con)
  ::
      %node-rpc
    %-  (slog leaf+"%books-rpc-node [%url \"{(trip node.con)}\"]")
    `state(node-url node.con)
      %send-rpc
    ~&  >>>  ^-  (list card:agent:gall)
             :~  :*  %pass  /iris/rpc/request
                     %arvo  %i  :+  %request
                       %+  light-json-request:rpc:eth
                         ?~(urp=(de-purl:html node-url) *purl:eyre u.urp)
                       (request-to-json:rpc:eth `rid.con req.con)
                     *outbound-config:iris
             ==  ==
    :_  state
    ^-  (list card:agent:gall)
    :~  :*  %pass  /iris/rpc/request
            %arvo  %i  :+  %request
              %+  light-json-request:rpc:eth
                ?~(urp=(de-purl:html node-url) *purl:eyre u.urp)
              (request-to-json:rpc:eth `rid.con req.con)
            *outbound-config:iris
    ==  ==
  ==
  ++  con-wal
    |=  con=config-wallets
    ~&  >>  con
    `state
  ++  con-con
    |=  con=config-contracts
    ^-  (quip card _state)
    ~&  >>>  con
    ?-    -.con
        %watch-contract
      ?-    -.cont.con
          %erc-20
        =;  config=config:ewe
          ~&  >>>  `card`[%pass /test/(scot %ux address.cont.con) %agent [our.bol %eth-watcher] %poke %poke !>([%watch /test/(scot %ux address.cont.con) config])]
          ~&  >>   `card`[%pass /watch/(scot %ux address.cont.con) %agent [our.bol %eth-watcher] %watch /test/(scot %ux address.cont.con)]
          :_  state
          :~  [%pass /test/(scot %ux address.cont.con) %agent [our.bol %eth-watcher] %poke %eth-watcher-poke !>([%watch /test/(scot %ux address.cont.con) config])]
              [%pass /watch/(scot %ux address.cont.con) %agent [our.bol %eth-watcher] %watch /logs/test/(scot %ux address.cont.con)]
          ==
        %-  eth-watcher-config-maker:erc20:books
        [node-url %.n ~m1 ~m1 address.cont.con]
      ::
          %erc-721
        `state
      ==
    ==
  --
++  parse-rpc-json
  ~
--
