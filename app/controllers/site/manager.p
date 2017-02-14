@USE
controllers/site/interface.p
pf2/lib/web/middleware.p


## Главный контролер сайта

@CLASS
SiteManager

@BASE
SiteInterfaceModule

@OPTIONS
locals

@create[aOptions]
## aOptions.conf — хеш с конфигурацией сайта
  ^BASE:create[
    ^hash::create[$aOptions]
    $.asManager(true)
  ]
  $self.conf[$aOptions.conf]

  ^router.assign[/message/:token;/message;
    $.where[
      $.token[[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}]
    ]
  ]

# Подключаем модуль и страницу с описанием API сайта
  ^router.module[/api/v1;controllers/site/api.p@APIController]
  ^router.assign[/api;$.render[
    $.template[/api.pt]
    $.context[$.title[АПИ]]
  ]]

  ^if($self.isDebug){
    ^router.middleware[pfDebugInfoMiddleware;
      $.enable(true)
      $.sql[$core.CSQL]
      $.enableHighlightJS(true)
#     $.hideQueryLog(true)
    ]
  }

# Мидлваре для защиты от CSRF-атак
  ^router.middleware[pf2/lib/web/csrf.p@pfCSRFMiddleware;
    $.cryptoProvider[$core.security]
    $.cookieHTTPOnly(true)
    $.cookieSecure(true)
    $.pathExempt[
      $.api[^^/api/v1]
    ]
  ]

# Подключаем мидлваре для хранения зашифрованной сессий на клиенте
# В сессию запишем токен зашифрованного сообщения, чтобы потом безопасно показать на странице /message/saved.
  ^router.middleware[pf2/lib/web/middleware.p@pfSessionMiddleware;
    $.cryptoProvider[$core.security]
    $.expires[session]
  ]

@/NOTFOUND[aRequest]
## Обработчик всех 404-страниц
## Вызываем, если не найден обработчик для марщрута или в обработчике вызвали ^abort(404)
  $self.title[Страница не найдена (404)]
  $result[
    $.status[404]
    $.body[^render[/404.pt]]
  ]

@/INDEX[aRequest]
## Главная страница сайта
  $self.title[Зашифровать и сохранить сообщение]
  ^if($aRequest.isPOST){
#   Обрабатываем форму с секретныйм сообщением
    ^try{
      $lMessage[^core.messages.save[$aRequest]]

#     Записываем токен в сессию и делаем редирект на страницу /message/saved
      $aRequest.session.message[
        $.token[$lMessage.token]
        $.expiredAt[$lMessage.expiredAt]
      ]
      ^redirectTo[message/saved]
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

@/message/saved[aRequest]
## Показываем ссылку на сохраненное сообщение
  $lMessage[$aRequest.session.message]
  ^if(!def $lMessage.token){^redirectTo[/]}
  ^aRequest.session.delete[message]

  $result[^render[message_saved.pt;
    $.title[Сообщение зашифровали и сохранили]
    $.messageLink[^aRequest.absoluteURL[^linkFor[message;$lMessage]]]
    $.messageExpiredAt[$lMessage.expiredAt]
  ]]

@/message[aRequest]
## Показываем сообщение по ссылке
  $self.title[Прочитать секретное сообщение]
  ^if(!def $aRequest.token){^redirectTo[/]}
  ^if($aRequest.isPOST){
     $lMessage[^core.messages.load[$aRequest.token;$aRequest.pin]]
     ^if(!$lMessage.error){
       $self.title[Секретное сообщение]
     }
     ^assignVar[message;$lMessage]
     ^assignVar[messageForm;$aRequest.form]
  }
  ^render[message.pt]

@/robots.txt[aRequest]
## Показываем параметры роботам.
## Это пример обработки статического маршрута с нестандартным типом ответа.
  $lRobots[
    User-agent: *
    Host: $self.conf.host
    Disallow: /api
    Disallow: /message
  ]
  $result[
    $.type[text]
    $.contentType[text/plain]
    $.body[^lRobots.match[^^\s+][gm][]]
  ]
