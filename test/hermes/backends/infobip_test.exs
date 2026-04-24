defmodule Hermes.Backends.InfobipTest do
  use ExUnit.Case, async: true

  alias Hermes.Backends.Infobip
  alias Hermes.Message

  setup do
    Req.Test.verify_on_exit!()
  end

  test "posts SMS messages to Infobip with authorization header and message sender" do
    Req.Test.expect(__MODULE__, fn conn ->
      assert conn.method == "POST"
      assert conn.request_path == "/sms/3/messages"
      assert Plug.Conn.get_req_header(conn, "authorization") == ["App test-api-key"]

      body = conn |> Req.Test.raw_body() |> Jason.decode!()

      assert body == %{
               "messages" => [
                 %{
                   "sender" => "Zeus",
                   "destinations" => [%{"to" => "+15555550123"}],
                   "content" => %{
                     "text" =>
                       "Paris, Zeus says the apple discourse has gotten out of hand. Code 123456."
                   }
                 }
               ]
             }

      Req.Test.json(conn, %{"messages" => [%{"messageId" => "message-1"}]})
    end)

    message =
      Message.new()
      |> Message.channel(:sms)
      |> Message.to("+15555550123")
      |> Message.body("Paris, Zeus says the apple discourse has gotten out of hand. Code 123456.")

    assert {:ok, %{provider: "infobip", channel: :sms, to: "+15555550123"}} =
             Infobip.deliver(message, infobip_config())
  end

  test "message sender overrides configured sender" do
    Req.Test.expect(__MODULE__, fn conn ->
      body = conn |> Req.Test.raw_body() |> Jason.decode!()

      assert get_in(body, ["messages", Access.at(0), "sender"]) == "Hera"

      Req.Test.json(conn, %{})
    end)

    message =
      Message.new()
      |> Message.channel(:sms)
      |> Message.from("Hera")
      |> Message.to("+15555550123")
      |> Message.body("Achilles, Hera says to guard the heel this time.")

    assert {:ok, %{provider: "infobip"}} = Infobip.deliver(message, infobip_config())
  end

  test "non-2xx responses return an Infobip error tuple" do
    Req.Test.expect(__MODULE__, fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(
        400,
        Jason.encode!(%{requestError: %{serviceException: %{messageId: "BAD"}}})
      )
    end)

    message =
      Message.new()
      |> Message.channel(:sms)
      |> Message.to("+15555550123")
      |> Message.body("Odysseus, Poseidon says no hard feelings. Probably.")

    assert {:error,
            {:infobip_error, 400,
             %{"requestError" => %{"serviceException" => %{"messageId" => "BAD"}}}}} =
             Infobip.deliver(message, infobip_config())
  end

  test "unsupported channels return an explicit error" do
    message =
      Message.new()
      |> Message.channel(:whatsapp)
      |> Message.to("+15555550123")
      |> Message.body("Cassandra, Apollo says this one is totally worth believing.")

    assert Infobip.deliver(message, infobip_config()) ==
             {:error, {:unsupported_channel, Hermes.Backends.Infobip, :whatsapp}}
  end

  defp infobip_config do
    [
      api_key: "test-api-key",
      base_url: "https://infobip.test",
      from: "Zeus",
      req_options: [plug: {Req.Test, __MODULE__}]
    ]
  end
end
