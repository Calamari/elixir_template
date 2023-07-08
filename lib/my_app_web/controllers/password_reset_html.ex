defmodule MyAppWeb.PasswordResetHTML do
  use MyAppWeb, :html

  embed_templates "password_reset_html/*"

  @doc """
  Renders the password reset form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def reset_form(assigns)

  @doc """
  Renders the form to redeem password reset token.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def redeem_form(assigns)
end
