defmodule MyAppWeb.EmailConfirmationControllerTest do
  use MyAppWeb.ConnCase, async: true
  use Bamboo.Test

  import MyApp.Factory
  alias MyApp.Accounts
  alias MyApp.EmailConfirmationTokens

  # describe "sending confirmation email without being logged out" do
  # end

  # describe "sending confirmation email being logged in" do
  #   setup [:create_user]

  #   setup %{conn: conn, user: user} do
  #     %{conn: conn |> login_user(user)}
  #   end

  #   test "resends the confirm email to email address of current user", %{conn: conn, user: user} do
  #     conn = post(conn,  Routes.resend_email_confirmation_path(conn, :create))
  #     email = user.email

  #     assert_delivered_email_matches(%{to: [{_, ^email}], text_body: text_body})

  #     token = EmailConfirmationTokens.get_by_email(email)

  #     assert text_body =~
  #              "http://localhost:4002/email/#{URI.encode_www_form(email)}/confirmation/#{token.token}"

  #     assert get_flash(conn, :info) == "Email confirmation sent to #{email}"
  #     assert redirected_to(conn) == ~p"/me"
  #   end
  # end

  describe "trying to confirm a valid email confirmation token" do
    setup [:create_user, :create_token]

    test "confirms the users token and redirects to login page if not logged in", %{
      conn: conn,
      user: user,
      token: token
    } do
      conn =
        get(
          conn,
          ~p"/email/#{user.email}/confirmation/#{token.token}"
        )

      assert redirected_to(conn) == ~p"/login"
      assert Accounts.get_user!(user.id).confirmed
    end

    test "confirms the users token and redirects to his profile page if logged in", %{
      conn: conn,
      user: user,
      token: token
    } do
      conn =
        conn
        |> login_user(user)
        |> get(~p"/email/#{user.email}/confirmation/#{token.token}")

      assert get_flash(conn, :info) == "Congratulations. Email was successfully confirmed."

      assert redirected_to(conn) == ~p"/me"
      assert Accounts.get_user!(user.id).confirmed
    end

    test "shows unspecifc error if token is not valid", %{
      conn: conn,
      user: user
    } do
      conn =
        conn
        |> get(~p"/email/#{user.email}/confirmation/bad_token")

      assert redirected_to(conn) == ~p"/"
      assert get_flash(conn, :error) == "Given confirmation link is invalid or expired."

      refute Accounts.get_user!(user.id).confirmed
    end

    test "shows unspecifc error and redirects to profile if token is not valid and user is logged in",
         %{
           conn: conn,
           user: user
         } do
      conn =
        conn
        |> login_user(user)
        |> get(~p"/email/#{user.email}/confirmation/bad_token")

      assert redirected_to(conn) == ~p"/me"
      assert get_flash(conn, :error) == "Given confirmation link is invalid or expired."

      refute Accounts.get_user!(user.id).confirmed
    end
  end

  defp create_user(_) do
    %{user: insert(:user)}
  end

  defp create_token(%{user: user}) do
    %{token: insert(:email_confirmation_token, %{email: user.email})}
  end
end
