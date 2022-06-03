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
::  - lilblackbook: your friends - a map of addresses to metadatas
::  - held-wallets: your wallets - a map of addresses to metadatas
::  - elucidations: your notes - a map of trxhashes to annotations
::
+$  state-zero
  $:  zapper-token=[uid=@t pw=@t]
      transactions=((mop @da transaction) gth)
      lilblackbook=(map @ux wallet)
      held-wallets=(map @ux wallet)
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
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
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
    ?-  -.vaz
      %change-zapper-creds  `this
      %add-transaction  `this
      %add-wallet  `this
      %add-friend  `this
      %annotation  `this
    ==
  ==
::
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-leave  on-leave:def
++  on-watch  on-watch:def
--
