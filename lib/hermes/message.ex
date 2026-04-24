defmodule Hermes.Message do
  @moduledoc """
  A provider-neutral message to deliver through a configured Hermes channel.
  """

  defstruct [
    :channel,
    :to,
    :from,
    :subject,
    :body,
    :html_body,
    metadata: %{},
    provider_options: %{}
  ]

  @type t :: %__MODULE__{
          channel: atom() | nil,
          to: term(),
          from: term(),
          subject: String.t() | nil,
          body: String.t() | nil,
          html_body: String.t() | nil,
          metadata: map(),
          provider_options: map()
        }

  def new, do: %__MODULE__{}

  def channel(%__MODULE__{} = message, channel), do: %{message | channel: channel}
  def to(%__MODULE__{} = message, to), do: %{message | to: to}
  def from(%__MODULE__{} = message, from), do: %{message | from: from}
  def subject(%__MODULE__{} = message, subject), do: %{message | subject: subject}
  def body(%__MODULE__{} = message, body), do: %{message | body: body}
  def html_body(%__MODULE__{} = message, html_body), do: %{message | html_body: html_body}

  def put_metadata(%__MODULE__{} = message, key, value) do
    %{message | metadata: Map.put(message.metadata, key, value)}
  end

  def put_provider_option(%__MODULE__{} = message, key, value) do
    %{message | provider_options: Map.put(message.provider_options, key, value)}
  end
end
