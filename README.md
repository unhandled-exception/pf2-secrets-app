# pf2-secrets-app

Пример приложения на языке Парсер 3 и [фреймворком PF2](https://github.com/unhandled-exception/pf2). Идея взята из проекта https://github.com/umputun/secrets.

Сайт помогает пользователям передавать секретные сообщения коллегам и друзьям через интернет. Сообщение защищаем пин-кодом и уничтожаем как только получатель откроет ссылку и введет правильный пин-код.

## Принцип работы

Приложение работает на сайте https://secrets.unhandled-exception.ru/

Вводим на сайте секретное сообщение и пин-код. Указываем сколько минут сообщение доступно получателю. Секретную ссылку пересылаем коллеге по почте или через чат. Пин-код расскажем по телефону или пошлем эсэмэской. Коллега откроет сайт по ссылке, введет пин-код и увидит сообщение. Сообщение покажем один раз и сразу сотрем из базы данных.

Не отправляйте ссылку и пин-код в двух письмах по электронной почте или двумя сообщениями в одном и том же чате.

## Безопасность

* Шифруем сообщение пин-кодом перед тем как сохранить в базу данных. Для пин-кода храним хеш из которого невозможно восстановить пин.
* Не сохраняем сообщения и пин-коды в логи веб-сервера.
* Сообщение удалим сразу после просмотра. Спрашиваем сколько минут хранить сообщение и удалим сообщение, когда время прошло и сообщение не прочитали.

## API

Для программистов на сайте работает REST API, чтобы сохранить и загрузить сообщение из программы.

### Зашифровать и сохранить сообщение на сервере

`POST /api/v1/message`, body - `pin=12345&message=testtest-12345678&exp=15`
- `message` сообщение
- `exp` время жизни сообщения в минутах
- `pin` пин-код

```
$ http --form POST https://secrets.unhandled-exception.ru/api/v1/message pin=12345 message=testtest-12345678 exp=15

HTTP/1.1 201 Created

{
  "exp": "2016-12-13T22:01:25+03:00",
  "token": "109a943d-c254-4306-bdab-2afaac78e94f"
}
```

### Загрузить сообщение

`GET /api/v1/message/:token/:pin`

```
$ http GET https://secrets.unhandled-exception.ru/api/v1/message/109a943d-c254-4306-bdab-2afaac78e94f/12345

HTTP/1.1 200 OK

{
  "token": "109a943d-c254-4306-bdab-2afaac78e94f",
  "message": "testtest-12345678"
}
```

### Пинг

`GET /api/v1/ping`

```
$ http https://secrets.unhandled-exception.ru/api/v1/ping

HTTP/1.1 200 OK

pong
```

### Получить настройки сервиса

`GET /api/v1/params`

```
$ http https://secrets.unhandled-exception.ru/api/v1/params

HTTP/1.1 200 OK

{
  "min_exp_min": 10,
  "max_pin_attempts": 3,
  "min_pin_size": 5
}
```

## Библиотека API для Парсера

Класс ueSecretsAPI лежит в [./lib/secrets_api.p](/lib/secrets_api.p). Пример работы с классом смотрите в [./lib/secrets_api_test.p](/lib/secrets_api_test.p).
