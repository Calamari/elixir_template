defmodule MyAppWeb.ProfileControllerTest do
  use MyAppWeb.ConnCase, async: true

  import MyApp.Factory

  describe "a logged out user" do
    test "cannot see those routes", %{conn: conn} do
      Enum.each(
        [
          get(conn, Routes.profile_path(conn, :show))
        ],
        fn conn ->
          assert html_response(conn, 302)
        end
      )
    end
  end

  describe "show" do
    setup _context do
      {:ok, user: insert(:user, %{email: "bob@dylan.com"})}
    end

    test "shows logged in user’s profile page", %{conn: conn, user: user} do
      conn =
        conn
        |> login_user(user)
        |> get(Routes.profile_path(conn, :show))

      assert html_response(conn, 200) =~ "Hello, bob@dylan.com"
    end
  end
end
