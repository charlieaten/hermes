defmodule Hermes.Backends.Infobip do
  @moduledoc """
  Infobip Hermes backend.

  The MVP only supports SMS delivery.
  """

  use Hermes.Backend, required_config: [:api_key, :base_url]

  alias Hermes.Message

  @impl true
  def deliver(%Message{channel: :sms} = message, config), do: send_sms(message, config)

  def deliver(%Message{channel: channel}, _config) do
    {:error, {:unsupported_channel, __MODULE__, channel}}
  end

  defp send_sms(%Message{} = message, config) do
    body = %{
      messages: [
        %{
          sender: message.from || config[:from],
          destinations: [%{to: message.to}],
          content: %{text: message.body}
        }
      ]
    }

    url =
      config
      |> Keyword.fetch!(:base_url)
      |> URI.parse()
      |> URI.merge("/sms/3/messages")
      |> URI.to_string()

    headers = [authorization: "App #{Keyword.fetch!(config, :api_key)}"]
    req_options = Keyword.get(config, :req_options, [])

    case Req.post(url, Keyword.merge(req_options, headers: headers, json: body)) do
      {:ok, %{status: status, body: response_body}} when status in 200..299 ->
        {:ok,
         %{
           provider: "infobip",
           channel: :sms,
           to: message.to,
           response: response_body
         }}

      {:ok, %{status: status, body: response_body}} ->
        {:error, {:infobip_error, status, response_body}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
