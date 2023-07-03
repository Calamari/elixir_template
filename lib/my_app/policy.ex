defmodule MyApp.Policy do
  @moduledoc """
  General authorization polices.
  """
  @behaviour Bodyguard.Policy

  @impl true
  def authorize(_, %MyApp.Accounts.User{admin: true}, _), do: true
  def authorize(_, _, _), do: false
end
