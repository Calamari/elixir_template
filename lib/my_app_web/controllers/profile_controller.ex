defmodule MyAppWeb.ProfileController do
  use MyAppWeb, :controller

  alias MyAppWeb.Authentication
  alias MyApp.Data

  def show(conn, _) do
    current_user = Authentication.get_current_user(conn)

    render(conn, :show,
      breadcrumb: [
        %{to: Routes.profile_path(conn, :show), title: "This is"},
        %{to: Routes.profile_path(conn, :show), title: "a Breadcrumb"},
        %{to: Routes.profile_path(conn, :show), title: "Profile"}
      ]
    )
  end
end
