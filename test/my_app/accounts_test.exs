defmodule MyApp.AccountsTest do
  use MyApp.DataCase, async: true

  import MyApp.Factory
  alias MyApp.Accounts
  alias MyApp.Accounts.User
  alias MyApp.Accounts.PasswordResetToken

  describe "users" do
    @valid_attrs %{admin: true, email: "some@EMAIL.io", name: "Obi Van", password: "obikinobi"}
    @update_attrs %{
      admin: false,
      email: "some_updated@email.io",
      name: "Bob",
      password: "sandpeople"
    }
    @invalid_attrs %{admin: nil, email: nil}

    test "count_users/0" do
      assert Accounts.count_users() == 0

      insert(:user)

      assert Accounts.count_users() == 1
    end

    test "list_users/0 returns all users" do
      user = insert(:user)
      assert length(Accounts.list_users()) == 1

      assert List.first(Accounts.list_users()) |> Map.delete(:password) ==
               user |> Map.delete(:password)
    end

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)
      assert Accounts.get_user!(user.id) |> Map.delete(:password) == user |> Map.delete(:password)
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.admin == true
      assert user.email == "some@email.io"
      assert user.name == "Obi Van"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = insert(:user)
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.admin == false
      assert user.email == "some_updated@email.io"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user |> Map.delete(:password) == Accounts.get_user!(user.id) |> Map.delete(:password)
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user)
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = insert(:user)
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "#update_password_of_user" do
    setup _context do
      {:ok, user} = Accounts.create_user(%{email: "Big@email.com", password: "ouldpass"})
      {:ok, %{user: user}}
    end

    test "works for valid params", %{user: user} do
      encrypted_password_before = user.encrypted_password

      Accounts.update_password_of_user(user, %{
        password: "new_pass",
        password_confirmation: "new_pass"
      })

      assert encrypted_password_before != Accounts.get_user!(user.id).encrypted_password
    end

    test "validates password confirmation", %{user: user} do
      encrypted_password_before = user.encrypted_password

      result =
        Accounts.update_password_of_user(user, %{
          password: "new_pass",
          password_confirmation: "new_passs"
        })

      assert {:error, %Ecto.Changeset{errors: errors}} = result

      assert Keyword.fetch!(errors, :password_confirmation) |> elem(1) == [
               validation: :confirmation
             ]

      assert encrypted_password_before == Accounts.get_user!(user.id).encrypted_password
    end
  end

  describe "#create_password_reset_token_for_user" do
    setup _context do
      {:ok, user} = Accounts.create_user(%{email: "Big@email.com", password: "testmegood"})
      {:ok, %{user: user}}
    end

    test "stores a password reset token for that user", %{user: user} do
      pre_count = count_of(PasswordResetToken)

      result = Accounts.create_password_reset_token_for_user(user)

      assert {:ok, %PasswordResetToken{}} = result
      assert %PasswordResetToken{} = Repo.get_by!(PasswordResetToken, user_id: user.id)
      assert pre_count + 1 == count_of(PasswordResetToken)
    end

    test "replaces old password reset token if user got one already", %{user: user} do
      {:ok, %PasswordResetToken{token: old_token}} =
        Accounts.create_password_reset_token_for_user(user)

      pre_count = count_of(PasswordResetToken)

      {:ok, %PasswordResetToken{token: new_token}} =
        Accounts.create_password_reset_token_for_user(user)

      assert old_token != new_token
      assert %PasswordResetToken{} = Repo.get_by!(PasswordResetToken, user_id: user.id)
      assert pre_count == count_of(PasswordResetToken)
    end
  end

  describe "#is_valid_password_reset_token" do
    setup _context do
      {:ok, old_user} =
        Accounts.create_user(%{email: "old_token@email.com", password: "testmegood"})

      {:ok, current_user} =
        Accounts.create_user(%{email: "current_token@email.com", password: "testmegood"})

      %PasswordResetToken{
        token: "old_token",
        user_id: old_user.id,
        updated_at:
          NaiveDateTime.utc_now()
          |> NaiveDateTime.add(-5 * 60 - 1, :second)
          |> NaiveDateTime.truncate(:second)
      }
      |> Repo.insert!()

      %PasswordResetToken{token: "current_token", user_id: current_user.id} |> Repo.insert!()

      {:ok, %{old_user: old_user, current_user: current_user}}
    end

    test "returns true for current token" do
      assert true == Accounts.is_valid_password_reset_token("current_token")
    end

    test "returns false for outdated token" do
      assert false == Accounts.is_valid_password_reset_token("old_token")
    end

    test "returns false for if token does not exist" do
      assert false == Accounts.is_valid_password_reset_token("no_token")
    end
  end

  describe "#delete_password_reset_token_for_user" do
    setup _context do
      {:ok, another_user} =
        Accounts.create_user(%{email: "old_token@email.com", password: "testmegood"})

      {:ok, user} =
        Accounts.create_user(%{email: "current_token@email.com", password: "testmegood"})

      %PasswordResetToken{token: "another_token", user_id: another_user.id} |> Repo.insert!()
      %PasswordResetToken{token: "current_token", user_id: user.id} |> Repo.insert!()

      {:ok, %{another_user: another_user, user: user}}
    end

    test "removes the token of current user", %{user: user} do
      pre_count = count_of(PasswordResetToken)

      result = Accounts.delete_password_reset_token_for_user(user)

      assert {:ok, 1} == result
      assert pre_count - 1 == count_of(PasswordResetToken)
    end
  end

  describe "registering using ueberauth params" do
    test "register for an account with valid information" do
      pre_count = count_of(User)
      params = valid_user_params()

      result = Accounts.register(params)

      assert {:ok, %User{}} = result
      assert pre_count + 1 == count_of(User)
    end

    test "register for an account with an existing email address" do
      params = valid_user_params()
      insert(:user, %{email: params.info.email})

      pre_count = count_of(User)

      result = Accounts.register(params)

      assert {:error, %Ecto.Changeset{}} = result
      assert pre_count == count_of(User)
    end

    test "register for an account with to short password and no email" do
      pre_count = count_of(User)
      %{credentials: credentials} = params = valid_user_params()

      params = %{
        params
        | credentials: %{
            credentials
            | other: %{
                password: "Fiendly",
                password_confirmation: "Fiendly"
              }
          }
      }

      result = Accounts.register(params)

      assert {:error, %Ecto.Changeset{errors: errors}} = result

      assert Keyword.fetch!(errors, :password) |> elem(1) == [
               count: 8,
               validation: :length,
               kind: :min,
               type: :string
             ]

      assert pre_count == count_of(User)
    end
  end

  describe "registering using normal map" do
    @valid_attrs %{
      email: "some@email.io",
      password: "forceful",
      password_confirmation: "forceful"
    }

    test "works" do
      pre_count = count_of(User)

      result = Accounts.register(@valid_attrs)

      assert {:ok, %User{} = user} = result
      assert user.email
      assert pre_count + 1 == count_of(User)
    end

    test "stores email downcased" do
      pre_count = count_of(User)

      result = Accounts.register(%{@valid_attrs | email: "SOME@email.Io"})

      assert {:ok, %User{} = user} = result
      assert user.email == "some@email.io"
      assert pre_count + 1 == count_of(User)
    end

    test "register for an account with too short password and no email" do
      pre_count = count_of(User)

      result =
        Accounts.register(%{
          @valid_attrs
          | password: "shortly",
            password_confirmation: "shortly",
            email: "foo"
        })

      assert {:error, %Ecto.Changeset{errors: errors}} = result

      assert Keyword.fetch!(errors, :password) |> elem(1) == [
               count: 8,
               validation: :length,
               kind: :min,
               type: :string
             ]

      assert pre_count == count_of(User)
    end

    test "we can not register the same email twice" do
      Accounts.register(@valid_attrs)
      pre_count = count_of(User)

      result = Accounts.register(@valid_attrs)

      assert {:error, %Ecto.Changeset{errors: errors}} = result

      assert Keyword.fetch!(errors, :email) |> elem(1) == [
               constraint: :unique,
               constraint_name: "users_email_index"
             ]

      assert pre_count == count_of(User)
    end

    test "email is case insensitive" do
      Accounts.register(@valid_attrs)
      pre_count = count_of(User)

      result = Accounts.register(%{@valid_attrs | email: "SOME@email.Io"})

      assert {:error, %Ecto.Changeset{errors: errors}} = result

      assert Keyword.fetch!(errors, :email) |> elem(1) == [
               constraint: :unique,
               constraint_name: "users_email_index"
             ]

      assert pre_count == count_of(User)
    end
  end

  describe "confirming users email" do
    setup [:create_user, :create_token]

    test "works if everything is in order", %{user: user, token: token} do
      :ok = Accounts.confirm_email(user.email, token.token)

      assert Accounts.get_by_email(user.email).confirmed
    end

    test "returns error if email does not exist", %{token: token} do
      result = Accounts.confirm_email("another@email.de", token.token)

      assert result == {:error, :no_token_for_email}
    end

    test "returns error if token is invalid", %{user: user} do
      result = Accounts.confirm_email(user.email, "bad token")

      assert result == {:error, :token_not_valid}
    end
  end

  defp count_of(queryable) do
    MyApp.Repo.aggregate(queryable, :count, :id)
  end

  defp valid_user_params do
    %Ueberauth.Auth{
      credentials: %Ueberauth.Auth.Credentials{
        other: %{
          password: "superdupersecret",
          password_confirmation: "superdupersecret"
        }
      },
      info: %Ueberauth.Auth.Info{
        email: "me@example.com"
      }
    }
  end

  defp create_user(_) do
    %{user: insert(:user)}
  end

  defp create_token(%{user: user}) do
    %{token: insert(:email_confirmation_token, %{email: user.email})}
  end
end
