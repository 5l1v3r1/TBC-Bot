defmodule TBC.Commands.Eval do
  alias Coxir.Struct.{User, Channel, Message}
  import TBC.Helpers

  def exec(message, channel, string) do
    binding = [
      user: User.get(),
      channel: channel,
      message: message
    ]

    if message.channel != nil and message.channel.id do
      Channel.typing(message.channel.id)
    end

    try do
      string
      |> Code.eval_string(binding, __ENV__)
      |> elem(0)
      |> (fn result ->
        Message.react(message, "✅")
        Message.reply(
          message,
          embed: buildSuccessEmbed(
            """
            ```elixir
            #{inspect result}
            ```
            """
          )
        )
      end).()
    rescue
      error ->
        Message.react(message, "❌")
        Message.reply(
          message,
          embed: buildErrorEmbed(
            """
            ```elixir
            #{inspect error}
            ```
            """
          )
        )
        error
    end
    |> case do
      %{error: error} ->
        Message.reply(
          message,
          embed: buildErrorEmbed(
            """
            ```elixir
            #{inspect error}
            ```
            """
          )
        )
      _success ->  :ok
    end
  end
end
