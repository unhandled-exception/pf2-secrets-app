@USE
controllers/site/interface.p


## Контролер для api сайта
## Монтируем в /api/v1

@CLASS
APIController

@BASE
SiteInterfaceModule

@OPTIONS
locals

@create[aOptions]
  ^BASE:create[$aOptions]

  $self._defaultResponseType[json]

  ^router.assign[/message/:token/:pin;/message]

# Подключаем CORS-мидлваре к API-модулю
  ^router.middleware[controllers/site/middleware.p@CORSMiddleware;
    $.applicationName[pf2-secrets]
  ]

@response<json>[aResponse]
## Постобработчик для ответов типа json
## Если нам пришел хеш, то преобразовываем его в json-строку
## Добавляем заголовок Content-Type: application/json
  $result[$aResponse]
  $result.contentType[application/json]
  ^if(!def $result.body){
    $result.body[{}]
  }($result.body is hash){
    $result.body[^json:string[$result.body]]
  }

@catch<http.404>[aRequest;aException]
## Выдаем свою сраничку для 404-ошибки в формате JSON
  $result[
    $.status[404]
    $.body[
      $.error[Resource not found.]
    ]
  ]

@/message<post>[aRequest]
## Зашифровать и сохранить сообщение на сервере
## POST /api/v1/message, body - `pin=12345&message=testtest-12345678&exp=15
## message — сообщение
## exp — время жизни сообщения в минутах
## pin — пин-код
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

@/message<get>[aRequest]
## Загрузить сообщение
## GET /api/v1/message/:token/:pin
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

@/ping<get>[aRequest]
## Пинг
## GET /api/v1/ping
  $result[
    $.contentType[text/plain]
    $.body[pong]
  ]

@/params<get>[aRequest]
## Получить настройки сервиса
## GET /api/v1/params
  $result[
    $.body[
      $.min_exp_min($core.conf.defaultMessageTTL)
      $.max_pin_attempts($core.conf.maxPinAttempts)
      $.min_pin_size($core.conf.minPinSize)
    ]
  ]
