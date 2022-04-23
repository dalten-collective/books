/-  *books, ewe=eth-watcher
/+  eth=ethereum
::
|_  bol=bowl:gall
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