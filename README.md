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

## First run

### Create running system

First we need a database:

```sh
docker-compose up -d
mix.ecto.migrate
```

### Creating an admin user

To create an admin user, you can run the following task:

```sh
mix dance_comm.create_admin your@email.io "Your Name" passw0rd
```

### Prepare frontend:

```sh
npm i --prefix assets
```

### Run Test server

```sh
make start # or dev
```
