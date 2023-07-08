defmodule MyAppWeb.Router do
  use MyAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :session
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MyAppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
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

    get "/", PageController, :home

    resources "/users", UserController

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

    post("/email/confirmation/", EmailConfirmationController, :create,
      as: :resend_email_confirmation
    )
  end

  # Logged in only routes
  scope "/", MyAppWeb do
    pipe_through [:browser, :ensure_auth, :assign_current_user]

    get("/me", ProfileController, :me)
  end

  # Other scopes may use custom stacks.
  # scope "/api", MyAppWeb do
  #   pipe_through :api
  # end

  scope "/admin" do
    pipe_through([:browser, :ensure_auth, :assign_current_user, :ensure_admin])

    import Phoenix.LiveDashboard.Router
    live_dashboard "/dashboard", metrics: MyAppWeb.Telemetry
  end

  if Application.compile_env(:my_app, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Bamboo.SentEmailViewerPlug
    end
  end

  defp ensure_admin(conn, _) do
    user = conn.assigns.current_user

    case Bodyguard.permit?(MyApp, :show_admin, user) do
      true ->
        conn

      _ ->
        conn
        |> put_status(403)
        |> put_view(NioomiWeb.ErrorView)
        |> render(:"403")
        |> halt()
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
