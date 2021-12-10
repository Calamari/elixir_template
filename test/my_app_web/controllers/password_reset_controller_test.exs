defmodule MyAppWeb.PasswordResetControllerTest do
  use MyAppWeb.ConnCase, async: true
  use Bamboo.Test

  import MyApp.Factory
  alias MyApp.Accounts

  describe "new password reset" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.password_reset_path(conn, :new))
      assert html_response(conn, 200) =~ "Forgot your Password?"
    end
  end

  describe "sent password reset form" do
    test "renders sent text", %{conn: conn} do
      conn = get(conn, Routes.password_reset_path(conn, :sent))
      assert html_response(conn, 200) =~ "Password Reset Instructions Sent"
    end
  end

  describe "create password reset token for existing user" do
    setup [:create_user]

    test "redirects to sent text", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.password_reset_path(conn, :create), %{
          "password_reset" => %{"email" => user.email}
        })

      assert redirected_to(conn) == Routes.password_reset_path(conn, :sent)
    end

    test "sends out an email", %{conn: conn, user: user} do
      post(conn, Routes.password_reset_path(conn, :create), %{
        "password_reset" => %{"email" => user.email}
      })

      email = user.email

      assert_delivered_email_matches(%{to: [{_, ^email}], text_body: text_body})
      assert text_body =~ "Here is the link: http://localhost:4002/forgot_password/redeem?token="
    end
  end

  describe "create password reset token for non existing user" do
    test "still redirects to sent text", %{conn: conn} do
      conn =
        post(conn, Routes.password_reset_path(conn, :create), %{
          "password_reset" => %{"email" => "some@email.de"}
        })

      assert redirected_to(conn) == Routes.password_reset_path(conn, :sent)
    end
  end

  describe "trying to redeem a valid password reset token" do
    setup [:create_user, :create_reset_token]

    test "should show a form", %{conn: conn, token: token} do
      conn = get(conn, Routes.password_reset_path(conn, :redeem, token: token.token))
      assert html_response(conn, 200) =~ "Reset your Password"
    end
  end

  describe "trying to redeem an invalid password reset token" do
    test "should show a hint", %{conn: conn} do
      conn = get(conn, Routes.password_reset_path(conn, :redeem, token: "NOPE_NOTHING"))
      assert html_response(conn, 200) =~ "Password Reset Token Invalid"
    end
  end

  describe "redeeming a valid password reset token" do
    setup [:create_user, :create_reset_token]

    test "should show a form and change password of user", %{conn: conn, user: user, token: token} do
      encrypted_password_before = user.encrypted_password

      conn =
        post(
          conn,
          Routes.password_reset_path(conn, :do_redeem, token.token),
          password_reset: %{
            password: "new_pass",
            password_confirmation: "new_pass"
          }
        )

      assert redirected_to(conn) == Routes.session_path(conn, :new)
      assert encrypted_password_before != Accounts.get_user!(user.id).encrypted_password
    end

    test "only changes password if validation passes", %{conn: conn, user: user, token: token} do
      encrypted_password_before = user.encrypted_password

      conn =
        post(
          conn,
          Routes.password_reset_path(conn, :do_redeem, token.token),
          password_reset: %{
            password: "short"
          }
        )

      assert html_response(conn, 200) =~ "Reset your Password"
      assert html_response(conn, 200) =~ "should be at least 8 character(s)"
      assert encrypted_password_before == Accounts.get_user!(user.id).encrypted_password
    end
  end

  describe "redeeming an invalid password reset token" do
    test "should show a hint", %{conn: conn} do
      conn =
        post(
          conn,
          Routes.password_reset_path(conn, :do_redeem, "NOPE_NOTHING"),
          password_reset: %{}
        )

      assert html_response(conn, 200) =~ "Password Reset Token Invalid"
    end
  end

  defp create_user(_) do
    %{user: insert(:user)}
  end

  defp create_reset_token(%{user: user}) do
    %{token: insert(:password_reset_token, %{user: user})}
  end
end
