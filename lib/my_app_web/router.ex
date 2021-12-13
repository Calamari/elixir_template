defmodule MyAppWeb.Router do
  @moduledoc false
  use MyAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug(:session)
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MyAppWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers, %{"content-security-policy" => "default-src 'self'"}
  end

  pipeline :auth do
    plug(MyAppWeb.Authentication.Pipeline)
  end

  pipeline :ensure_auth do
    plug(:auth)
    plug(Guardian.Plug.EnsureAuthenticated)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MyAppWeb do
    pipe_through [:browser, :auth, :assign_current_user]

    get "/", PageController, :index

    # Authentication flow routes
    get("/register", RegistrationController, :new)
    post("/register", RegistrationController, :create)
    get("/login", SessionController, :new)
    post("/login", SessionController, :create)
    delete("/logout", SessionController, :delete)
    get("/forgot_password", PasswordResetController, :new)
    post("/forgot_password", PasswordResetController, :create)
    get("/forgot_password/sent", PasswordResetController, :sent)
    get("/forgot_password/redeem", PasswordResetController, :redeem)
    post("/forgot_password/redeem/:token", PasswordResetController, :do_redeem)

    get("/email/:email/confirmation/:token", EmailConfirmationController, :confirm,
      as: :email_confirmation
    )
  end

  scope "/", MyAppWeb do
    pipe_through [:browser, :ensure_auth, :assign_current_user]

    resources("/profile", ProfileController, only: [:show], singleton: true)

    post("/email/confirmation/", EmailConfirmationController, :create,
      as: :resend_email_confirmation
    )
  end

  # Other scopes may use custom stacks.
  # scope "/api", MyAppWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: MyAppWeb.Telemetry
    end
  end

  # Enables the Bamboo mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Bamboo.SentEmailViewerPlug
    end
  end

  defp assign_current_user(conn, _) do
    assign(conn, :current_user, MyAppWeb.Authentication.get_current_user(conn))
  end

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  defp session(conn, _opts) do
    opts =
      Plug.Session.init(
        store: :cookie,
        key: Application.get_env(:my_app, __MODULE__)[:session_key],
        signing_salt: Application.get_env(:my_app, __MODULE__)[:session_signing_salt]
      )

    Plug.Session.call(conn, opts)
  end
end
