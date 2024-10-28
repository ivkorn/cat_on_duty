# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian
# instead of Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye-20240812-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: hexpm/elixir:1.17.2-erlang-27.0.1-debian-bullseye-20240812-slim
#
ARG ELIXIR_VERSION=1.17.3
ARG OTP_VERSION=27.1.2
ARG NODEJS_VERSION=20.18
ARG DEBIAN_VERSION=bookworm
ARG DEBIAN_DATE=20241016

ARG ASSETS_BUILDER_IMAGE="node:${NODEJS_VERSION}-${DEBIAN_VERSION}-slim"
ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}-${DEBIAN_DATE}-slim"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${ASSETS_BUILDER_IMAGE} AS assets_builder

WORKDIR /app

ENV NODE_ENV="prod"

COPY assets assets
COPY esbuild esbuild
COPY package.json package-lock.json ./

RUN npm install --omit=dev

RUN npm run build

FROM ${BUILDER_IMAGE} AS builder

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git libsqlite3-dev \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod" \
  EXQLITE_USE_SYSTEM="1"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv

COPY lib lib

COPY --from=assets_builder /app/priv/static/assets ./priv/static/assets

# digest assets
RUN mix phx.digest

# Compile the release
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
COPY .iex.exs rel/overlays/bin/.iex.exs
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

RUN apt-get update -y && \
  apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates libsqlite3-dev \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && sed -i '/ru_RU.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG="ru_RU.UTF-8" \
  LANGUAGE="ru_RU:ru" \
  LC_ALL="ru_RU.UTF-8"

WORKDIR "/app"
# RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
# COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/cat_on_duty ./
COPY --from=builder /app/_build/${MIX_ENV}/rel/cat_on_duty ./

# USER nobody

# If using an environment that doesn't automatically reap zombie processes, it is
# advised to add an init process such as tini via `apt-get install`
# above and adding an entrypoint. See https://github.com/krallin/tini for details
# ENTRYPOINT ["/tini", "--"]

CMD ["/app/bin/server"]
