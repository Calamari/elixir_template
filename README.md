# MyApp

This tempalte is my my_app to start new Elixir projects. It should contain authentication, Bamboo powered Emails and a release strategy for fly.io.

## Usage

Call ./setup_my_app.sh with your desired app naming, like `./setup_my_app.sh MyGreatApp`. And then look into to Makefile to see a nice variety of things you can do.

There is also a local database server provided using docker:

```sh
docker-compose up -d
```

But to run everything in development mode just run:

```sh
make dev
```
