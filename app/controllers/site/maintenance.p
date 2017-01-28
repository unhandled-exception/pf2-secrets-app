@USE
controllers/site/interface.p


@CLASS
MaintenanceManager

## Контролер для режима техобслуживания
## Выдает на все запросы 503-ошибку

@BASE
SiteInterfaceModule

@create[aOptions]
## aOptions.conf
  ^BASE:create[
    ^hash::create[$aOptions]
    $.asManager(true)
  ]
  $self.conf[$aOptions.conf]

@/DEFAULT[aRequest]
  $result[
    $.status[503]
    $.headers[
      $.retry-after[120]
    ]
    $.body[^render[maintenance.pt]]
  ]
