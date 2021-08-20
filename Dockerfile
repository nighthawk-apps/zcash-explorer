FROM elixir:1.12.2-alpine AS build

# install build dependencies
RUN apk add --update --no-cache build-base --update nodejs npm git

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod


COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

COPY assets/package.json  ./assets/
RUN npm install --prefix=assets

# should be before running npm deploy
COPY lib lib
copy rel rel

COPY priv priv
COPY assets assets
RUN npm run deploy --prefix=assets

RUN mix phx.digest
RUN mix do release

# prepare release image
FROM alpine:3.14 AS app
RUN apk add --no-cache openssl ncurses-libs libstdc++ libgcc

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/zcash_explorer ./

ENV HOME=/app

CMD ["bin/zcash_explorer", "start"]
