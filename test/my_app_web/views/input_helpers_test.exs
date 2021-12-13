defmodule MyAppWeb.InputHelpersTest do
  use MyAppWeb.ConnCase, async: true

  describe "input" do
    @form Phoenix.HTML.Form.form_for(
            MyApp.Accounts.User.changeset(%MyApp.Accounts.User{}, %{}),
            ""
          )

    test "creates a nice structure for text fields" do
      {:safe, result} = MyAppWeb.InputHelpers.input(@form, :name, "My Text")

      assert to_string(result) ==
               "<div class=\"mb-4 \"><label class=\"block\" for=\"user_name\">My Text</label><input id=\"user_name\" name=\"user[name]\" type=\"text\"></div>"
    end

    test "figures out if a field is a password" do
      {:safe, result} = MyAppWeb.InputHelpers.input(@form, :password, "My Pass")

      assert to_string(result) ==
               "<div class=\"mb-4 \"><label class=\"block\" for=\"user_password\">My Pass</label><input id=\"user_password\" name=\"user[password]\" type=\"password\"></div>"
    end

    test "does not need a label" do
      {:safe, result} = MyAppWeb.InputHelpers.input(@form, :name)

      assert to_string(result) ==
               "<div class=\"mb-4 \"><label class=\"block\" for=\"user_name\">Name</label><input id=\"user_name\" name=\"user[name]\" type=\"text\"></div>"
    end

    test "can receive some options for the wrapper" do
      {:safe, result} =
        MyAppWeb.InputHelpers.input(@form, :password, "humm", class: "my-class", role: "input")

      assert to_string(result) ==
               "<div class=\"mb-4 my-class\" role=\"input\"><label class=\"block\" for=\"user_password\">humm</label><input id=\"user_password\" name=\"user[password]\" type=\"password\"></div>"
    end
  end
end
