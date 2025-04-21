set dotenv-load := true

setup-backend:
    mix do deps.get, deps.compile, compile

setup-frontend:
    npm ci

setup-db:
    mix ecto.setup

setup:
    @just setup-backend
    @just setup-frontend
    @just setup-db

check-formated:
    mix format --check-formatted

credo:
    mix credo --strict

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
    mix ecto.gen.erd --output-path=docs/ecto_erd.dot
    dot -Tsvg docs/ecto_erd.dot -o docs/erd.svg
    rm docs/ecto_erd.dot

dbmigrate *options="":
    mix ecto.migrate {{ options }}
    {{ if env_var_or_default("MIX_ENV", "dev") == "dev" { "just gen-erd" } else { "" } }}

dbreset:
    mix ecto.reset

routes routes="":
    mix phx.routes | grep "{{ routes }}"

serve:
    iex --dbg pry -S mix phx.server

gettext:
    mix gettext.extract --merge

remsh local_node_name="debug@127.0.0.1":
    #!/usr/bin/env bash
    read_vars() {
        ansible-vault decrypt $1 --vault-password-file .vault --output - 2> /dev/null || cat $1
    }
    host_vars_path="ansible/host_vars/server.yml"
    hosts_path="ansible/hosts.yml"
    cookie=$(read_vars $host_vars_path | grep "env_release_cookie" | awk -F ":" '{print $2}' | xargs)
    release_name=$(read_vars $host_vars_path | grep "env_release_name" | awk -F ":" '{print $2}' | xargs)
    node_name=$(read_vars $hosts_path | grep "ansible_host" | awk -F ":" '{print $2}' | xargs)
    iex --name {{ local_node_name }} --cookie $cookie --remsh "$release_name@$node_name"

encrypt:
    ansible-vault encrypt ansible/hosts.yml ansible/host_vars/server.yml --vault-password-file .vault

decrypt:
    ansible-vault decrypt ansible/hosts.yml ansible/host_vars/server.yml --vault-password-file .vault

deploy release_version:
    ansible-playbook ansible/deploy.yml -i ansible/hosts.yml --vault-password-file .vault --extra-vars release_version={{ release_version }}
