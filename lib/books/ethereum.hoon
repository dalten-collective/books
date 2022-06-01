/-  *books, rpc=json-rpc
/+  eth=ethereum, ethio, default-agent, dbug, books
::    ethereum-books-handler
::
::  Plan:
::    - Handle ERC20, ERC721, ERC1155, Base Ether
::    - Capable of RPC calls to get information
::      - handles Iris returning behavior
::      - subscribes to and handles eth-watcher subscriptions
::    - Returns a (quip card _change)
::+$  chain-lib
::  $_  ^|
::  |_  [bowl:gall wal=wallets tax=transactions]
::  ++  on-poke
::    |~([=mark =vase] [*(list card:agent:gall) *change])
::  ++  on-arvo
::    |~([=wire =sign-arvo] [*(list card:agent:gall) *change])
::  ++  on-agent
::    |~([=wire =sign:agent:gall] [*(list card:agent:gall) *change])
::  --
=<
  |_  [=bowl:gall wal=wallets tax=transactions]
  +*  hc  ~(. +> bowl)
  ++  on-poke
  ++  on-arvo
    |=  [=wire sign=sign-arvo]
    ?+    wire  `this
        [%iris %rpc %request ~]
      ?.  ?=([%iris %http-response *] sign)  `this
      ?.  ?=([%finished *] client-response.sign)  `this
      ?~  fife=full-file.client-response.sign
        ((slog leaf+"%empty-rpc-data" ~) `this)
      ?.  =('application/json' type.u.fife)  `this
      ~&  >>>  ?~  mame=(de-json:html `@t`q.data.u.fife)  "no response"
               ?.  ?=([%o p=*] u.mame)  "no object"
               ?~  don=(~(get by `(map @t json)`p.u.mame) 'result')  "no result"
               (parse-hex-result:rpc:eth u.don)
      `this
    ::
        [%iris %rpc %eth-balance @ ~]
      ?.  ?=([%iris %http-response *] sign)  `this
      ?~  pend=(~(get by wallets) (slav %ux +>+<.wire))  `this
      ?~  luna=~(eth-balance iris-abi:bot client-response.sign)  `this
      =.  wallets
        (~(put by wallets) address.u.pend %_(u.pend ether-balance u.luna))
      %.  `this  %-  slog
      :~  leaf+"%books-got-eth-balance"
          leaf+"-wallet.{(scow %ux address.u.pend)}"
          leaf+"-wei.{<u.luna>}"
      ==
    ::
        [%iris %rpc @ @ @ ~]
      =/  con=contract-type
        ;;(contract-type [(slav %tas +>+<.wire) `@ux`(slav %ux +>+>-.wire)])
      ?.  ?=([%iris %http-response *] sign)  `this
      ~&  >>>  ~(strepper iris-abi:bot client-response.sign)
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
  ++  on-agent
  --

|_  bol=bowl:gall
::
::    helper function
::
++  iris-req
  |=  [url=@t rid=(unit @t) req=request:rpc:eth]
  ^-  task:iris
  =+  ?~(rid `(scot %da now.bol) `u.rid)
  [%request (light-jon (need (de-purl:html url)) (plead-jon - req)) [5 3]]
::
++  erc20
  |%
  ++  stdlib
    |%
    ++  name
      ^~  (tape (ncode-cal 'name()' ~))
    ++  decimals
      ^~  (tape (ncode-cal 'decimals()' ~))
    ++  symbol
      ^~  (tape (ncode-cal 'symbol()' ~))
    ++  total-supply
      ^~  (tape (ncode-cal 'totalSupply()' ~))
    ++  balance-of
      |=  =address
      (tape (ncode-cal 'balanceOf' ~[address+address]))
    --
  ++  topics
    |%
    ++  transfer
      ^~  ^-  @ux
      %-  keccak-256:keccak:crypto
      (as-octs:mimes:html 'Transfer(address,address,uint256)')
    ++  approval
      ^~  ^-  @ux
      %-  keccak-256:keccak:crypto
      (as-octs:mimes:html 'Approval(address,address,uint256')
    --
  ++  eth-watcher-config
    |=  $:  url=@ta  eager=?  block=@ud
            contract=@ux     addresses=(set address)
        ==
    =*  trans  transfer:topics
    =*  appro  approval:topics
    =/  pats=[in=path out=path]
      [/erc-20/to/(scot %ux contract) /erc-20/from/(scot %ux contract)]
    |^
    =;  both=[in=config:ewe out=config:ewe]
      %-  welp  :_  dog-watcher
      (dog-leasher contract in.both out.both)
    :-  :+  url  eager
        :+  ~m1  ~m1
        [block [contract]~ ~ [trans 0x0 ~(tap in addresses)]~]
    :+  url  eager
    :+  ~m1  ~m1
    [block [contract]~ ~ [trans ~(tap in addresses)]~]
    ++  dog-watcher
      :~  [%pass in.pats %agent [our.bol %eth-watcher] %watch [%logs in.pats]]
          [%pass out.pats %agent [our.bol %eth-watcher] %watch [%logs out.pats]]
      ==
    ++  dog-leasher
      |=  [contract=@ux in=config:ewe out=config:ewe]
      :~  :^  %pass  /eth-watcher/kick/(scot %da now.bol)  %agent
          [[our.bol %eth-watcher] %poke %eth-watcher-poke !>([%watch in.pats in])]
          :^  %pass  /eth-watcher/kick/(scot %da now.bol)  %agent
          [[our.bol %eth-watcher] %poke %eth-watcher-poke !>([%watch out.pats out])]
      ==
    --
  --
--