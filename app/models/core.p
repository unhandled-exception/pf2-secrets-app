@USE
pf2/lib/sql/models/structs.p
pf2/lib/security/sql_security.p


@CLASS
Core

@BASE
pfModelModule

@create[aOptions]
## aOptions.conf
## aOptions.conf.secretKey
## aOptions.conf.cryptKey
  ^cleanMethodArgument[]
  ^BASE:create[$aOptions]

  $self.conf[$aOptions.conf]

  ^assignModule[security;CoreSecurity;
    $.secretKey[$conf.secretKey]
    $.cryptKey[$conf.cryptKey]
    $.serializer[base64]
  ]

  ^assignModule[messages;CoreMessages]

#--------------------------------------------------------------------------------------------------

@CLASS
CoreSecurity

## Шифрование и работа с токенами.

@BASE
pfSQLSecurityCrypt

@create[aOptions]
  ^cleanMethodArgument[]
  ^BASE:create[$aOptions]
  ^pfModelChainMixin:mixin[$self;^hash::create[$aOptions] $.ignoreSQLFields(true)]

#--------------------------------------------------------------------------------------------------

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
