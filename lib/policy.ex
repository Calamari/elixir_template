defmodule MyApp.Policy do
  @moduledoc """
  General authorization polices.
  """
  @behaviour Bodyguard.Policy

  @impl true
  def authorize(:show_admin, %MyApp.Accounts.User{admin: true}, _), do: true
  def authorize(:show_admin, _, _), do: false
  def authorize(_, _, _), do: true
end
