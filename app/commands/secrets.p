@USE
pf2/lib/console/console_app.p
pf2/lib/sql/models/structs.p

@CLASS
SecretsCommand

@OPTIONS
locals

@BASE
pfConsoleCommandWithSubcommands

@create[aOptions]
## aOptions.sql — ссылка на класс соединение с БД.
  ^self.cleanMethodArgument[]
  ^BASE:create[$aOptions]
  ^pfModelChainMixin:mixin[$self;$aOptions]

  ^self.assignSubcommand[stat;$stat;
    $.help[Print messages statistics.]
  ]

  ^self.assignSubcommand[cleanup [--all];$cleanup;
    $.help[Cleanup expired messages.]
  ]

@stat[aArgs;aSwitches]
  $lStat[^core.messages.stat[]]
  ^self.print[$lStat.total messages, ^lStat.active.int(0) active, ^lStat.expired.int(0) expired]

@cleanup[aArgs;aSwitches]
  $lDeleted[^core.messages.cleanup[
    $.all(^aSwitches.contains[all])
  ]]
  $lNow[^date::now[]]
  ^self.print[[^lNow.sql-string[]] ^lDeleted.count[] expired messages was deleted.]
  ^lDeleted.foreach[_;v]{
    ^self.print[${v.messageID}: $v.token, $v.expiredAt]
  }
