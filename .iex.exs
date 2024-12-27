import Ecto.Query

alias CatOnDuty.Employees
alias CatOnDuty.Employees.Sentry
alias CatOnDuty.Employees.Team
alias CatOnDuty.ErrorTrackerRepo
alias CatOnDuty.ObanRepo
alias CatOnDuty.Repo

IEx.configure(colors: [enabled: true], history_size: -1, inspect: [limit: :infinity])
