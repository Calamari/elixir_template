defmodule MyApp.Accounts.Emails.PasswordResetInstructionsEmail do
  @moduledoc """
  Email with password reset instructions.
  """
  use MyApp, :email

  @spec build(MyApp.Accounts.User.t(), String.t()) :: Bamboo.Email.t()
  def build(user, link) do
    new_email(
      to: user.email,
      from: Application.get_env(:my_app, :email_sender),
      subject: "Your Instructions for Resetting Your Password",
      html_body: """
      <strong>Someone asked for resetting the password for this email.</strong>

      <p>Here is the link: #{link}</p>
      """,
      text_body: """
      Someone asked for resetting the password for this email.

      Here is the link: #{link}
      """
    )
  end
end
