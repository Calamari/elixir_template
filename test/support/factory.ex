defmodule MyApp.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: MyApp.Repo

  def admin_user_factory do
    %MyApp.Accounts.User{
      admin: true,
      email: sequence(:email, &"user-#{&1}@email.io"),
      encrypted_password: Bcrypt.Base.hash_password("password", Bcrypt.Base.gen_salt(1, true))
    }
  end

  def user_factory do
    %MyApp.Accounts.User{
      email: sequence(:email, &"user-#{&1}@email.io"),
      encrypted_password: Bcrypt.Base.hash_password("password", Bcrypt.Base.gen_salt(1, true))
    }
  end

  def email_confirmation_token_factory do
    %MyApp.Accounts.EmailConfirmationToken{
      email: sequence(:email, &"email-#{&1}@test.de"),
      token: SecureRandom.urlsafe_base64()
    }
  end

  def password_reset_token_factory do
    %MyApp.Accounts.PasswordResetToken{
      token: SecureRandom.urlsafe_base64(),
      user: build(:user)
    }
  end
end
