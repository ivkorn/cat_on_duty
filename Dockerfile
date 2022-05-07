# ---- Build Stage ----
FROM elixir:1.10.0-alpine AS build

# install build dependencies
RUN apk add --no-cache build-base npm git

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ARG MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

# build assets
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

COPY priv priv
COPY assets assets
RUN npm run --prefix ./assets deploy
RUN mix phx.digest

# compile and build release
COPY lib lib
COPY priv priv
RUN mix do compile, release


# ---- Application Stage ----
FROM alpine AS app
RUN apk add --no-cache openssl ncurses-libs postgresql-client

WORKDIR /app

COPY --from=build /app/_build/prod/rel/cat_on_duty ./
COPY entrypoint.sh .

CMD ["./entrypoint.sh"]
