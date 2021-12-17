defmodule MyApp.Tracking do
  @moduledoc """
  Context for sending tracking signals to the server.
  """

  defp api_url, do: "#{Application.get_env(:my_app, :plausible_tracking)[:host]}/api/event"

  defp enabled?, do: Application.get_env(:my_app, :plausible_tracking)[:enabled]

  defp domain, do: Application.get_env(:my_app, :plausible_tracking)[:domain]

  defp url, do: "app://#{domain}/server_events"

  @spec send_event(String.t(), map) :: nil
  def send_event(event_name, payload) do
    case Jason.encode(%{name: event_name, domain: domain(), url: url(), payload: payload}) do
      {:ok, json} ->
        send(json)

      {:error, error} ->
        Honeybadger.notify(error)
    end
  end

  defp send(json) do
    version = Keyword.get(MyApp.MixProject.project(), :version)

    headers = [
      {"User-Agent", "MyApp/#{version}"},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.post(api_url, json, headers) do
      {:ok, response} ->
        # Nothing to do here
        nil

      {:error, error} ->
        Honeybadger.notify(error)
    end
  end
end
