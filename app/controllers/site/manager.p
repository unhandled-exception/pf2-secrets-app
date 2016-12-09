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

@onSave[aRequest]
  $self.title[Сохранить сообщение]
  ^if($aRequest.isPOST
    && ^self.antiFlood.validateRequest[$aRequest]
  ){
    $lMessage[^core.messages.save[$aRequest.form]]
    Ссылка на сообщение — ^aRequest.absoluteURL[^linkFor[show;$lMessage]]
  }{
     ^redirectTo[/]
   }
