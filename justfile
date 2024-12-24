set dotenv-load := true

setup-backend:
    mix do deps.get, deps.compile, compile

setup-frontend:
    npm install

setup:
    @just setup-backend
    @just setup-frontend

check-formated:
    mix format --check-formatted

credo:
    mix credo

plts-create:
    mix dialyzer --plt

dialyzer-ci:
    mix dialyzer --format github

dialyzer:
    mix dialyzer --quiet-with-result

lint-backend:
    @just check-formated
    @just credo
    @just dialyzer

eslint:
    npx eslint .

stylelint:
    npx stylelint assets/**/*.scss

lint-frontend:
    @just eslint
    @just stylelint

lint:
    @just lint-frontend
    @just lint-backend

audit-backend:
    mix deps.audit

audit-frontend:
    npm audit --audit-level low

audit:
    @just audit-frontend
    @just audit-backend

test paths="":
    MIX_ENV=test mix do ecto.drop --quiet, ecto.create --quiet, ecto.migrate --quiet, test {{ paths }}

full-check:
    @just lint
    @just audit
    @just test

gen-erd:
    #!/usr/bin/env bash
    tmp_erd_path="$(mktemp -d)/ecto_erd.dot"; \
    mix ecto.gen.erd --output-path=$tmp_erd_path && \
    dot -Tsvg $tmp_erd_path -o docs/erd.svg

routes route="":
    mix phx.routes | grep "{{ route }}"

serve:
    iex --dbg pry -S mix phx.server

gettext:
    mix gettext.extract --merge

seed:
    mix run priv/repo/seeds.exs

encrypt:
    ansible-vault encrypt ansible/hosts.yml ansible/host_vars/server.yml --vault-password-file .vault

decrypt:
    ansible-vault decrypt ansible/hosts.yml ansible/host_vars/server.yml --vault-password-file .vault

server-setup:
    ansible-playbook ansible/setup.yml -i ansible/hosts.yml --vault-password-file .vault

server-deploy release_version:
    ansible-playbook ansible/deploy.yml -i ansible/hosts.yml --vault-password-file .vault --extra-vars release_version={{ release_version }}
