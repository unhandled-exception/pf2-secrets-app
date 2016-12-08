#!/usr/bin/env parser3

@main[]
  ^CLASS_PATH.append{./}
  ^CLASS_PATH.append{/../vendor/}

  ^use[config/app_config.p]

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
  ]

  $result[^app.run[]]

#--------------------------------------------------------------------------------------------------

@auto[filespec]
## Настраиваем Парсер для автономной работы.

$confdir[^file:dirname[$filespec]]

# Назначаем директорию со скриптом как рут для поиска
$request:document-root[$confdir]

$parserlibsdir[$confdir/../../bin]
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
