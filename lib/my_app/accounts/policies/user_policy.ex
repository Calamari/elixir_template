defmodule MyApp.Accounts.Policies.UserPolicy do
  @moduledoc """
  User authorization polices.
  """
  use MyApp, :policy

  alias MyApp.Accounts.User

  @impl true
  def authorize(_, %User{id: id}, %{user: %User{id: id}}), do: true
  def authorize(_, %User{admin: true}, _), do: true
  def authorize(_, _, _), do: false
end
