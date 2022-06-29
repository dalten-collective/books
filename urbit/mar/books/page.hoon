::  /mar/books/page
::
/-  *books
|_  leaf=page
++  grad  %noun
++  grow
  |%
  ++  noun  leaf
  --
++  grab
  |%
  ++  noun  page
  ++  json
    |=  jon=^json
    %-  page
    =<  (to-noun jon)
    |%
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
    ++  to-noun
      =,  dejs:format
      %-  of
      :~
        :-  %set-nick
        %-  ot
        :~  address+(su ;~(pfix (jest '0x') hex))
            nick+so
        ==
      ::  
        :-  %set-tags
        %-  ot
        :~  address+(su ;~(pfix (jest '0x') hex))
            tags+(as (se %tas))
        ==
      ::
        :-  %add-wallet
        %-  ot
        :~  address+(su ;~(pfix (jest '0x') hex))
            nick+so
            tags+(as (se %tas))
        ==
      ::
        :-  %del-wallet
        %-  ot
        :~  address+(su ;~(pfix (jest '0x') hex))
        ==
      ::
        :-  %add-transaction
        %-  ot
        :~  primarywallet+(su ;~(pfix (jest '0x') hex))
            network+(se %tas)
            hash+(su ;~(pfix (jest '0x') hex))
            blocknumber+ni
            name+so
            direction+(se %tas)
            timestamp+du
            symbol+so
            address+(su:dejs-soft:format ;~(pfix (jest '0x') hex))
            amount+ne-string
            from+(su ;~(pfix (jest '0x') hex))
            destination+(su ;~(pfix (jest '0x') hex))
            contract+(su:dejs-soft:format ;~(pfix (jest '0x') hex))
            subtransactions+(as from-sub)
            nonce+(su dem)
            txgas+ne-soft-string
            txgaslimit+ne-soft-string
            input+so:dejs-soft:format
            fee+ne-string
            txsuccessful+bo
        ==
      ==
    ++  from-sub
      =,  dejs:format
      %-  ot
      :~  type+(se %tas)
          symbol+so
          amount+ne-string
          address+(su:dejs-soft:format ;~(pfix (jest '0x') hex))
      ==
    --
  --
--