defmodule ReleaseLister.Mixfile do
  use Mix.Project

  def project do
    [ app: :release_lister,
      version: "0.1.1",
      elixir: "~> 0.11.3-dev",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat.git" }
  defp deps do
    [{:httpotion, github: "myfreeweb/httpotion"},
     {:json, github: "cblage/elixir-json"}]
  end
end
