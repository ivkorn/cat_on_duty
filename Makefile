ARGS = $(filter-out $@,$(MAKECMDGOALS))

lint:
	mix do format --check-formatted, credo, dialyzer --quiet-with-result

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

encrypt-server-setup:
	ansible-vault encrypt ansible/hosts.yml --vault-password-file .vault

decrypt-server-setup:
	ansible-vault decrypt ansible/hosts.yml --vault-password-file .vault

setup-server:
	ansible-playbook ansible/setup.yml -i ansible/hosts.yml -u root --vault-password-file .vault
