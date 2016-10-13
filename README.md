# Spree Webpay Web Services


Integración de Webpay Web Services (Transbank) para Spree 2.1


### Instalación
------------

Añadir spree_tbk_webpay_ws al Gemfile:

```ruby
gem "spree_tbk_webpay_ws", git: 'https://gitlab.acid.cl/fcano/spree_tbk_webpay_ws.git'
```

Instalar dependencias y ejecutar generador:

```shell
bundle
bundle exec rails g spree_tbk_webpay_ws:install
```

Correr migraciones
```shell
bundle exec rake db:migrate
```




### Datos para probar en el ambiente de integración
-------

Tarjetas:

- Crédito Visa (aprobado): 

    - Nº: 4051885600446623
    - Año Expiración: Cualquiera
    - Mes Expiración: Cualquiera
    - CVV: 123

- Crédito Mastercard (rechazado): 

    - Nº: 5186059559590568
    - Año Expiración: Cualquiera
    - Mes Expiración: Cualquiera
    - CVV: 123

-  Tarjeta de débito (aprobado o rechazado):
    - Nº 12345678


Luego autenticar con el RUT **11.111.111-1** y clave **123**
