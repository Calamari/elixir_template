defmodule MyApp.EmailConfirmationTokensTest do
  use MyApp.DataCase, async: true

  import MyApp.Factory
  alias MyApp.EmailConfirmationTokens
  alias MyApp.Accounts.EmailConfirmationToken

  describe "email confirmation tokens" do
    @email "some@EMAIL.io"

    setup _context do
      {:ok, %{token: insert(:email_confirmation_token)}}
    end

    test "create_token/1 with valid email address creates a token" do
      assert {:ok, %EmailConfirmationToken{} = token} =
               EmailConfirmationTokens.create_token(@email)

      assert token.email == "some@email.io"
      assert String.length(token.token) == 32
    end

    test "create_token/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = EmailConfirmationTokens.create_token("no")
    end

    test "create_token/1 with duplicate email recreates a token", %{token: token} do
      assert {:ok, %EmailConfirmationToken{} = new_token} =
               EmailConfirmationTokens.create_token(token.email)

      assert new_token.email == token.email
      assert new_token.token != token.token

      assert EmailConfirmationTokens.get_by_email(token.email).token == new_token.token
    end

    test "redeem_token/2 can succeed", %{token: token} do
      assert :ok == EmailConfirmationTokens.redeem_token(String.upcase(token.email), token.token)
    end

    test "redeem_token/2 returns error if not redeemed in time" do
      token =
        insert(:email_confirmation_token, %{
          updated_at:
            NaiveDateTime.utc_now()
            |> NaiveDateTime.add(-10 * 60 - 1, :second)
            |> NaiveDateTime.truncate(:second)
        })

      assert {:error, :token_outdated} ==
               EmailConfirmationTokens.redeem_token(token.email, token.token)
    end

    test "redeem_token/2 is not valid", %{token: token} do
      assert {:error, :token_not_valid} ==
               EmailConfirmationTokens.redeem_token(String.upcase(token.email), "bad")
    end

    test "redeem_token/2 says when email has no token" do
      assert {:error, :no_token_for_email} ==
               EmailConfirmationTokens.redeem_token(@email, "doesnt_matter")
    end

    test "redeem_token/2 deletes redeemed token", %{token: token} do
      :ok = EmailConfirmationTokens.redeem_token(String.upcase(token.email), token.token)

      # Now it's deleted
      assert {:error, :no_token_for_email} ==
               EmailConfirmationTokens.redeem_token(String.upcase(token.email), token.token)
    end
  end
end
