defmodule MyApp.Email do
  @moduledoc """
  Email template for all the emails.
  """
  import Bamboo.Email

  def password_reset_instructions_email(user, link) do
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

  def email_confirmation_email(user, link) do
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
