defmodule MyApp.Tasks.CreateAdmin do
  @moduledoc """
  Implementation of task to create admin user.
  """

  alias MyApp.Accounts

  def run(email, name, password) do
    case Accounts.get_by_email(email) do
      nil ->
        case Accounts.create_user(%{email: email, name: name, password: password, admin: true}) do
          {:ok, user} ->
            "Created admin user with email=#{user.email} & name=#{user.name}"

          # credo:disable-for-next-line Credo.Check.Warning.IoInspect
          {:error, changeset} ->
            IO.inspect(changeset, label: "Could not create user")
        end

      user ->
        case Accounts.update_user(user, %{name: name, password: password, admin: true}) do
          {:ok, _} ->
            "Updated user with email=#{email} and name=#{name} and made him admin"

          {:error, changeset} ->
            # credo:disable-for-next-line Credo.Check.Warning.IoInspect
            IO.inspect(changeset, label: "Could not update existing user")
        end
    end
  end
end
