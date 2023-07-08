defmodule MyAppWeb.RegistrationHTML do
  use MyAppWeb, :html

  embed_templates "registration_html/*"

  @doc """
  Renders a user form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def register_form(assigns)
end
