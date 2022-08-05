/-  spider, *books
/+  *strandio
::
=,  strand=strand:spider
::
|%
+$  ccru  (unit client-response:iris)
+$  almost-trans
  $:  network=@tas
      hash=@ux
      blocknumber=@ud
      name=@t
      direction=@tas
      timestamp=@da
      symbol=@t
      address=(unit @ux)
      amount=@rd
      from=@ux
      destination=@ux
      contract=(unit @ux)
      subtransactions=(set [t=@tas s=@t a=@rd ad=(unit @ux)])
      nonce=@ud
      txgas=(unit @rd)
      txgaslimit=(unit @rd)
      input=(unit @t)
      fee=@rd
      txsuccessful=?
  ==
--
::
|^  call-zapper
::
++  gth-hex
  |=  [a=[p=@da q=@ux] b=[p=@da q=@ux]]
  ?:(=(p.a p.b) (gth q.a q.b) (gth p.a p.b))
::
++  make-http-request
  |=  [uid=@t pwd=@t urb-address=@ux]
  ?~  p=(rush (scot %ux urb-address) ;~(pfix (jest '0x') (more dot (star aln))))  !!
  =;  [authorization=@t web-address=@t]
   ^-  request:http
   :+  %'GET'
     %^  cat  3
       'https://api.zapper.fi/v2/transactions?address='
     (cat 3 '0x' web-address)
   :_  ~
   :~  'Authorization'^(cat 3 'Basic ' authorization)
       'User-Agent'^'urbit_books'
   ==
  :_  (crip (zing u.p))
  (en:base64:mimes:html (as-octs:mimes:html (rap 3 ~[uid ':' pwd])))
::
++  json-to-dino
  |=  [jon=json addy=@ux]
  |^  ^-  (list [[@da @ux] transaction])
  =;  return=(set almost-trans)
    ;;  (list [[@da @ux] transaction])
    %~  tap  in
    ;;  (set [[@da @ux] transaction])
    %-  ~(run in return)
    |=  mid=almost-trans
    ^-  [[@da @ux] transaction]
    :-  [timestamp.mid hash.mid]
    :-  addy
    %=    mid
      address    ?:(=(`0x0 address.mid) ~ address.mid)
      network    ;;(network network.mid)
      direction  ;;(direction direction.mid)
    ::
        subtransactions
      %-  ~(run in subtransactions.mid)
      |=  [t=@tas s=@t a=@rd ad=(unit @ux)]
      [;;(direction t) s a ?:(=(`0x0 address.mid) ~ address.mid)]
    ==
  =/  error=(unit @t)
    ((ot:dejs-soft:format [%message so:dejs-soft:format]~) jon)
  ?.  ?=(~ error)  *(set almost-trans)
  =,  dejs:format
  %.  jon
  %-  ot
  :~  :-  %data
      %-  as  %-  ot
      :~  network+(se %tas)
          hash+(su ;~(pfix (jest '0x') hex))
          'blockNumber'^ni
          name+so
          direction+(se %tas)
          'timeStamp'^du-string
          symbol+so
          address+(su:dejs-soft:format ;~(pfix (jest '0x') hex))
          amount+ne-string
          from+(su ;~(pfix (jest '0x') hex))
          destination+(su ;~(pfix (jest '0x') hex))
          contract+(su:dejs-soft:format ;~(pfix (jest '0x') hex))
          'subTransactions'^(as from-sub)
          nonce+(su dem)
          'gasPrice'^ne-soft-string
          'gasLimit'^ne-soft-string
          input+so:dejs-soft:format
          gas+ne
          'txSuccessful'^bo
      ==
  ==
  ++  du-string
    |=  jon=^json
    =,  dejs:format
    ^-  @da
    ?>  ?=([%s *] jon)
    ((cu from-unix:chrono:userlib ni) [%n +.jon])
  ++  ne-string
    |=  jon=^json
    =,  dejs:format
    ^-  @rd
    ?>  ?=([%s *] jon)
    (rash p.jon (cook ryld (cook royl-cell:^so json-rn)))
  ++  ne-soft-string
    |=  jon=^json
    =,  dejs-soft:format
    ^-  (unit @rd)
    ?.  ?=([%s *] jon)  ~
    (rush p.jon (cook ryld (cook royl-cell:^so json-rn)))
  ++  from-sub
    =,  dejs:format
    %-  ot
    :~  type+(se %tas)
        symbol+so
        amount+ne
        address+(su:dejs-soft:format ;~(pfix (jest '0x') hex))
    ==
  --
::
::  main thread
::
++  call-zapper
  ^-  thread:spider
  |=  prep=vase
  =/  m  (strand ,vase)
  ^-  form:m
  =/  uber
    !<  $:  bol=bowl:gall 
            uid=@t
            pw=@t
            addresses=(set @ux)
            trans=((mop ,[p=@da q=@ux] transaction) gth-hex)
        ==
    prep
  =/  addy  ~(tap in addresses.uber)
  =|  leg=(list [[@da @ux] transaction])
  =,  bol.uber
  |-  ?~  addy
    =;  vaz=vase
      (pure:m vaz)
    !>  ^-  $:  ((mop ,[p=@da q=@ux] transaction) gth-hex)
                (list [[@da @ux] transaction])
            ==
    =-  :-  next
        %~  tap  by
        %-  %~  dif  by  (malt leg)
        (malt (tap:((on ,[p=@da q=@ux] transaction) gth-hex) trans.uber))
    next=(gas:((on ,[p=@da q=@ux] transaction) gth-hex) trans.uber leg)
  ;<  ~      bind:m  (send-request (make-http-request uid.uber pw.uber i.addy))
  ;<  =ccru  bind:m  take-maybe-response
  ?~  ccru  $(addy t.addy)
  ;<  r=@t   bind:m  (extract-body u.ccru)
  ?~  jun=(de-json:html r)  $(addy t.addy)
  %=  $
    leg   (weld (json-to-dino u.jun i.addy) leg)
    addy  t.addy
  ==
--