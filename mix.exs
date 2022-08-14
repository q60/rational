defmodule Rational.MixProject do
  use Mix.Project

  def project do
    [
      app: :rational,
      version: "1.0.1",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      name: "Rational",
      source_url: "https://github.com/q60/rational",
      docs: [
        main: "Rational",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.28.4", only: :dev, runtime: false}
    ]
  end
end
