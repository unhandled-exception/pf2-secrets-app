@USE
pf2/lib/web/controllers.p


@CLASS
CORSMiddleware

## Мидлваре добавляет заголовки для поддержки http-запросов с другого домена.
## https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS

@BASE
pfMiddleware

@create[aOptions]
## aOptions.applicationName — строка для заголовка Application-Name.
  ^BASE:create[$aOptions]

  $self._applicationName[$aOptions.applicationName]

@processRequest[aAction;aRequest;aController;aProcessOptions] -> [response|null]
  $result[]
  ^if($aRequest.method eq "options"){
#   Если нам прислали запрос с методом OPTIONS, то прерываем обработку и возвращаем ответ с опциями CORS.
    $result[^pfResponse::create[$__empty_body__;
      $.contentType[text/plain]
      $.status[204]
      $.headers[
        $.[Access-Control-Allow-Origin][*]
        $.[Access-Control-Allow-Methods][GET, PUT, POST, DELETE, OPTIONS]
        $.[Access-Control-Max-Age][86400]
        $.[Access-Control-Allow-Credentials][true]
        $.[Access-Control-Allow-Headers][Authorization,DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type]
        ^if(def $self._applicationName){$.[Application-Name][$self._applicationName]}
      ]
    ]]
  }

@processResponse[aAction;aRequest;aResponse;aController;aProcessOptions] -> [response]
# Добавляем CORS-заголовки в ответ.
  $result[$aResponse]
  ^result.setHeader[Access-Control-Allow-Origin;*]
  ^result.setHeader[Access-Control-Allow-Methods;GET, PUT, POST, DELETE, OPTIONS]
  ^result.setHeader[Access-Control-Allow-Headers;Content-Type, Authorization, X-Requested-With]
  ^if(def $self._applicationName){
    ^result.setHeader[Application-Name;$self._applicationName]
  }
