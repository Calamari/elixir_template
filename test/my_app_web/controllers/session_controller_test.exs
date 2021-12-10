defmodule MyAppWeb.SessionControllerTest do
  use MyAppWeb.ConnCase, async: true
  use Bamboo.Test

  import MyApp.Factory
  alias MyAppWeb.Authentication

  @email "bob@dylan.com"
  @password "password"

  describe "having a user" do
    setup [:create_user]

    @valid_params %{account: %{email: @email, password: @password}}
    @invalid_params %{account: %{email: @email, password: "..."}}

    test "logging in works", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), @valid_params)

      assert Authentication.get_current_user(conn)
      assert redirected_to(conn, 302) =~ Routes.profile_path(conn, :show)
    end

    test "just redirects if already logged in", %{conn: conn, user: user} do
      conn = conn |> login_user(user) |> post(Routes.session_path(conn, :create), @valid_params)

      assert redirected_to(conn, 302) =~ Routes.profile_path(conn, :show)
    end

    test "stays on login page if credentailas are wrong", %{conn: conn} do
      conn = post(conn, Routes.session_path(conn, :create), @invalid_params)

      assert html_response(conn, 200) =~ "Log In"
      assert html_response(conn, 200) =~ "Incorrect email or password"
    end

    test "logging off redirects to login page", %{conn: conn} do
      conn = delete(conn, Routes.session_path(conn, :delete))

      refute Authentication.get_current_user(conn)
      assert redirected_to(conn, 302) =~ Routes.session_path(conn, :new)
    end
  end

  defp create_user(_) do
    %{user: insert(:user, %{email: @email, password: @password})}
  end
end
