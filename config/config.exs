import Config

config :hermes,
  channels: [
    sms: :local,
    whatsapp: :local,
    voice: :local,
    email: :local
  ],
  backends: [
    local: [
      backend: Hermes.Backends.Local,
      from: "Zeus"
    ]
  ]
