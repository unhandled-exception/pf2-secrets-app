@USE
controllers/site/interface.p

@CLASS
MaintenanceManager

@BASE
SiteInterfaceModule

@create[aOptions]
## aOptions.conf
  ^BASE:create[
    ^hash::create[$aOptions]
    $.asManager(true)
  ]
  $self.conf[$aOptions.conf]

@onINDEX[aRequest]
  $result[
    $.status[503]
    $.headers[
      $.retry-after[120]
    ]
    $.body[^render[maintenance.pt]]
  ]

@onNOTFOUND[aRequest]
  $result[^onINDEX[$aRequest]]
