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

  ^router.assignModule[api/v1;controllers/site/api.p@APIController]
  ^router.assign[show/:token;show]

@onINDEX[aRequest]
  $self.title[Зашифровать и сохранить сообщение]
  ^render[/index.pt]

@onNOTFOUND[aRequest]
  $self.title[Страница не найдена (404)]
  $result[
    $.status[404]
    $.body[^render[/404.pt]]
  ]

@onShow[aRequest]
  $self.title[Прочитать сообщение]
  ^if(!def $aRequest.token){^redirectTo[/]}
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
  $self.title[Зашифровать и сохранить сообщение]
  ^if($aRequest.isPOST
    && ^self.antiFlood.validateRequest[$aRequest]
  ){
    ^try{
      $lMessage[^core.messages.save[$aRequest]]
      ^render[save.pt;
        $.title[Сообщение зашифровали и сохранили]
        $.messageLink[^aRequest.absoluteURL[^linkFor[show;$lMessage]]]
        $.messageExpiredAt[$lMessage.expiredAt]
      ]
    }{
       ^if(^exception.type.match[^^core\.messages\.][n]){
         $exception.handled(true)
         $lError[
           $.type[$exception.type]
           $.message[$exception.source]
         ]
       }
       ^if($lError){
         ^render[/index.pt;
           $.error[$lError]
           $.formData[$aRequest.form]
         ]
       }
     }
  }{
     ^redirectTo[/]
   }
