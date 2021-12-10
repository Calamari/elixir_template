defmodule MyAppWeb.Authentication.Pipeline do
  @moduledoc """
  Authentication pipeline
  """
  use Guardian.Plug.Pipeline,
    otp_app: :my_app,
    error_handler: MyAppWeb.Authentication.ErrorHandler,
    module: MyAppWeb.Authentication

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
end
