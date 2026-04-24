defmodule Hermes do
  @moduledoc """
  Minimal multi-channel delivery facade.
  """

  alias Hermes.Message

  @spec deliver(Message.t(), Keyword.t()) :: {:ok, term()} | {:error, term()}
  def deliver(%Message{} = message, config \\ []) do
    config = parse_config(config)

    with :ok <- validate_message(message),
         {:ok, backend_config} <- fetch_backend_config(config, message.channel),
         {:ok, backend} <- fetch_backend(backend_config) do
      :ok = backend.validate_config(backend_config)
      backend.deliver(message, backend_config)
    end
  end

  @spec deliver!(Message.t(), Keyword.t()) :: term() | no_return()
  def deliver!(%Message{} = message, config \\ []) do
    case deliver(message, config) do
      {:ok, result} -> result
      {:error, reason} -> raise RuntimeError, "Hermes delivery failed: #{inspect(reason)}"
    end
  end

  defp parse_config(dynamic_config) do
    Application.get_all_env(:hermes)
    |> Keyword.merge(dynamic_config)
  end

  defp fetch_backend_config(config, channel) when is_atom(channel) do
    with {:ok, backend_name} <- fetch_channel_backend_name(config, channel),
         {:ok, backend_config} <- fetch_named_backend_config(config, backend_name) do
      {:ok, Keyword.put_new(backend_config, :name, backend_name)}
    end
  end

  defp fetch_backend_config(_config, channel), do: {:error, {:invalid_channel, channel}}

  defp fetch_channel_backend_name(config, channel) do
    config
    |> Keyword.get(:channels, [])
    |> Keyword.fetch(channel)
    |> case do
      {:ok, backend_name} when is_atom(backend_name) -> {:ok, backend_name}
      {:ok, backend_name} -> {:error, {:invalid_backend_name, channel, backend_name}}
      :error -> {:error, {:unknown_channel, channel}}
    end
  end

  defp fetch_named_backend_config(config, backend_name) do
    config
    |> Keyword.get(:backends, [])
    |> Keyword.fetch(backend_name)
    |> case do
      {:ok, backend_config} -> {:ok, backend_config}
      :error -> {:error, {:unknown_backend, backend_name}}
    end
  end

  defp fetch_backend(backend_config) do
    case Keyword.fetch(backend_config, :backend) do
      {:ok, backend} -> {:ok, backend}
      :error -> {:error, :backend_not_configured}
    end
  end

  defp validate_message(%Message{channel: nil}), do: {:error, :channel_not_set}
  defp validate_message(%Message{to: nil}), do: {:error, :to_not_set}
  defp validate_message(%Message{}), do: :ok
end
