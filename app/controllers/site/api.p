@USE
controllers/site/interface.p


@CLASS
APIController

@BASE
SiteInterfaceModule

@OPTIONS
locals

@create[aOptions]
  ^BASE:create[$aOptions]

  $self._defaultResponseType[json]

  ^router.assign[message/:token/:pin;message]

# Подключаем CORS-мидлваре к API-модулю
  ^router.assignMiddleware[controllers/site/middlewares.p@CORSMiddleware;
    $.applicationName[pf2-secrets]
  ]

@postJSON[aResponse]
  $result[$aResponse]
  $result.contentType[application/json]
  ^if(!def $result.body){
    $result.body[{}]
  }($result.body is hash){
    $result.body[^json:string[$result.body]]
  }

@onNOTFOUND[aRequest]
  $result[
    $.status[404]
    $.body[
      $.error[Resource not found.]
    ]
  ]

@onMessagePOST[aRequest]
  ^try{
    $lMessage[^core.messages.save[
      $.data[$aRequest.message]
      $.expiredAt[$aRequest.exp]
      $.pinHash[$aRequest.pin]
    ]]
    $lExp[^date::create[$lMessage.expiredAt]]
    $result[
      $.status[201]
      $.body[
        $.token[$lMessage.token]
        $.exp[^lExp.iso-string[]]
      ]
    ]
  }{
     ^if(^exception.type.match[^^core\.messages\.][n]){
       $exception.handled(true)
       $result[
         $.status[400]
         $.body[
           $.error[$exception.source]
         ]
       ]
     }
  }

@onMessageGET[aRequest]
  $lMessage[^core.messages.load[$aRequest.token;$aRequest.pin]]
  ^if(!$lMessage.error){
    $result[
      $.body[
        $.token[$lMessage.token]
        $.message[$lMessage.text]
      ]
    ]
  }{
     $result[
       $.status[^if($lMessage.error.type eq "message.not.found"){404}{400}]
       $.body[
         $.error[$lMessage.error.source]
       ]
     ]
   }

@onPing[aRequest]
  $result[
    $.contentType[text/plain]
    $.body[pong]
  ]

@onParams[aRequest]
  $result[
    $.body[
      $.max_exp_min($core.conf.defaultMessageTTL)
      $.max_pin_attempts($core.conf.maxPinAttempts)
      $.min_pin_size($core.conf.minPinSize)
    ]
  ]
