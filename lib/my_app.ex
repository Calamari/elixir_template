defmodule MyApp do
  @moduledoc """
  This groups common sub modules together we use in our app.

  The directory structure in lib/my_app should look smth like this:

  - thing/
    - emails/an_email.ex <- w/ `use MyApp, :email`
    - finders/thing_query.ex <- w/ `use MyApp, :query`
    - finders/thing_repo.ex <- w/ `use MyApp, :repo`
    - policies/thing_policy.ex <- w/ `use MyApp, :policy`
    - thing.ex <- w/ `use MyApp, :schema`
  - thing.ex

  The available usages are:

      use MyApp, :email
      use MyApp, :policy
      use MyApp, :query
      use MyApp, :repo
      use MyApp, :schema
  """

  def policy do
    quote do
      @behaviour Bodyguard.Policy
    end
  end

  def email do
    quote do
      import Bamboo.Email
    end
  end

  def query do
    quote do
      import Ecto.Query, warn: false
    end
  end

  def repo do
    quote do
      import Ecto.Query, warn: false
      alias MyApp.Repo
    end
  end

  @doc """
  This is the default usage for the schema.
  It expects that current module has a policy with respective name in the polcies sub directory.
  If there is none, you should set `@policy false` before the `use` statement.
  """
  def schema do
    quote do
      use MyApp.Schema
      import Ecto.Changeset

      # Allow the resource to be used instead of the respective policies.
      @name __MODULE__ |> Module.split() |> List.last()
      @parent __MODULE__ |> Module.split() |> Enum.drop(-1) |> Module.concat()
      defdelegate authorize(action, user, params),
        to: Module.concat([@parent, Policies, "#{@name}Policy"])
    end
  end

  @doc """
  When used, dispatch to the appropriate sub part
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
