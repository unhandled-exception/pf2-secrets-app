@USE
controllers/site/interface.p


@CLASS
SiteManager

@BASE
SiteInterfaceModule

@OPTIONS
locals

@create[aOptions]
## aOptions.conf
  ^BASE:create[
    ^hash::create[$aOptions]
    $.asManager(true)
  ]
  $self.conf[$aOptions.conf]

  ^router.assign[show/:token;show]

@onINDEX[aRequest]
  $self.title[$core.conf.siteName]
  ^render[/index.pt]

@onNOTFOUND[aRequest]
  $self.title[Страница не найдена (404)]
  $result[
    $.status[404]
    $.body[^render[/404.pt]]
  ]

@onShow[aRequest]
  $self.title[Прочитать сообщение]
  ^if($aRequest.isPOST
    && ^self.antiFlood.validateRequest[$aRequest]
  ){
     $lMessage[^core.messages.load[$aRequest.token;$aRequest.pin]]
     ^switch[$lMessage.error.type]{
       ^case[DEFAULT]{
         ^assignVar[message;$lMessage]
         ^assignVar[messageForm;$aRequest.form]
       }
     }
  }
  ^render[show.pt]

@onSave[aRequest]
  ^if($aRequest.isPOST
    && ^self.antiFlood.validateRequest[$aRequest]
  ){
    $lMessage[^core.messages.save[$aRequest.form]]
    ^render[save.pt;
      $.title[Сообщение зашифровали и сохранили]
      $.messageLink[^aRequest.absoluteURL[^linkFor[show;$lMessage]]]
      $.messageExpiredAt[$lMessage.expiredAt]
    ]
  }{
     ^redirectTo[/]
   }
