#!/usr/bin/env parser3

@main[]
  ^CLASS_PATH.append{./app}
  ^CLASS_PATH.append{./vendor/}

  ^use[app/config/app_config.p]
  ^pfClass:unsafe{
    ^use[app/config/local_config.p]
  }

  $csql[^pfSQLConnection::create[$CONF.connectString;
    $.enableMemoryCache(true)
#    $.enableQueriesLog(true)
  ]]
  $core[^Core::create[
    $.conf[$CONF]
    $.sql[$csql]
  ]]

  ^use[pf2/lib/console/console_app.p]
  $app[^pfConsoleApp::create[]]

  ^app.assignCommand[generate][
    pf2/lib/console/commands/generate.p@pfConsoleGenerateCommand
  ][
    $.sql[$csql]
    $.core[$core]
    $.formWidgets[bs4v]
  ]

  ^app.assignCommand[secrets;commands/secrets.p@SecretsCommand;
    $.core[$core]
    $.sql[$csql]
  ]

  ^app.assignCommand[sql;pf2/lib/console/commands/mysql.p@pfMySQLCommand;
    $.sql[$csql]
  ]

  $result[^app.run[]]

#--------------------------------------------------------------------------------------------------

@auto[filespec]
## Настраиваем Парсер для автономной работы.

$confdir[^file:dirname[$filespec]]

# Назначаем директорию со скриптом как рут для поиска
$request:document-root[$confdir]

$parserlibsdir[$confdir/../bin]
$charsetsdir[$parserlibsdir/charsets]
$sqldriversdir[$parserlibsdir/lib]

$CHARSETS[
#    $.koi8-r[$charsetsdir/koi8-r.cfg]
#    $.windows-1250[$charsetsdir/windows-1250.cfg]
    $.windows-1251[$charsetsdir/windows-1251.cfg]
#    $.windows-1257[$charsetsdir/windows-1257.cfg]
    $.iso-8859-1[$charsetsdir/windows-1250.cfg]
]

$SQL[
	$.drivers[^table::create{protocol	driver	client
mysql	$sqldriversdir/libparser3mysql.so	libmysqlclient.so
}]
]

$CLASS_PATH[^table::create{path}]

@unhandled_exception[exception;stack]
# Показываем сообщение об ошибке
Unhandled Exception^if(def $exception.type){ ($exception.type)}
Source: $exception.source
Comment: $exception.comment
^if(def $exception.file){File: $exception.file ^(${exception.lineno}:$exception.colno^)}
^if($stack){
Stack trace:
^stack.menu{$stack.name^#09$stack.file ^(${stack.lineno}:$stack.colno^)}[^#0A]
}
