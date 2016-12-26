@USE
pf2/lib/console/console_app.p
pf2/lib/sql/models/structs.p

@CLASS
SQLCommand

## Команда manage.p sql

@OPTIONS
locals

@BASE
pfConsoleCommandWithSubcommands

@auto[aFilespec]
  $self.SQL_COMMAND_ROOT[^file:dirname[$aFilespec]]

@create[aOptions]
## aOptions.sql — ссылка на класс соединение с БД.
  ^self.cleanMethodArgument[]
  ^BASE:create[$aOptions]
  ^pfModelChainMixin:mixin[$self;$aOptions]

  $self.binPath[commands/bin]
  $self.mysqldumpBin[$self.binPath/mysqldump]

  $lParsed[^pfString:parseURL[$CSQL.connectString]]
  $self.sqlServer[
    $.type[$lParsed.protocol]
    $.schema[^lParsed.path.trim[both;/]]
    $.host[$lParsed.host]
    $.port[$lParsed.port]
    $.user[$lParsed.user]
    $.password[$lParsed.password]
  ]

  ^self.assignSubcommand[schema;$schema;
    $.help[Dump a database schema.]
  ]
  ^self.assignSubcommand[settings;$settings][
    $.help[Show connection settings.]
  ]

@schema[aAgrs;aSwitches]
  $lExec[^file::exec[$self.mysqldumpBin;;-dR;--skip-comments;--user=$self.sqlServer.user;--password=$self.sqlServer.password;$self.sqlServer.schema]]
  ^self.print[^lExec.text.match[\sauto_increment=\d+][ig][]]

@settings[aArgs;aSwitches]
  ^self.print[SQL settings]
  ^self.print[  type:     $self.sqlServer.type]
  ^self.print[  host:     $self.sqlServer.host^if(def $self.sqlServer.port){:$self.sqlServer.port}]
  ^self.print[  user:     $self.sqlServer.user]
  ^self.print[  password: $self.sqlServer.password]
  ^self.print[  schema:   $self.sqlServer.schema]
