#!/usr/bin/env parser3

@auto[filespec]
  $request:document-root[^file:dirname[$filespec]]
  $CLASS_PATH[^table::create{path}]
  ^CLASS_PATH.append{./}
  ^CLASS_PATH.append{/../vendor/}

@main[][locals]
  ^use[secrets_api.p]

  $message[Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc scelerisque ex eros, sit amet sollicitudin ex pharetra nec. Ut condimentum blandit neque, eu luctus magna sodales sed. Sed auctor vulputate ante, at facilisis metus mattis ut. Pellentesque interdum ornare dolor, in imperdiet magna tincidunt eget. Donec tincidunt gravida dictum. Curabitur egestas diam egestas imperdiet elementum. Fusce nec condimentum metus. Etiam vestibulum dui ut est viverra gravida. Praesent vitae euismod elit. Integer euismod aliquet tellus, vel consectetur quam sodales et. Morbi ornare, lacus ac molestie convallis, elit turpis faucibus mauris, in lobortis augue sem id velit. Pellentesque sem est, dapibus a fermentum non, laoreet ac urna.]
  $pin[^math:uid64[]]
  $exp[15]

  $api[^ueSecretsAPI::create[]]

  Ping: ^if(^api.ping[]){true}{false}

  $params[^api.params[]]
  Params: ^if($params){^params.foreach[k;v]{$k -> $v}[, ]}{none}

  $stored[^api.save[$message;$pin;$.exp[$exp]]]
  Save message: $stored.token, $stored.expiredAt

  $loaded[^api.load[$stored.token;$pin]]
  Load message: $loaded.token, message is ^if($message eq $loaded.message){correct}{incorrect}

@postprocess[aBody]
  $result[^aBody.match[(?:\n\s*\n)+][gx][^#0A]^#0A]
