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
    $.token[$.label[] $.processor[uid] $.widget[none]]
    $.data[$.label[Текст] $.widget[textarea]]
    $.pinHash[$.dbField[pin_hash] $.label[Пин-код] $.processor[_pin]]
    $.expiredAt[$.dbField[expired_at] $.label[Время жизни сообщения] $.processor[datetime]]
    $.errors[$.processor[uint] $.default[0] $.label[] $.widget[none]]
    $.createdAt[$.dbField[created_at] $.processor[auto_now] $.skipOnUpdate(true) $.widget[none]]
    $.updatedAt[$.dbField[updated_at] $.processor[auto_now] $.widget[none]]
  ]

@save[aData] -> [$.messageID $.token $.expiredAt]
## Созраняет сообщение в базе данных
  $result[^hash::create[]]
  $aData[^self.cleanFormData[$aData]]
  ^CSQL.transaction{
    $result.messageID[^self.new[
      $.pin[$aData.pinHash]
      $.data[^self.encryptDataField[$aData.data;$aData.pinHash]]
      $.expiredAt[^date::create($_now + $aData.expiredAt/(24*60))]
    ]]

    $lMessage[^self.get[$result.messageID]]
    $result.expiredAt[$lMessage.expiredAt]
    $result.token[$lMessage.token]
  }

@encryptDataField[aData;aPin] -> [string]
## Шифрует текст сообщения с использованием pin-кода
  $result[^core.security.encrypt[$aData][
    $.cryptKey[^core.security.digest[${core.security.cryptKey}$aPin]]
  ]]

@decryptDataField[aData;aPin] -> [string]
## Расшифровывает текст сообщения с использованием pin-кода
  $result[^core.security.decrypt[$aData][
    $.cryptKey[^core.security.digest[${core.security.cryptKey}$aPin]]
  ]]

@fieldValue[aField;aValue]
  $result[]
  ^switch[$aField.processor]{
    ^case[_pin]{
      $result['^taint[^core.security.digest[$aValue]]']
    }
    ^case[DEFAULT]{$result[^BASE:fieldValue[$aField;$aValue]]}
  }
