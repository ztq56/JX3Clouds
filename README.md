# Jx3App

## Prepare DB
Postgresql should be installed in order to be served as storage backend.
```shell
# after install and start the postgresql
createdb jx3app
```
You should add
```elixir
config :jx3app, Model.Repo,
  database: "jx3app",
  hostname: "localhost",
  port: 5432
```
to your `config/secret.exs`

Don't forget including
```elixir
use Mix.Config
```
at the top of `config/secret.exs`

## Prepare JX3 account
Add to your `config/secret.exs`
```elixir
config :jx3app, API,
  username: "username",
  password: "password"
```

## Compilation
Elixir should be installed in order to compile and run the code.
```shell
# install dependencies
mix deps.get
# create schema in postgresql
mix ecto.migrate
# test
mix test
# run
MIX_ENV=prod mix run --no-halt
```

## Useful commands

1. postgresql
    ```shell
    pg_ctl -D data initdb
    # start/stop/restart
    pg_ctl -D data -o "-p5733" -l postgres.log start
    createdb -p5733 jx3app # dropdb
    pg_dump -Fc -p5733 jx3app > dump.sql
    pg_restore -a -p5733 -djx3app dump.sql --disable-triggers
    psql -p5733 jx3app # -s (step)
    # use "-h/tmp/postgresql" to specific pid folder
    ```
2. redis
    ```shell
    redis-server cache/redis.conf
    redis-cli -p 5734
    redis-cli -p 5734 flushdb
    redis-cli -p 5734 shutdown
    ```