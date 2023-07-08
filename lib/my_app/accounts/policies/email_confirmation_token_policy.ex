defmodule MyApp.Accounts.Policies.EmailConfirmationTokenPolicy do
  @moduledoc """
  User authorization polices.
  """
  use MyApp, :policy

  @impl true
  def authorize(_, _, _), do: true
end
