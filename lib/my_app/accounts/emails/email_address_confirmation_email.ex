defmodule MyApp.Accounts.Emails.EmailAddressConfirmationEmail do
  @moduledoc """
  Email for confirming email address.
  """
  use MyApp, :email

  @spec build(MyApp.Accounts.User.t(), String.t()) :: Bamboo.Email.t()
  def build(user, link) do
    new_email(
      to: user.email,
      from: Application.get_env(:my_app, :email_sender),
      subject: "Please Confirm This is Your Email.",
      html_body: """
      <strong>Someone registered with this email.</strong>

      <p>If this is you, please <a href="#{link}">confirm your email address</a>.</p>
      """,
      text_body: """
      Someone registered with this email.

      If this is you, please confirm your email address using this link: #{link}.
      """
    )
  end
end
