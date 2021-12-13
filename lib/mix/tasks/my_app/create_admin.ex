defmodule Mix.Tasks.MyApp.CreateAdmin do
  @moduledoc """
  This creates an admin User
  """
  @shortdoc "Creates an admin user."

  alias MyApp.MixTasks
  use Mix.Task

  @impl Mix.Task
  def run([email, name, password]) do
    Mix.Task.run("app.start")

    IO.puts(MixTasks.CreateAdmin.run(email, name, password))
  end

  def run(_), do: IO.puts("Please call like 'my_app.create_admin address@email.id Bob passw0rd'")
end
