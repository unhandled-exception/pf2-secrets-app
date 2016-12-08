@conf[filespec]
$confdir[^file:dirname[$filespec]]
$charsetsdir[$confdir/charsets]
$sqldriversdir[$confdir/lib]

$CHARSETS[
#    $.koi8-r[$charsetsdir/koi8-r.cfg]
#    $.windows-1250[$charsetsdir/windows-1250.cfg]
    $.windows-1251[$charsetsdir/windows-1251.cfg]
#    $.windows-1257[$charsetsdir/windows-1257.cfg]
]
#change your client libraries paths to those on your system
$SQL[
    $.drivers[^table::create{protocol	driver	client
mysql	$sqldriversdir/libparser3mysql.so	/usr/local/lib/mysql/libmysqlclient.so
#pgsql	$sqldriversdir/libparser3pgsql.so	-configure could not guess-
#oracle	$sqldriversdir/libparser3oracle.so	-configure could not guess-
#sqlite	$sqldriversdir/libparser3sqlite.so	-configure could not guess-
}]
]

#for ^file::load[name;user-name] mime-type autodetection
$MIME-TYPES[^table::create{ext	mime-type
zip	application/zip
doc	application/msword
xls	application/vnd.ms-excel
pdf	application/pdf
ppt	application/powerpoint
rtf	application/rtf
gif	image/gif
jpg	image/jpeg
jpeg	image/jpeg
png	image/png
tif	image/tiff
html	text/html
htm	text/html
txt	text/plain
xml	text/xml
mts	application/metastream
mid	audio/midi
midi	audio/midi
mp3	audio/mpeg
ram	audio/x-pn-realaudio
rpm	audio/x-pn-realaudio-plugin
ra	audio/x-realaudio
wav	audio/x-wav
au	audio/basic
mpg	video/mpeg
avi	video/x-msvideo
mov	video/quicktime
swf	application/x-shockwave-flash
}]

$LIMITS[
    $.post_max_size(10*0x400*0x400)
]

#$MAIL[
#	$.sendmail[your sendmail command goes here]
#	these are tried when no 'sendmail' specified:
#		/usr/sbin/sendmail -t -i -f postmaster
#		/usr/lib/sendmail -t -i -f postmaster
#]

$ADMIN_EMAIL[]

$DEVELOPERS_IPS[
  $._default(false)
]

@isDeveloper[aIP]
  $result($DEVELOPERS_IPS.[^if(def $aIP){$aIP}{$env:REMOTE_ADDR}])

@fatal_error[title;subtitle;body]
#$response:status(500)
#$response:content-type[
#  $.value[text/html]
#  $.charset[$response:charset]
#]
<html>
<head><title>$title</title></head>
<body>
<H1>^if(def $subtitle){$subtitle;$title}</H1>
$body
#for [x] MSIE friendly
^for[i](0;512/8){<!-- -->}
</body>

@unhandled_exception_debug[exception;stack][lLink]
  ^fatal_error[Unhandled Exception^if(def $exception.type){ ($exception.type)};$exception.source ($exception.type);
    <pre>^untaint[html]{$exception.comment}</pre>
    ^if(def $exception.file){
      ^untaint[html]{<tt>$exception.file^(${exception.lineno}:$exception.colno^)</tt>}
    }
    ^if($stack){
      <hr>
      <table>
      ^stack.menu{
        <tr><td>$stack.name</td><td><tt>$stack.file^(${stack.lineno}:$stack.colno^)</tt></tr>
      }
      </table>
    }
    <hr>
    $lLink[http^if($env:HTTPS eq "on"){s}://${env:SERVER_NAME}$request:uri]
    <p><a href="$lLink">$lLink</a></p>
  ]

@unhandled_exception_release[exception;stack]
^fatal_error[<p>The server encountered an unhandled exception
and was unable to complete your request.</p>
<p>Please contact the server administrator, $env:SERVER_ADMIN
and inform them of the time the error occurred,
and anything you might have done that may have caused the error.</p>
<p>More information about this error may be available in the Parser error log
or in debug version of unhandled_exception.</p>
]

@unhandled_exception[exception;stack]
#use debug version to see problem details
$response:content-type[
         $.value[text/html]
         $.charset[$response:charset]
]
^if(^isDeveloper[$env:REMOTE_ADDR]){
  ^unhandled_exception_debug[$exception;$stack]
}{
   ^switch[$exception.type]{
     ^case[DEFAULT]{$response:location[/500.htm]}
   }
   ^sendExceptionToAdmin[$exception;$stack]
 }

@sendExceptionToAdmin[aException;aStack]
^try{
  ^mail:send[
    $.from[$env:SERVER_NAME <$ADMIN_EMAIL>]
    $.to[$ADMIN_EMAIL]
    $.subject[Error on $env:SERVER_NAME ($env:REMOTE_ADDR)]
    $.html{
       ^unhandled_exception_debug[$aException;$aStack]
    }
  ]
}{
   $exception.handled(true)
 }

@auto[]
#source/client charsets
$request:charset[utf-8]
$response:charset[utf-8]

$response:content-type[
    $.value[text/html]
    $.charset[$response:charset]
]

$CLASS_PATH[^table::create[nameless]{
/../../../vendor
/../../
}]
