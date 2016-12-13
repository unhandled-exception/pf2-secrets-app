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
      $.message[Resource not found.]
    ]
  ]

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
