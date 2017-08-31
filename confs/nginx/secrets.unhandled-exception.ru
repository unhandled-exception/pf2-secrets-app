    server {
        listen       443 ssl http2;
        server_name  secrets.unhandled-exception.ru;

        ssl_certificate      /etc/dehydrated/certs/secrets.unhandled-exception.ru/fullchain.pem;
        ssl_certificate_key  /etc/dehydrated/certs/secrets.unhandled-exception.ru/privkey.pem;

        include sites-available/_ssl.defaults;

        access_log /home/pf2/secrets.unhandled-exception.ru/logs/secrets.nginx.access.443.log;
        error_log /home/pf2/secrets.unhandled-exception.ru/logs/secrets.nginx.error.443.log;

        error_page   500 502 503 504  /500.htm;
        error_page   401 /403.htm;
        error_page   403 /403.htm;

        client_max_body_size 100m;

        location / {
            root /home/pf2/secrets.unhandled-exception.ru/app/public/site;
            try_files $uri @pf2_backend;

            location ~ \.(htm)$ {
                charset utf-8;
            }

            location ~ "^/(assets)" {
                expires +1y;
                charset utf-8;
            }
        }

        location @pf2_backend {
            root /home/pf2/secrets.unhandled-exception.ru/app/public/site;

            fastcgi_pass unix:/var/run/fcgiwrap_pf2.socket;
            fastcgi_read_timeout 600s;
            fastcgi_param  SCRIPT_NAME  $request_uri;
            fastcgi_param  SCRIPT_FILENAME  /home/pf2/secrets.unhandled-exception.ru/cgi-bin/parser3.cgi;
            fastcgi_param  PATH_INFO    /_ind.html;
            fastcgi_param  PATH_TRANSLATED /home/pf2/secrets.unhandled-exception.ru/app/public/site/index.html;
            fastcgi_param  PWD $document_root;

            fastcgi_param  CGI_PARSER_CONFIG /home/pf2/secrets.unhandled-exception.ru/cgi-bin/auto.p;

            include fastcgi_params;
        }

        location /index.html {
            deny all;
        }
    }
