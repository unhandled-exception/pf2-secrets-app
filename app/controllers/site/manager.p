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

  ^router.assignMiddleware[pf2/lib/web/middleware.p@pfSessionMiddleware;
    $.cryptoProvider[$core.security]
    $.expires[session]
  ]

@onNOTFOUND[aRequest]
  $self.title[Страница не найдена (404)]
  $result[
    $.status[404]
    $.body[^render[/404.pt]]
  ]

@onINDEX[aRequest]
  $self.title[Зашифровать и сохранить сообщение]
  ^if($aRequest.isPOST){
    ^try{
      $lMessage[^core.messages.save[$aRequest]]

#     Записываем токен в сессию и делаем редирект на страницу /saved
      $aRequest.session.message[
        $.token[$lMessage.token]
        $.expiredAt[$lMessage.expiredAt]
      ]
      ^redirectTo[saved]
    }{
       ^if(^exception.type.match[^^core\.messages\.][n]){
         $exception.handled(true)
         $lError[
           $.type[$exception.type]
           $.message[$exception.source]
         ]
       }
     }
  }

  ^render[/index.pt;
    $.error[$lError]
    $.formData[$aRequest.form]
  ]

@onSaved[aRequest]
  $lMessage[$aRequest.session.message]
  ^if(!def $lMessage.token){^redirectTo[/]}
  ^aRequest.session.delete[message]

  $result[^render[saved.pt;
    $.title[Сообщение зашифровали и сохранили]
    $.messageLink[^aRequest.absoluteURL[^linkFor[show;$lMessage]]]
    $.messageExpiredAt[$lMessage.expiredAt]
  ]]

@onShow[aRequest]
  $self.title[Прочитать секретное сообщение]
  ^if(!def $aRequest.token){^redirectTo[/]}
  ^if($aRequest.isPOST
    && ^self.antiFlood.validateRequest[$aRequest]
  ){
     $lMessage[^core.messages.load[$aRequest.token;$aRequest.pin]]
     ^if(!$lMessage.error){
       $self.title[Секретное сообщение]
     }
     ^assignVar[message;$lMessage]
     ^assignVar[messageForm;$aRequest.form]
  }
  ^render[show.pt]
