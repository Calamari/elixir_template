defmodule MyAppWeb.UserControllerTest do
  use MyAppWeb.ConnCase

  describe "logged in as admin" do
    @create_attrs %{
      admin: true,
      email: "john@doe.com",
      password: "p4ssword",
      name: "some name"
    }
    @update_attrs %{
      admin: false,
      email: "jane@doe.com",
      password: "p4ssw0rd",
      name: "some updated name"
    }
    @invalid_attrs %{admin: nil, email: nil, password: nil, name: nil}

    setup %{conn: conn} do
      admin = insert(:user, admin: true)
      {:ok, admin: admin, user: insert(:user), conn: conn |> login_user(admin)}
    end

    test "GET / lists all users", %{conn: conn} do
      conn = get(conn, ~p"/users")
      assert html_response(conn, 200) =~ "Listing Users"
    end

    test "GET /new renders form", %{conn: conn} do
      conn = get(conn, ~p"/users/new")
      assert html_response(conn, 200) =~ "New User"
    end

    test "POST / redirects to show when data is valid", %{conn: conn} do
      first_conn = post(conn, ~p"/users", user: @create_attrs)

      assert %{id: id} = redirected_params(first_conn)
      assert redirected_to(first_conn) == ~p"/users/#{id}"

      second_conn = get(conn, ~p"/users/#{id}")
      assert html_response(second_conn, 200) =~ "User #{id}"
    end

    test "POST / renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/users", user: @invalid_attrs)
      assert html_response(conn, 200) =~ "New User"
    end

    test "GET /:id/edit renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, ~p"/users/#{user}/edit")
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "PUT /:id redirects when data is valid", %{conn: conn, user: user} do
      first_conn = put(conn, ~p"/users/#{user}", user: @update_attrs)

      assert redirected_to(first_conn) == ~p"/users/#{user}"

      second_conn = get(conn, ~p"/users/#{user}")
      assert html_response(second_conn, 200) =~ "jane@doe.com"
    end

    test "POST /editrenders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/users/#{user}", user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "DELETE /:id deletes chosen user", %{conn: conn, user: user} do
      first_conn = delete(conn, ~p"/users/#{user}")
      assert redirected_to(first_conn) == ~p"/users"

      assert_error_sent 404, fn ->
        get(conn, ~p"/users/#{user}")
      end
    end
  end

  describe "not logged in" do
    test "redirects you to login", %{conn: conn} do
      conn = get(conn, ~p"/users")

      assert get_flash(conn, :error) == "You have to be logged in to access this resource."
      assert redirected_to(conn) == ~p"/login"
    end
  end

  describe "logged in as non admin" do
    setup %{conn: conn} do
      user = insert(:user, admin: false)
      {:ok, user: user, conn: conn |> login_user(user)}
    end

    test "redirects you to login", %{conn: conn} do
      conn = get(conn, ~p"/users")

      assert html_response(conn, 403) =~ "You are forbidden to see this page."
    end
  end
end
