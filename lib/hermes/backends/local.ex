defmodule Hermes.Backends.Local do
  @moduledoc """
  Local Hermes backend that logs messages instead of sending them.
  """

  use Hermes.Backend

  require Logger

  @impl true
  def deliver(%Hermes.Message{} = message, _config) do
    Logger.info(
      "[hermes:local] #{inspect(message.channel)} to=#{inspect(message.to)} body=#{inspect(message.body)}"
    )

    {:ok,
     %{
       provider: "local",
       id: "local-" <> random_id(),
       channel: message.channel,
       to: message.to
     }}
  end

  defp random_id do
    16
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
  end
end
