/-  *books, ewe=eth-watcher
/+  eth=ethereum
::
|%
++  erc20
  |%
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
  ++  eth-watcher-config-maker
    |=  [url=@ta eager=? refresh-rate=@dr timeout-time=@dr contract=@ux]
    ^-  config:ewe
    :+  url  eager
    [refresh-rate timeout-time 14.624.734 [contract]~ ~ [0xee88.4fe6.d895.5a12.a91b.e2eb.e897.e2fa.ea76.e594]~]
  --
--