ARGS = $(filter-out $@,$(MAKECMDGOALS))
%:
	@:

lint:
	mix do format --check-formatted, credo, dialyzer --quiet-with-result

tests:
	MIX_ENV=test mix do ecto.drop --quiet, ecto.create --quiet, ecto.migrate --quiet, test $(ARGS)

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

docker-build:
	docker build -t ivkorn/cat_on_duty:$(ARGS) -t ivkorn/cat_on_duty:latest .

docker-push:
	docker push ivkorn/cat_on_duty:$(ARGS)
	docker push ivkorn/cat_on_duty:latest

encrypt-server-setup:
	ansible-vault encrypt ansible/hosts.yml ansible/host_vars/server.yml --vault-password-file .vault

decrypt-server-setup:
	ansible-vault decrypt ansible/hosts.yml ansible/host_vars/server.yml --vault-password-file .vault

server-setup:
	ansible-playbook ansible/setup.yml -i ansible/hosts.yml --vault-password-file .vault

server-deploy:
	ansible-playbook ansible/deploy.yml -i ansible/hosts.yml --vault-password-file .vault --extra-vars "release_version=$(ARGS)"

build-deploy:
	@make docker-build $(ARGS)
	@make docker-push $(ARGS)
	@make server-deploy $(ARGS)
