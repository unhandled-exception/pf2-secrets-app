@USE
pf2/lib/common.p

## Клиент для REST API сайта https://secrets.unhandled-exception.ru/
## Описание API —  https://secrets.unhandled-exception.ru/api/

@CLASS
ueSecretsAPI

@BASE
pfClass

@OPTIONS
locals

@create[aOptions]
## aOptions.apiURL[https://secrets.unhandled-exception.ru/api/v1/] — адрес API сайта
## aOptions.timeout(5) — таймаут для http-запросов
  ^self.cleanMethodArgument[]
  ^BASE:create[$aOptions]

  $self._apiURL[^self.ifdef[$aOptions.apiURL]{https://secrets.unhandled-exception.ru/api/v1}]
  $self._timeout(^aOptions.timeout.int(5))
  $self._exceptionType[secrets.api.fail]

@save[aMessage;aPin;aOptions] -> [$.token $.expiredAt]
## Сохраить сообщение aMessage с пин-кодом $aPin.
## aOptions.exp — время в минутах сколько хранить сообщение
  $self.cleanMethodArgument[]
  $result[^hash::create[]]
  $lRes[^self._request[message;POST][
    $.message[$aMessage]
    $.pin[$aPin]
    ^if(^aOptions.contains[exp]){
      $.exp[^aOptions.exp.int[]]
    }
  ]]
  ^if($lRes.status eq "201" && ^lRes.[CONTENT-TYPE].match[application/json][in]
  ){
#   Сохранили сообщение
    $lData[^json:parse[^taint[as-is][$lRes.text]]]
    $result.token[$lData.token]
    $result.expiredAt[$lData.exp]
  }($lRes.status eq "400"){
#   Ошибка при сохранении
    ^if(^lRes.[CONTENT-TYPE].match[application/json][in]){
      $lData[^json:parse[^taint[as-is][$lRes.text]]]
      $lError[$lData.error]
    }
    ^throw[$self._exceptionType;$lError]
  }

@load[aToken;aPin;aOptions] -> [$.token $.message]
## Сохраить сообщение aMessage с пин-кодом $aPin.
## aOptions.exp — время в минутах сколько хранить сообщение
  $self.cleanMethodArgument[]
  $result[^hash::create[]]
  $lRes[^self._request[message/$aToken/$aPin;GET]]
  ^if($lRes.status eq "200" && ^lRes.[CONTENT-TYPE].match[application/json][in]
  ){
#   Загрузили сообщение
    $lData[^json:parse[^taint[as-is][$lRes.text]]]
    $result.token[$lData.token]
    $result.message[$lData.message]
  }($lRes.status eq "400"
    || $lRes.status eq "404"
  ){
#   Ошибка при загрузке
    ^if(^lRes.[CONTENT-TYPE].match[application/json][in]){
      $lData[^json:parse[^taint[as-is][$lRes.text]]]
      $lError[$lData.error]
    }
    ^throw[$self._exceptionType;$lError]
  }

@ping[] -> [bool]
## Сделать пинг сервиса
  $result(false)
  $lRes[^self._request[ping;GET]]
  $result($lRes.status eq "200")

@params[] -> [$.minExpMin $.maxPinAttempts $.minPinSize]
# Вернуть дефолтные параметры сервиса
  $result[^hash::create[]]
  $lRes[^self._request[params;GET]]
  ^if($lRes.status eq "200"
    && ^lRes.[CONTENT-TYPE].match[application/json][in]
  ){
     $lData[^json:parse[^taint[as-is][$lRes.text]]]
     $result.minExpMin[$lData.min_exp_min]
     $result.maxPinAttempts[$lData.max_pin_attempts]
     $result.minPinSize[$lData.min_pin_size]
  }

@_request[aResource;aMethod;aForm] -> [file]
## aResource
## aMethod[GET]
## aData[hash]
  $result[^pfCFile::load[text;${self._apiURL}/$aResource][
    $.method[^self.ifdef[$aMethod]{GET}]
    $.any-status(true)
    $.timeout($self._timeout)
    ^if(def $aForm){
      $.form[$aForm]
    }
#     $.verbose(true)
#     $.stderr[./curl_api_${aResource}.log]
  ]]
