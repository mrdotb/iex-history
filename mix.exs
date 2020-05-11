defmodule IexHistory.MixProject do
  use Mix.Project

  def project do
    [
      app: :"iex-history",
      version: "0.1.0",
      elixir: "~> 1.10",
      elixirc_paths: ["."],
      escript: escript()
    ]
  end

  defp escript do
    [main_module: IexHistory]
  end
end
