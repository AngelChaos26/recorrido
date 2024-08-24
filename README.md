Recorrido
=====================

Esto es el proyecto como parte del proceso de seleccion, los comentarios y procesos estan establecidos en Ingles.

Instalacion
------------

Al descargar la aplicacion, siga los siguientes pasos:

Correr `bundle install`.

Cree la base de datos tanto de `development` como de `test`, tome en cuenta que estas base de datos fueron creadas en `sqlite3`.

Una vez creadas, corra el archivo `seed`

```shell
bundle exec rails db:seed
```
Se deberia de llenar la aplicacion con la informacion necesaria para empezar, antes de correr la aplicacion, ejecute el siguiente comando la consola de ruby para correr el `servicio`:

```ruby
MonitoringEngineersService.call(Company.first, Date.current.beginning_of_week.strftime("%m-%d-%Y"))
```
La aplicacion fur implementada usando las siguientes tecnologias:

* `Tailwind`
* `Stimulus.js`
* `rubocop`
* `Rspec`
* `FactoryBot`
* `Faker`

Cualquier duda favor de contactarme!!!



