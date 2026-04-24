defmodule Hermes.Backend do
  @moduledoc """
  Behaviour for Hermes delivery backends.
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @required_config opts[:required_config] || []
      @behaviour Hermes.Backend

      @impl Hermes.Backend
      def validate_config(config) do
        Hermes.Backend.validate_config(@required_config, config)
      end

      defoverridable validate_config: 1
    end
  end

  @type config :: Keyword.t()

  @callback deliver(Hermes.Message.t(), config()) :: {:ok, term()} | {:error, term()}
  @callback validate_config(config()) :: :ok | no_return()

  @spec validate_config([atom()], Keyword.t()) :: :ok | no_return()
  def validate_config(required_config, config) do
    missing =
      Enum.filter(required_config, fn key ->
        config[key] in [nil, ""]
      end)

    if missing == [] do
      :ok
    else
      raise ArgumentError, "expected #{inspect(missing)} to be set, got: #{inspect(config)}"
    end
  end
end
