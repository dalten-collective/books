/-  ewe=eth-watcher
/+  eth=ethereum
::  books sur file
::
::  erc20 Transfer Topic
::  - 0xddf2.52ad.1be2.c89b.69c2.b068.fc37.8daa.952b.a7f1.63c4.a116.28f5.5a4d.f523.b3ef
::
|%
+$  address  address:ethereum-types
+$  node-url   @t
::
::::  state
::  - node-url - any json-rpc node, for raw Eth queries
::  - 
+$  state-zero  [%0 =node-url =wallets =contracts]
::
::::  wallets
::  - includes only Ether balance and names
::
+$  wallets  (map address wallet-data)
+$  wallet-data
  $%  [%0 wallet-data:zero]
  ==
::
::::  (un)watched contracts
::  - includes any facts we know about transactions
::  - includes affordances for watching contracts for
::    additional information
::
+$  contracts  (map contract-type contract)
+$  contract-type
  $%  [%erc-20 address=@ux]
      [%erc-721 address=@ux]
  ==
+$  contract
  $%  [%0 contract:zero]
  ==
::
::::  ethereum denominations
::
+$  denomination
  $%  [%wei ~]             ::  18
      [%ada ~]             ::  15
      [%babbage ~]         ::  12
      [%shannon ~]         ::  9
      [%szabo ~]           ::  6
      [%finney ~]          ::  3
      [%ether ~]           ::  1
      [%other factor=@sd]  ::  roll your own
  ==
::
+$  page  $%  [%send-rpc rid=@t req=request:rpc:eth]
              [%node-rpc node=@t]
              config-wallets
              config-contracts
          ==
+$  config-wallets
  $%  [%watch-wallet =address priv-name=(unit @t)]
      ::[%leave-wallet =address]
      ::[%shout-wallet =address public-name=@t eth-sig=@ux]
  ==
+$  config-contracts
  $%  [%watch-contract cont=contract-type]
      ::[%leave-contract contract=contract-type]
  ==
::
++  zero
  |%
  ::
  ::
  +$  wallet-data
    $:  =address
        public-name=(unit [=address name=@t ship-sig=[p=@ux q=ship r=life] eth-sig=@ux])
        private-name=(unit @t)
        ether-balance=@ud
    ==
  +$  note
    $:  basis=@ud
        purpose=tape
    ==
  +$  contract
    $:  watched=(unit path)
        events=((mop @da $:(=event-log:rpc:eth =note)) gth)
        sub=(unit denomination)
        balances=(map @ux @ud)
    ==
  --
--