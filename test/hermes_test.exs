defmodule HermesTest do
  use ExUnit.Case, async: true

  alias Hermes.Message

  test "deliver/2 returns an error when channel is missing" do
    message =
      Message.new()
      |> Message.to("+15555550123")

    assert Hermes.deliver(message) == {:error, :channel_not_set}
  end

  test "deliver/2 returns an error when recipient is missing" do
    message =
      Message.new()
      |> Message.channel(:sms)

    assert Hermes.deliver(message) == {:error, :to_not_set}
  end

  test "deliver/2 returns an error for unknown channels" do
    message =
      Message.new()
      |> Message.channel(:push)
      |> Message.to("Paris")

    assert Hermes.deliver(message) == {:error, {:unknown_channel, :push}}
  end

  test "deliver/2 uses configured local backend" do
    message =
      Message.new()
      |> Message.channel(:sms)
      |> Message.to("+15555550123")
      |> Message.body("Paris, Zeus says the apple discourse has gotten out of hand. Code 123456.")

    assert {:ok, %{provider: "local", channel: :sms, to: "+15555550123"}} =
             Hermes.deliver(message)
  end

  test "per-call config overrides application config" do
    message =
      Message.new()
      |> Message.channel(:pager)
      |> Message.to("Achilles")
      |> Message.body("Hera says to guard the heel this time.")

    config = [
      channels: [
        pager: :local
      ],
      backends: [
        local: [
          backend: Hermes.Backends.Local
        ]
      ]
    ]

    assert {:ok, %{provider: "local", channel: :pager, to: "Achilles"}} =
             Hermes.deliver(message, config)
  end

  test "deliver/2 returns an error when a channel points at an unknown backend" do
    message =
      Message.new()
      |> Message.channel(:sms)
      |> Message.to("+15555550123")

    config = [
      channels: [
        sms: :missing
      ],
      backends: []
    ]

    assert Hermes.deliver(message, config) == {:error, {:unknown_backend, :missing}}
  end
end
