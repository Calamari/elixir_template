defmodule MyAppWeb.RegistrationControllerTest do
  use MyAppWeb.ConnCase, async: true
  use Bamboo.Test

  import MyApp.Factory

  @name "Bob Dylan"
  @email "bob@dylan.com"
  @password "password"

  describe "create" do
    @valid_params %{
      account: %{
        name: @name,
        email: @email,
        password: @password,
        password_confirmation: @password
      }
    }

    test "registers a user", %{conn: conn} do
      conn =
        conn
        |> post(Routes.registration_path(conn, :create), @valid_params)

      assert redirected_to(conn, 302) =~ Routes.profile_path(conn, :show)

      assert MyApp.Accounts.get_by_email(@email) |> Map.take(~w[name email]a) == %{
               name: @name,
               email: @email
             }
    end

    test "redirects a user somewhere else if need to", %{conn: conn} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> get(Routes.registration_path(conn, :new), %{after: "/some/other/path"})
        |> post(Routes.registration_path(conn, :create), @valid_params)

      assert redirected_to(conn, 302) =~ "/some/other/path"
    end

    test "sends out an email to confirm email address", %{conn: conn} do
      conn = post(conn, Routes.registration_path(conn, :create), @valid_params)

      assert_delivered_email_matches(%{to: [{_, @email}], text_body: text_body})

      assert text_body =~
               "http://localhost:4002/email/#{URI.encode_www_form(@email)}/confirmation/"
    end
  end

  defp create_user(_) do
    %{user: insert(:user, %{email: @email, password: @password})}
  end
end
