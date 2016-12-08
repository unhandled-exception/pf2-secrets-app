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
