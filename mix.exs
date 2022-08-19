defmodule Rational.MixProject do
  use Mix.Project

  def project do
    [
      app: :rational,
      version: "1.3.1",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "qrational",
      source_url: "https://github.com/q60/rational",
      docs: [
        main: "Rational",
        extras: ["README.md"]
      ]
    ]
  end

  defp description() do
    "Elixir library implementing rational numbers and math."
  end

  defp package() do
    [
      name: "qrational",
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/q60/rational"
      }
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.28.4", only: :dev, runtime: false}
    ]
  end
end
