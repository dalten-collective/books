/-  hark
/+  pal
::  books sur file
::
^?  ::  context of core not available - we're air tight bb
|%
::
::    chains
::  - data used to specify a built in chain or a custom lib
::  chain. libs will have a prescribed shape (below)
::
+$  chain
  $%  %ethereum-mainnet
      %bitcoin-mainnet
      %monero-mainnet
      $:  %other
          name=@tas            ::  must be unique
          conversion-lib=@tas
          base-denomination=@ud
          wallet-atom-type=?(%ux %t %)
      ==
  ==
+$  chains  (map chain chain-lib)
::
::    chain-lib
::  chain libraries help books compete with an ever-expanding
::  array of layer 1 solutions.
::
+$  chain-lib
  $_  ^|
  |_  [bowl:gall wal=wallets tax=transactions]
  ++  on-poke
    |~([=mark =vase] [*(list card:agent:gall) *change])
  ++  on-arvo
    |~([=wire =sign-arvo] [*(list card:agent:gall) *change])
  ++  on-agent
    |~([=wire =sign:agent:gall] [*(list card:agent:gall) *change])
  --
::
::  DEV NOTE
::  maybe we should store everything as data unless they ask for parsing using a thread so it can fail
::
::    transactions
::  - the user can elect to watch for certain transactions
::  using their main/custom chain library. This data is
::  automatically recorded in the mip called transactions;
::    -alternatively-
::  - when perusing the interface, which will include
::  transactions not recorded in state, a user can elect 
::  to record a transaction, optionally with note, for
::  offline review;
::    -additionally-
::  - data from gossip network integration will be stored in
::  gossip data structures (below).  user can elect to 
::  include individual transactions from same in their 
::  mip of transactions (or ignore them).
::
::  - transactions are stored off-line when the user specifies
::  such that, even without an internet connection, basic
::  account data should be available.
::
+$  transactions  (mip:pal chain tx-hash tx-data)
+$  tx-hash  atom
+$  tx-data
  $:  $=  parsed
      %-  unit
      $%  [%base from=atom to=atom amt=@ud fees=@ud pub=? =tx-hash]
          [%toke contract=atom from=atom to=atom amt=@ud fees=@ud pub=? =tx-hash]
          [%data data=@t fees=@ud pub=? =tx-hash]
          $:  %swap
              exchange-contract=atom
              from=atom  in-con=atom  amt=@ud  sign=(unit tape)
              to=atom   out-con=atom  amt=@ud  sign=(unit tape) 
              fees=@ud  pub=?  =tx-hash
          ==
      ==
    ::
      noted=(unit note)
  ==
::
+$  note
  $:  $=  basis  %-  unit
      [@ud ?(%eth %usd %btc %xmr [%oth ticker=term])]
      narrative=(unit tape)
      tag=(set term)
      related=(set tx-hash)
  ==
::
::    wallets
::  - the user can specify wallets to watch for balance changes
::    -additionally-
::  - this information (things like public names) can be
::  received via gossip and user can elect to move them here
::
+$  wallets  (mip:pal chain atom content)
+$  content
  $:  $=  pub-name
      %-  unit
      [name=tape ship-sig=[@ux ship life] =tx-hash]
    ::
      priv-name=(unit tape)
      l1-balance=@ud
      other-balances=(set account)
  ==
::
::  account
::
::  - address of contract
::  - name of contract, per contract
::  - symbol of contract, per contract
::  - denomination (for fungible) - number of decimal places
::  - hold
::    - (for fungible) - quantity held, @ lowest denomination
::    - (for nft) - IDs held, set
::  - total supply - in lowest denomination (for nft, whole units)
::
+$  account
  $%  $:  %fungible-token
          address=atom
          name=(unit tape)  symbol=(unit tape)
          denomination=(unit @ud)  hold=@ud
          total-supply=(unit @ud)
      ==
    ::
      $:  %non-fungible-token
          address=atom
          name=(unit tape) symbol=(unit tape)
          hold=(set atom)  total-supply=(unit @ud)
      ==
  ==
::
::    cook
::  actions allow you to watch a wallet and watch, where
::  appropriate, sub-contracts of the underlying system
::    - Tobias Smollett's
::      The Adventures of Peregrine Pickel, 1751:
::    "Some falsified printed accounts, artfully cooked up,
::     on purpose to mislead and deceive."
::    
+$  cook
  $%  [%watch-tokens address=atom =chain standard=term]
      [%watch-wallet address=atom =chain name=(unit tape)]
      [%leave-tokens addresses=(set atom)]
      [%leave-wallet addresses=(set atom)]
      [%match-toklet token=atom wallet=(set atom)]
    ::
      [%cristen-addy address=atom priv-name=tape]
      $:  %publish-addy
          address=atom
          pub=[name=tape ship-sig=[@ux ship life] eth-sig=@ux]]
      ==
    ::
      [%annotate =tx-hash =note]
    ::
  ==
::
::    change
::  - change is just an expected form of message back to
::  books. it could probably be one type but we like a
::  no change option
::    -aditionally-
::  - each change can return a `(list content:hark)` which
::  books will dilligently send on to hark-store
+$  change
  $%  $:  %change
          bal=(map atom content)
          tax=(map tx-hash tx-data)
          hark=(unit (list content:hark))
      ==
    ::
      [%no-change hark=(unit (list content:hark))]
  ==
::
::    gossip data
::
+$  overheard  [=wallets =transactions]
--