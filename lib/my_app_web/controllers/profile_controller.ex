defmodule MyAppWeb.ProfileController do
  use MyAppWeb, :controller

  alias MyAppWeb.Authentication

  def show(conn, _) do
    render(conn, :show,
      breadcrumb: [
        %{to: Routes.profile_path(conn, :show), title: "This is"},
        %{to: Routes.profile_path(conn, :show), title: "a Breadcrumb"},
        %{to: Routes.profile_path(conn, :show), title: "Profile"}
      ]
    )
  end
end
