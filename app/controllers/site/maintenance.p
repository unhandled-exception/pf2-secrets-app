@USE
controllers/site/interface.p


## Контролер для режима обслуживания
## Выдает на все запросы 503-ошибку

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
