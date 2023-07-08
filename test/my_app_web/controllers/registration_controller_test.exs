defmodule MyAppWeb.RegistrationControllerTest do
  use MyAppWeb.ConnCase, async: true
  use Bamboo.Test

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
        |> post(~p"/register", @valid_params)

      assert redirected_to(conn, 302) =~ ~p"/me"

      assert MyApp.Accounts.get_by_email(@email) |> Map.take(~w[name email]a) == %{
               name: @name,
               email: @email
             }
    end

    test "redirects a user somewhere else if need to", %{conn: conn} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> get(~p"/register", %{after: "/some/other/path"})
        |> post(~p"/register", @valid_params)

      assert redirected_to(conn, 302) =~ "/some/other/path"
    end

    test "redirects to profile page if after is empty", %{conn: conn} do
      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> get(~p"/register", %{after: ""})
        |> post(~p"/register", @valid_params)

      assert redirected_to(conn, 302) =~ ~p"/me"
    end

    test "sends out an email to confirm email address", %{conn: conn} do
      post(conn, ~p"/register", @valid_params)

      assert_delivered_email_matches(%{to: [{_, @email}], text_body: text_body})

      assert text_body =~
               "http://localhost:4002/email/#{URI.encode_www_form(@email)}/confirmation/"
    end
  end
end
