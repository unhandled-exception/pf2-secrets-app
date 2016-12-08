@USE
controllers/site/interface.p

@CLASS
MaintenanceManager

@BASE
SiteInterfaceModule

@create[aOptions]
  ^BASE:create[$aOptions]

@onINDEX[aRequest]
  $self.title[$core.conf.siteName]
  $result[
    $.status[503]
    $.headers[
      $.retry-after[120]
    ]
    $.body[^render[maintenance.pt]]
  ]

@onNOTFOUND[aRequest]
  $result[^onINDEX[$aRequest]]
