/-  *books, rpc=json-rpc
/+  eth=ethereum, ethio, default-agent, dbug, books
::
|%
+$  versioned-state  
  $%  state-zero
  ==
::
::    aliases
::
+$  call     call:rpc:eth
+$  card     card:agent:gall
+$  request  request:rpc:eth
::
::    helper function
::
++  iris-req
  |=  [url=@t rid=(unit @t) req=request]
  ^-  task:iris
  [%request (light-jon (need (de-purl:html url)) (plead-jon rid req)) [5 3]]
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
      jot   ~(. books bowl)
      bot   ~(. +> bowl)
  ++  on-init
    ^-  (quip card _this)
    =?    node-url
        =(~ node-url)
      'https://rinkeby.infura.io/v3/d43cb0b443194c9e8d1ccfa41c0f7b2c'
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
        ~&  >>  headers.response-header.client-response.sign
        ?~  fife=full-file.client-response.sign
          ((slog leaf+"%empty-rpc-data" ~) `this)
        ?.  =('application/json' type.u.fife)  `this
        ~&  >>>  ?~  mame=(de-json:html `@t`q.data.u.fife)  "no response"
                 ?.  ?=([%o p=*] u.mame)  "no object"
                 ?~  don=(~(get by `(map @t json)`p.u.mame) 'result')  "no result"
                 (parse-hex-result:rpc:eth u.don)
        `this
      ==
    ::
        [%iris %rpc @ @ @ ~]
      =/  con=contract-type
        ;;(contract-type [(slav %tas +>+<.wire) `@ux`(slav %ux +>+>-.wire)])
      ?+    sign  `this
          [%iris %http-response *]
        ?~  rban=(~(get by contracts) con)  `this
        ?+    (slav %tas +>-.wire)  `this
            %name
          ?^  name.u.rban  `this
          ?~  phobos=~(name iris-abi:bot client-response.sign)  `this
          =.  contracts
            (~(put by contracts) con u.rban(name phobos))
          %.  `this  %-  slog
          :~  leaf+"%books-got-name {u.phobos}"
              leaf+"-contract.{<con>}"
          ==
        ::
            %symbol
          ?^  symbol.u.rban  `this
          ?~  triton=~(symbol iris-abi:bot client-response.sign)  `this
          =.  contracts
            (~(put by contracts) con u.rban(symbol triton))
          %.  `this  %-  slog
          :~  leaf+"%books-got-symbol {u.triton}"
              leaf+"-contract.{<con>}"
          ==
        ::
            %denomination
          ?^  sub.u.rban  `this
          ?~  deimos=~(denomination iris-abi:bot client-response.sign)  `this
          =.  contracts
            (~(put by contracts) con u.rban(sub deimos))
          %.  `this  %-  slog
          :~  leaf+"%books-got-denomination {<u.deimos>}"
              leaf+"-contract.{<con>}"
          ==
        ==
      ==
    ==  
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ~&  >>>  wire
    ~&  >>  sign
    `this
  ++  on-peek   on-peek:def
  ++  on-fail   on-fail:def
  ++  on-watch  on-watch:def
  ++  on-leave  on-leave:def
  --
  ::
|_  bol=bowl:gall
+*  jot  ~(. books bol)
++  iris-abi
  |_  clep=client-response:iris
  ++  strepper
    ^-  (unit @)
    ?.  ?=([%finished *] clep)  ~
    ?~  fife=full-file.clep     ~
    ?.  =('application/json' type.u.fife)      ~
    ?~  mame=(de-json:html `@t`q.data.u.fife)  ~
    ?.  ?=([%o p=*] u.mame)  ~
    ?~  don=(~(get by `(map @t json)`p.u.mame) 'result')  ~
    `(parse-hex u.don)
  ++  name
    ^-  (unit tape)
    ?~(don=`(unit @)`strepper ~ `(dcode-res u.don [%string]~))
  ++  symbol
    ^-  (unit tape)
    ?~(don=`(unit @)`strepper ~ `(dcode-res u.don [%string]~))
  ++  total-supply
    ^-  (unit @ud)
    ?~(don=`(unit @)`strepper ~ `(dcode-res u.don [%uint]~))
  ++  denomination
    ^-  (unit ^denomination)
    ?~  don=`(unit @)`strepper  ~
    =+  pex=u.don
    ?+  pex  `[%other pex]
      %18  `[%wei ~]
      %15  `[%ada ~]
      %12  `[%babbage ~]
       %9  `[%shannon ~]
       %6  `[%szabo ~]
       %3  `[%finney ~]
       %1  `[%ether ~]
    ==
  --
++  con-page
  |=  con=page
  =+  surp=(de-purl:html node-url)
  |^
  ?-    -.con
      %watch-wallet    (con-wal con)
      %watch-contract  (con-con con)
  ::
      %node-rpc
    ?^  (de-purl:html node.con)
      %-  (slog leaf+"%books-rpc-node [%url \"{(trip node.con)}\"]")
      `state(node-url node.con)
    %.  `state  %-  slog
    :~  leaf+"%books-rpc-node-not-set"
        leaf+"-bad.url.format"
    ==
  ::
      %send-rpc
    ?:  =('' node-url)
      %.  `state  %-  slog
      :~  leaf+"%books-send-rpc-fail"
          leaf+"-maybe.check.node-url"
      ==
    :_  state
    ^-  (list card:agent:gall)
    :~  :+  %pass  /iris/rpc/request
        [%arvo %i (iris-req node-url `rid.con req.con)]
    ==
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
      ::
      ::    watch-contract will add a contract to your contracts
      ::  and continue to watch it, including transactions in and
      ::  out of all addresses in your wallet
      ::
      ?-    `contract-type`cont.con
          [%erc-20 @]
        ?:  =(~ wallets)  
          %.  `state  %-  slog
          :~  leaf+"%books-watch-contract-fail"
              leaf+"-need.?=(wallets ^)"
              leaf+"-have.?=(wallets ~)"
          ==
        ?:  (~(has by contracts) cont.con)
          %.  `state  %-  slog
          :~  leaf+"%books-watch-contract-fail"
              leaf+"-duplicate.contract"
              leaf+"-remove.first"
          ==
          ::
        =;  calls=(list card)                            ::  we found what we needed
          =.  contracts
            (~(put by contracts) cont.con [~ ~ ~ ~])
          [calls state]
        =+  late=[%label %latest]
        =/  data=[name=request symb=request deno=request]
          :+  [%eth-call [~ +.cont.con ~ ~ ~ name.stdlib.erc20.jot] late]
            [%eth-call [~ +.cont.con ~ ~ ~ symbol.stdlib.erc20.jot] late]
          [%eth-call [~ +.cont.con ~ ~ ~ decimals.stdlib.erc20.jot] late]
        %+  welp
          ^-  (list card)
          :~  :+  %pass  /iris/rpc/name/erc-20/(scot %ux address.cont.con)
              [%arvo %i `task:iris`(iris-req node-url ~ name.data)]
              :+  %pass  /iris/rpc/symbol/erc-20/(scot %ux address.cont.con)
              [%arvo %i `task:iris`(iris-req node-url ~ symb.data)]
              :+  %pass  /iris/rpc/denomination/erc-20/(scot %ux address.cont.con)
              [%arvo %i `task:iris`(iris-req node-url ~ deno.data)]
          ==
        ^-  (list card)
        =-  (eth-watcher-config:erc20:jot -)
        [node-url %.n 10.543.000 address.cont.con ~(key by wallets)]
      ::
          [%erc-721 @]
        `state
      ==
    ==
  --
++  parse-rpc-json
  ~
--
