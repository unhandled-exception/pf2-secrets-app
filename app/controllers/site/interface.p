@USE
pf2/lib/web/controllers.p


@CLASS
SiteInterfaceModule

@BASE
pfController

@create[aOptions]
## aOptions.core
## aOptions.antiFlood
## aOptions.formater
## aOptions.isDebug(false)
  ^BASE:create[$aOptions]

  $self.isDebug(^aOptions.isDebug.bool(false))
  $self.core[$aOptions.core]

  $self.antiFlood[$aOptions.antiFlood]
  ^if(!^template.context.contains[antiFlood]){
    ^template.assign[antiFlood;$antiFlood]
  }

  $self._title[]

@SET_title[aTitle]
  $self._title[$aTitle]
  ^assignVar[title;$self._title]

@GET_title[]
  $result[$self._title]

@assignModule[aName;aClassDef;aOptions]
  ^cleanMethodArgument[]
  $aOptions[^hash::create[$aOptions]]
  $aOptions[^aOptions.union[
    $.core[$self.core]
    $.isDebug($self.isDebug)
  ]]
  $result[^BASE:assignModule[$aName;$aClassDef;$aOptions]]
