defmodule MyAppWeb.SessionHTML do
  use MyAppWeb, :html

  embed_templates "session_html/*"

  @doc """
  Renders a user form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def login_form(assigns)
end
