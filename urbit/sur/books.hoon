::  /sur/books
::
:: +$  state-zero
::   $:  zapper-token=[uid=@t pw=@t]
::       etherscankey=@t
::       tags=(set @tas)
::     ::
::       held-wallets=(map @ux [nick=@t tags=(set @tas)])
::       lilblackbook=(map @ux wallet)
::     ::
::       transactions=((mop @da transaction) gth)
::       elucidations=(map @ux annotation)
::   ==
::
|%
::
::  page
::
+$  page
  $%  [%change-zapper-creds uid=@t pw=@t]
      [%etherscan-key key=@t]
      [%add-transaction =transaction]
      [%add-wallet address=@ux nick=@t tags=(set @tas)]
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
::
+$  annotation
  $:  basis=@rd
      annotation=@t
      tags=(set @tas)
  ==
::
+$  wallet
  $:  nick=@t
      who=(unit @p)
      tags=(set @tas)
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
--