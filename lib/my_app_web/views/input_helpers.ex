defmodule MyAppWeb.InputHelpers do
  @moduledoc """
  Input rendering helpers for use in all views.
  """
  def input(form, field, label_text \\ nil) do
    type = Phoenix.HTML.Form.input_type(form, field)

    label_opts = [class: "block"]

    Phoenix.HTML.Tag.content_tag :div, class: "mb-4" do
      label =
        Phoenix.HTML.Form.label(
          form,
          field,
          label_text || Phoenix.HTML.Form.humanize(field),
          label_opts
        )

      input = apply(Phoenix.HTML.Form, type, [form, field])
      error = MyAppWeb.ErrorHelpers.error_tag(form, field) || ""
      [label, input, error]
    end
  end
end
