defmodule NifOptFlags.MixProject do
  use Mix.Project

  @version "0.1.0"
  @github_url "https://github.com/cocoa-xu/nif_opt_flags"
  def project do
    [
      app: :nif_opt_flags,
      version: @version,
      elixir: "~> 1.12",
      compilers: [:elixir_make] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      make_precompiler: {:nif, CCPrecompiler},
      make_precompiler_url: "#{@github_url}/releases/download/v#{@version}/@{artefact_filename}",
      make_precompiler_filename: "nif"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.7"},
      {:cc_precompiler, "~> 0.1"}
    ]
  end
end
