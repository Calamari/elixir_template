# Boilerplate

This tempalte is my boilerplate to start new Elixir projects. It should contain authentication, Bamboo powered Emails and a release strategy for fly.io.

## Usage

Call ./setup_boilerplate.sh with your desired app naming, like `./setup_boilerplate.sh MyGreatApp`. And then look into to Makefile to see a nice variety of things you can do.

There is also a local database server provided using docker:

```sh
docker-compose up -d
```

But to run everything in development mode just run:

```sh
make dev
```
