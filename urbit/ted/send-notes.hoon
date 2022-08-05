/-  spider, *books
/+  *strandio
::
=,  strand=strand:spider
::
^-  thread:spider
|=  prep=vase
=/  m  (strand ,vase)
^-  form:m
=/  uber  !<([bol=bowl:gall man=(map @ux annotation)] prep)
=,  enjs:format
=/  jon=json
  %-  pairs
  :~  head+s+'annotation'
      status+s+'annotations incoming'
      :+  %new  %a
      ^-  (list json)
      %-  ~(rep by man.uber)
      |=  $:  [hax=@ux [b=@rd t=(unit @ux) a=@t tg=(set @tas)]]
              max=(list json)
          ==
      :_  max
      %-  pairs
      :~  hash+s+(scot %ux hax)
          basis+s+(scot %rd b)
          to+?~(t ~ s+(scot %ux u.t))
          annotation+s+a
          tags+a+`(list json)`(turn ~(tap in tg) (lead %s))
      ==
  ==
(pure:m !>(jon))