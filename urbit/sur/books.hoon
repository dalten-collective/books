::  /sur/books
::
|%
::
::  page
::
+$  page
  $%  [%change-zapper-creds uid=@t pw=@t]
      [%add-transaction =transaction]
      [%add-wallet address=@ux =wallet]
      [%add-friend address=@ux =wallet]
      [%annotation hash=@ux note=annotation]

  ==
::
::  state objects
::
+$  network
  $?  %ethereum
      %polygon
      %optimism
      %gnosis
      %binancesmartchain
      %fantom
      %avalanche
      %arbitrum
      %celo
      %harmony
      %moonriver
      %bitcoin
      %cronos
      %aurora
      %evmos
    ==
::
+$  direction
  $?  %incoming
      %outgoing
      %exchange
    ==
::
+$  subtrans
  $:  type=direction
      symbol=@t
      amount=@rd
      address=@ux
  ==
::
+$  transaction
  $:  =network
      hash=@ux
      blocknumber=@ud
      name=@t
      =direction
      timestamp=@da
      symbol=@t
      address=(unit @ux)
      amount=@rd
      from=@ux
      destination=@ux
      contract=(unit @ux)
      subtransactions=(set subtrans)
      nonce=@ud
      txgas=(unit @rd)
      txgaslimit=(unit @rd)
      input=(unit @t)
      cost=@rd
      txsuccessful=?
      primarywallet=@ux
  ==
::
+$  annotation
  $:  basis=@rd
      annotation=@t
      tags=(set @tas)
  ==
::
+$  wallet
  $:  nick=@t
      who=@p
      tags=(set @tas)
  ==
--