@CLASS
CoreMessages

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

  ^self.addFields[
    $.messageID[$.dbField[message_id] $.primary(true) $.widget[none]]
    $.data[$.label[Текст] $.widget[textarea]]
    $.pinHash[$.dbField[pin_hash] $.label[Пин-код]]
    $.expiredAt[$.dbField[expired_at] $.label[Время жизни сообщения]]
    $.errors[$.processor[uint] $.default[0] $.label[] $.widget[none]]
    $.createdAt[$.dbField[created_at] $.processor[auto_now] $.skipOnUpdate(true) $.widget[none]]
    $.updatedAt[$.dbField[updated_at] $.processor[auto_now] $.widget[none]]
  ]
