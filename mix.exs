defmodule Hermes.MixProject do
  use Mix.Project

  def project do
    [
      app: :hermes,
      version: "0.1.0",
      elixir: "~> 1.18",
      description:
        "Multi-channel message delivery for Elixir with pluggable backends for SMS, WhatsApp, email, voice, and local development.",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:jason, "~> 1.4"},
      {:plug, "~> 1.17"},
      {:req, "~> 0.5"}
    ]
  end
end
