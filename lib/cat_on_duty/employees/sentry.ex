defmodule CatOnDuty.Employees.Sentry do
  @moduledoc "Sentry model"

  use Ecto.Schema
  use Gettext, backend: CatOnDutyWeb.Gettext

  import Ecto.Changeset

  alias CatOnDuty.Employees.Team
  alias Ecto.Association.NotLoaded

  @type t :: %__MODULE__{
          id: pos_integer | nil,
          name: String.t() | nil,
          tg_username: String.t() | nil,
          on_vacation?: boolean | nil,
          last_duty_at: DateTime.t() | nil,
          team: Team.t() | nil | NotLoaded.t(),
          today_duty: Team.t() | nil | NotLoaded.t(),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "sentries" do
    field(:name, :string)
    field(:tg_username, :string)
    field(:on_vacation?, :boolean, default: false)
    field(:last_duty_at, :utc_datetime)

    belongs_to(:team, Team)
    has_one(:today_duty, Team, foreign_key: :today_sentry_id, on_delete: :nilify_all)

    timestamps()
  end

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(sentry, attrs) do
    sentry
    |> cast(attrs, ~w[name team_id tg_username on_vacation?]a)
    |> validate_required(~w[name tg_username on_vacation?]a)
    |> validate_format(:tg_username, ~r/^@/, message: dgettext("errors", "must starts with '@'"))
  end

  @spec last_duty_at_changeset(t, %{last_duty_at: DateTime.t()}) :: Ecto.Changeset.t()
  def last_duty_at_changeset(sentry, attrs) do
    sentry
    |> cast(attrs, ~w[last_duty_at]a)
    |> validate_required(~w[last_duty_at]a)
  end
end
