::  /app/books
::
/-  *books
/+  default-agent, dbug

|%
+$  versioned-state
  $%  [%0 state-zero]
  ==
::
::  state-zero
::  - zapper-token: zapper.fi uid + password, defaulting to public
::  - transactions: a mop of zapper timestamps to transaction data
::  - tags: tags you've used for wallets, transactions
::
::  - held-wallets: your wallets - a map of addresses to metadatas
::  - lilblackbook: your friends - a map of addresses to metadatas
::
::  - transactions: your transactions, stored, as a mop
::  - elucidations: your notes - a map of trxhashes to annotations
::
+$  state-zero
  $:  zapper-token=[uid=@t pw=@t]
      etherscankey=@t
      tags=(set @tas)
    ::
      held-wallets=(map @ux [nick=@t tags=(set @tas)])
      lilblackbook=(map @ux wallet)
    ::
      transactions=((mop @da transaction) gth)
      elucidations=(map @ux annotation)
  ==
::
+$  card  card:agent:gall
--
::
%-  agent:dbug
::
=|  [%0 state-zero]
=*  state  -
::
^-  agent:gall
::
=<
  |_  =bowl:gall
  +*  this  .
      def   ~(. (default-agent this %|) bowl)
      is    ~(. +> bowl)
  ++  on-init
    ^-  (quip card _this)
    =.  zapper-token
      ['96e0cc51-a62e-42ca-acee-910ea7d2a241' '']
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
        %0
      `this(state old)
    ==
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?>  =(our.bowl src.bowl)
    ?+    mark  (on-poke:def mark vase)
        %books-page
      =/  vaz=page  !<(page vase)
      =^  cards  state
        ?-  -.vaz
          %change-zapper-creds  zip-zap:gilt:is
          %etherscan-key        eth-key:gilt:is
          %add-transaction      add-dis:gilt:is
          %add-wallet           (add-wal:gilt:is +.vaz)
          %del-wallet           (del-wal:gilt:is +.vaz)
          %add-friend           add-bud:gilt:is
          %del-friend           `state
          %annotation           pen-pad:gilt:is
          %del-a-note           `state
        ==
      [cards this]
    ==
  ::
  ++  on-watch
    |=  pat=path
    ~&  pat
    ?+    pat  (on-watch:def pat)
        [%website ~]
      =,  enjs:format
      :_  this
      =-  [%give %fact ~ json+!>(`json`-)]~
      %-  pairs
      :~  head+s+'wallets'
        :+  'fren'  %a
        ^-  (list json)
        %-  ~(rep by lilblackbook)
        |=  [[a=@ux w=wallet] j=(list json)]
        :_  j  :-  %a
        ::  here, we're sending a list of mini-arrays to 
        ::  mirror the structure of a Map Object from 
        ::  Immutable.js
        :: - https://immutable-js.com/docs/latest@main/Map/
        ^-  (list json)
        :~  s+(scot %ux a)
          ::
            %-  pairs
            :~  nickname+s+nick.w
                who+s+?~(who.w '' (scot %p u.who.w))
                tags+a+`(list json)`(turn ~(tap in tags.w) (lead %s))
            ==
        ==
      ::
        :+  'mine'  %a
        ^-  (list json)
        %-  ~(rep by held-wallets)
        |=  [[a=@ux [n=@t t=(set @tas)]] j=(list json)]
        :_  j  :-  %a
        :~  s+(scot %ux a)
          ::
            %-  pairs
            :~  address+s+(scot %ux a)
                nickname+s+n
                tags+a+`(list json)`(turn ~(tap in t) (lead %s))
            ==
        ==
      ==
    ==
  ++  on-arvo   on-arvo:def
  ++  on-fail   on-fail:def
  ++  on-peek   on-peek:def
  ++  on-agent  on-agent:def
  ++  on-leave  on-leave:def
  --
|_  bol=bowl:gall
++  gilt
  |%
  ++  zip-zap
    ^-  (quip card _state)
    `state
  ++  eth-key
    ^-  (quip card _state)
    `state
  ++  add-dis
    ^-  (quip card _state)
    `state
  ::
  ++  del-wal
    |=  a=@ux
    ^-  (quip card _state)
    ~|  '%books-fail -address-not-tracked'
    ?>  (~(has by held-wallets) a)
    =,  enjs:format
    :_  state(held-wallets (~(del by held-wallets) a))
    =-  [%give %fact ~[/website] json+!>(`json`-)]~
    %-  pairs
    :~  head+s+'del-wallet'
        remove+s+(scot %ux a)
        status+s+(crip "Deleted Tracked Wallet: {(scow %ux a)}")
    ==
    ::
  ++  add-wal
    |=  [a=@ux n=@t t=(set @tas)]
    ^-  (quip card _state)
    ~|  '%books-fail -address-already-tracked'
    ?<  (~(has by held-wallets) a)
    =,  enjs:format
    :_  state(held-wallets (~(put by held-wallets) a [n t]))
    =-  [%give %fact ~[/website] json+!>(`json`-)]~
    %-  pairs
    :~  head+s+'add-wallet'
      :-  'new'
      :-  %a
      :~  s+(scot %ux a)
        ::
          %-  pairs:enjs:format
          :~  nick+s+n
              tags+a+`(list json)`(turn ~(tap in t) (lead %s))
          ==
      ==
    ::
      status+s+(crip "Added Tracked Wallet: {(scow %ux a)}")
    ==
  ::
  ++  add-bud
    ^-  (quip card _state)
    `state
  ++  pen-pad
    ^-  (quip card _state)
    `state
  --
--