@USE
pf2/lib/sql/models/structs.p
pf2/lib/security/sql_security.p


## Модель данных сайта

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

  ^assignModule[messages;models/messages.p@CoreMessages]

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

@digest[aString;aOptions]
## Возвращает криптографический хеш строки
## aOptions.format[_serializer]
## aOptions.algorythm[_hashAlgorythm]
## aOptions.hmac[_secretKey]
  $result[^math:digest[^self.ifdef[$aOptions.algorythm]{$self._hashAlgorythm};$aString;
    $.format[^self.ifdef[$aOptions.format]{$self._serializer}]
    $.hmac[^self.ifdef[$aOptions.hmac]{$self._secretKey}]
  ]]
