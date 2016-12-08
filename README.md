# pf2-secrets-app

Пример приложения на PF2. Не хочу делать очередной блог. Напишем клон проекта https://github.com/umputun/secrets для секретного обмена сообщениями через инет. Оригинал написан на Go. Напишем приложение на Парсере с фреймворком pf2.

Сайт помогает пользователям безопасно передавать сообщения коллегам и друзьям. Сообщение защищаем пин-кодом и уничтожаем как только получатель откроет ссылку и введет правильный пин-код.

## Принцип работы

Вводите на сайте секретное сообщение и пин-код. Указываете сколько минут сообщение будет доступно получателю. Секретную ссылку пересылаем коллеге по почте или через чат. Пин-код передадим скажем по телефону или пошлем эсэмэской. Не отправляйте ссылку и пин-код в двух письмах по электронной почте или двумя сообщениями в одном и том же чате.

Коллега откроет сайт по ссылке, введет пин-код и увидит сообщение. Сообщение покажем один раз и сразу сотрем из базы данных.

## Безопасность

* Шифруем сообщение пин-кодом перед тем как сохранить в базу данных. Для пин-кода храним хеш из которого невозможно восстановить пин.
* Не сохраняем сообщения и пин-коды в логи веб-сервера.
* Сообщение удалим сразу после просмотра получателем. Спрашиваем сколько минут хранить сообщение. Удалим сообщение, когда время прошло и сообщение не прочитали.

## API

На сайте сделаем REST API для работы с сообщениями.
