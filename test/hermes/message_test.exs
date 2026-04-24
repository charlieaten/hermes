defmodule Hermes.MessageTest do
  use ExUnit.Case, async: true

  alias Hermes.Message

  test "builder helpers return a message" do
    message =
      Message.new()
      |> Message.channel(:sms)
      |> Message.to("+15555550123")
      |> Message.from("Zeus")
      |> Message.subject("A perfectly neutral apple update")
      |> Message.body("Paris, Zeus says the apple discourse has gotten out of hand. Code 123456.")
      |> Message.html_body(
        "<p>Paris, Zeus says the apple discourse has gotten out of hand. Code 123456.</p>"
      )

    assert %Message{
             channel: :sms,
             to: "+15555550123",
             from: "Zeus",
             subject: "A perfectly neutral apple update",
             body: "Paris, Zeus says the apple discourse has gotten out of hand. Code 123456.",
             html_body:
               "<p>Paris, Zeus says the apple discourse has gotten out of hand. Code 123456.</p>"
           } = message
  end

  test "metadata and provider options merge into their maps" do
    message =
      Message.new()
      |> Message.put_metadata(:purpose, :verification)
      |> Message.put_metadata(:verification_id, "verification-1")
      |> Message.put_provider_option(:template_id, "template-1")
      |> Message.put_provider_option(:idempotency_key, "message-1")

    assert message.metadata == %{purpose: :verification, verification_id: "verification-1"}
    assert message.provider_options == %{template_id: "template-1", idempotency_key: "message-1"}
  end
end
