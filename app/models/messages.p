@CLASS
CoreMessages

## Сообщения

@BASE
pfModelTable

@OPTIONS
locals

@create[aOptions]
## aOptions.tableName
  ^BASE:create[^hash::create[$aOptions]
    $.tableName[^ifdef[$aOptions.tableName]{messages}]
#    $.allAsTable(true)
  ]

# Список полей в таблице messages в БД
  ^self.addFields[
    $.messageID[$.plural[messages] $.dbField[message_id] $.primary(true) $.widget[none]]
    $.token[$.label[] $.processor[uid] $.widget[none]]
    $.data[$.label[Текст] $.widget[textarea]]
    $.pinHash[$.dbField[pin_hash] $.label[Пин-код] $.processor[_pin]]
    $.expiredAt[$.dbField[expired_at] $.label[Время жизни сообщения] $.processor[datetime]]
    $.errors[$.processor[uint] $.default[0] $.label[] $.widget[none]]
    $.createdAt[$.dbField[created_at] $.processor[auto_now] $.skipOnUpdate(true) $.widget[none]]
    $.updatedAt[$.dbField[updated_at] $.processor[auto_now] $.widget[none]]
  ]

@stat[] -> [$.total $.expired $.active]
## Возвращает статистику сообщений
  $result[^self.aggregate[
    count(*) as total;
    sum(case when $self.expiredAt <= '^self._now.sql-string[]' then 1 else 0 end) as expired;
    sum(case when $self.expiredAt > '^self._now.sql-string[]' then 1 else 0 end) as active;
    $.asTable(true)
  ]]
  $result[$result.fields]

@cleanup[aOptions] -> [table: messageID, token, expiredAt]
## Удаляет из базы данных все «устаревшие» сообщения
## aOptions.all(false) — удалить все сообщения
  ^cleanMethodArgument[]
  $result[]
  ^CSQL.transaction{
    $result[^self.aggregate[
      _fields(messageID, token, expiredAt)
    ][
      ^if(!^aOptions.all.bool(false)){
        $.[expiredAt <=][$self._now]
      }
      $.tail[for update]
      $.groupBy[$.messageID[asc]]
      $.asTable(true)
    ]]
    ^if($result){
      ^self.deleteAll[
        $.messages[$result]
      ]
    }
  }

@cleanFormData[aFormData]
## Проверяет форму перед сохранением в БД
  $result[^BASE:cleanFormData[$aFormData]]

# Проверяем сообщение
  $result.data[^result.data.trim[]]
  ^if(!def $result.data){
    ^throw[core.messages.empty.data;Введите сообщение]
  }

# Проверяем дилну пин-кода
  $result.pinHash[^result.pinHash.trim[]]
  ^if(^result.pinHash.length[] < $core.conf.minPinSize){
    ^throw[core.messages.invalid.pin;Длина пин-кода должна быть не менее $core.conf.minPinSize символов]
  }

# Обрабатываем TTL и выставляем дефолтное значение, если из формы пришла ерунда
# Не стал делать исключение, чтобы показать для чего можно применять cleanFormData
  $result.expiredAt[^result.expiredAt.trim[]]
  $result.expiredAt(^math:abs(^result.expiredAt.double($core.conf.defaultMessageTTL)))
  ^if($result.expiredAt <= 0){
    $result.expiredAt($core.conf.defaultMessageTTL)
  }
  $result.expiredAt[^date::create($_now + $result.expiredAt/(24*60))]

@save[aData] -> [$.messageID $.token $.expiredAt]
## Сохраняет сообщение в базе данных
  $result[^hash::create[]]
  $aData[^self.cleanFormData[$aData]]
  ^CSQL.transaction{
    $result.messageID[^self.new[
      $.pinHash[$aData.pinHash]
      $.data[^self.encryptDataField[$aData.data;$aData.pinHash]]
      $.expiredAt[$aData.expiredAt]
    ]]

    $lMessage[^self.get[$result.messageID]]
    $result.expiredAt[$lMessage.expiredAt]
    $result.token[$lMessage.token]
  }

@load[aToken;aPin] -> [$.token $.text $.errors]
## Достает сообщение из базы данных, расшифровывает, проверяет пин-код
  $result[]
  $lError[]
  ^CSQL.transaction{
    ^try{
#     Достаем сообщеине и блокируем строку в базе данных
      $lMessage[^self.one[
        $.token[$aToken]
        $.tail[for update]
        $.[expiredAt >][^date::now[]]
      ]]
      ^if(!$lMessage){^throw[message.not.found;Сообщение не найдено]}

      ^if($lMessage.pinHash ne ^_makePinHash[$aPin;$lMessage.pinHash]){
#       Неверный пин-код
        $lMessage.errors($lMessage.errors + 1)
        ^if($lMessage.errors < $core.conf.maxPinAttempts){
          ^self.modify[$lMessage.messageID;
            $.errors($lMessage.errors)
          ]
          ^throw[message.invalid.pin;Введен неверный пин-код]
        }{
           ^self.delete[$lMessage.messageID]
           ^throw[message.deleted;Сообщение удалено. Несколько раз введен неверный пин-код.]
         }
      }

#     Расшифровываем и удаляем сообщение из базы данных
      $result[
        $.token[$lMessage.token]
        $.text[^self.decryptDataField[$lMessage.data;$aPin]]
      ]
      ^self.delete[$lMessage.messageID]
    }{
        ^if(^exception.type.match[^^message\.][n]){
          $exception.handled(true)
          $result[
            $.error[
              $.type[$exception.type]
              $.source[$exception.source]
              $.comment[$exception.comment]
            ]
          ]
        }
     }
  }

@encryptDataField[aData;aPin] -> [string]
## Шифрует текст сообщения с использованием pin-кода
  $result[^core.security.encrypt[$aData][
    $.cryptKey[^core.security.digest[${aPin}${core.security.cryptKey}]]
  ]]

@decryptDataField[aData;aPin] -> [string]
## Расшифровывает текст сообщения с использованием pin-кода
  $result[^core.security.decrypt[$aData][
    $.cryptKey[^core.security.digest[${aPin}${core.security.cryptKey}]]
  ]]

@fieldValue[aField;aValue]
## Добавляет обработку процессора _pin для поля pinHash
  $result[]
  ^switch[$aField.processor]{
    ^case[_pin]{
      $result['^taint[^_makePinHash[$aValue]]']
    }
    ^case[DEFAULT]{$result[^BASE:fieldValue[$aField;$aValue]]}
  }

@_makePinHash[aPin;aSalt]
## Хешируем пароль через crypt. Если система умеет, то используем Blowfish
## К пину добавляем «локальный параметр», который не храним в БД.
## https://habrahabr.ru/post/210760/

# Хешируем пароль в sha512, чтобы уменьшить риск dos-атаки.
# http://arstechnica.com/security/2013/09/long-passwords-are-good-but-too-much-length-can-be-bad-for-security/
  $lPinString[^math:digest[sha512;${aPin}${core.security.secretKey};$.format[base64]]]

  ^unsafe{
    ^pfAssert:fail[stop]
#   Пробуем хешировать через системный bcrypt (Blowfish). Есть во FreeBSD
    $result[^math:crypt[$lPinString;^self.ifdef[$aSalt]{^$2b^$10^$^math:uid64[]^math:uid64[]}]]
  }{
#    Если bcrypt нет, то хешируем стандартным способом
     $result[^math:crypt[$lPinString;^self.ifdef[$aSalt]{^$apr1^$}]]
   }
