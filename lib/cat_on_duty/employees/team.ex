defmodule CatOnDuty.Employees.Team do
  @moduledoc "Team model"

  use Ecto.Schema

  import Ecto.Changeset

  alias CatOnDuty.Employees.Sentry
  alias Ecto.Association.NotLoaded

  @type t :: %__MODULE__{
          id: pos_integer | nil,
          name: String.t() | nil,
          tg_chat_id: String.t() | nil,
          sentries: [Sentry.t()] | [] | NotLoaded.t(),
          today_sentry: Sentry.t() | nil | NotLoaded.t(),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "teams" do
    field(:name, :string)
    field(:tg_chat_id, :string)

    has_many(:sentries, Sentry, on_delete: :nilify_all)
    belongs_to(:today_sentry, Sentry)

    timestamps()
  end

  def form_changeset(attrs \\ %{}) do
    cast(%__MODULE__{}, attrs, ~w[name tg_chat_id]a)
  end

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(team, attrs) do
    team
    |> cast(attrs, ~w[name tg_chat_id]a)
    |> validate_required(~w[name tg_chat_id]a)
  end

  @spec today_sentry_changeset(t, %{today_sentry_id: pos_integer | nil}) :: Ecto.Changeset.t()
  def today_sentry_changeset(team, attrs) do
    cast(team, attrs, ~w[today_sentry_id]a)
  end
end
