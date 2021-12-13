defmodule MyAppWeb.InputHelpers do
  @moduledoc """
  Input rendering helpers for use in all views.
  """
  def input(form, field, label_text \\ nil, wrapper_opts \\ []) do
    type = Phoenix.HTML.Form.input_type(form, field)

    wrapper_opts = merge_opts([class: "mb-4"], wrapper_opts)
    label_opts = [class: "block"]

    Phoenix.HTML.Tag.content_tag :div, wrapper_opts do
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

  defp merge_opts(default_opts, new_opts) do
    opts = Keyword.merge(default_opts, new_opts)

    Keyword.put(
      opts,
      :class,
      Enum.join([Keyword.get(default_opts, :class), Keyword.get(new_opts, :class)], " ")
    )
  end
end
