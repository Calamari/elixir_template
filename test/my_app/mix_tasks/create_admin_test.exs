defmodule MyApp.MixTasks.CreateAdminTest do
  use MyApp.DataCase, async: true

  import MyApp.Factory

  alias MyApp.Accounts

  describe "create admin task" do
    @email "some@email.io"
    @name "Obi Van"
    @password "obikinobi"

    test "creates a user that is admin" do
      assert Accounts.count_users() == 0

      assert MyApp.MixTasks.CreateAdmin.run("some@EMAIL.io", @name, @password) ==
               "Created admin user with email=#{@email} & name=#{@name}"

      assert Accounts.count_users() == 1
      assert Accounts.get_by_email(@email).admin
    end

    test "updates an existing user to admin if they exist" do
      insert(:user, %{email: @email, name: @name, password: @password})

      assert Accounts.count_users() == 1

      assert MyApp.MixTasks.CreateAdmin.run(@email, @name, @password) ==
               "Updated user with email=#{@email} and name=#{@name} and made him admin"

      assert Accounts.count_users() == 1
      assert Accounts.get_by_email(@email).admin
    end
  end
end
