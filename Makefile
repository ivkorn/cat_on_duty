ARGS = $(filter-out $@,$(MAKECMDGOALS))

lint:
	mix do format --check-formatted, credo, dialyzer --quiet-with-result

tests:
	MIX_ENV=test mix do ecto.drop --quiet, ecto.create --quiet, ecto.migrate --quiet, test

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
