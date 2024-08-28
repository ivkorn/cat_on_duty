ARGS = $(filter-out $@,$(MAKECMDGOALS))
%:
	@:

setup-backend:
	mix do deps.get, deps.compile, compile

setup-frontend:
	npm install

setup:
	@make backend-setup
	@make frontend-setup

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
	@make check-formatted
	@make credo
	@make dialyzer

eslint:
	npx eslint .

stylelint:
	npx stylelint assets/**/*.scss

lint-frontend:
	@make eslint
	@make stylelint

lint:
	@make lint-frontend
	@make lint-backend

audit-backend:
	mix deps.audit

audit-frontend:
	npm audit --audit-level low

audit:
	@make audit-backend
	@make audit-frontend

tests:
	MIX_ENV=test mix do ecto.drop --quiet, ecto.create --quiet, ecto.migrate --quiet, test $(ARGS)

full-check:
	@make lint
	@make audit
	@make tests

gen-erd:
	tmp_erd_path="$$(mktemp -d)/ecto_erd.dot"; \
	mix ecto.gen.erd --output-path=$$tmp_erd_path && \
	dot -Tsvg $$tmp_erd_path -o docs/erd.svg

routes:
	mix phx.routes | grep "$(ARGS)"

serve:
	source ./.envrc && iex --dbg pry -S mix phx.server

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

server-deploy:
	ansible-playbook ansible/deploy.yml -i ansible/hosts.yml --vault-password-file .vault --extra-vars "release_version=$(ARGS)"
