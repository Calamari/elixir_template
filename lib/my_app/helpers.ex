defmodule MyApp.Helpers do
  @moduledoc """
  Some helper functions.
  """

  @doc """
  Generates a random string.
  It's main purpose is to encapsulate `SecureRandom.urlsafe_base64` and wrap it
  in a try/catch block to make dialyzer happy.
  """
  @spec random_string() :: binary()
  @spec random_string(integer()) :: binary()
  def random_string(len \\ 16) do
    # I never found a way why this try is needed except to make dialyzer happy
    try do
      SecureRandom.urlsafe_base64(len)
    rescue
      err ->
        Honeybadger.notify(err)

        "ocyvcejrf3_oije-9pkoki35zht7nowf5h3q8tnc589zxtqm985ulz8496nz9qc853zvl95z8nu9öz3f"
        |> String.slice(0, len)
    end
  end
end
