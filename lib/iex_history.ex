defmodule IexHistory do
  @doc """
  See erlang log history log implementationa.
  https://github.com/erlang/otp/blob/da04cc20cc1527d142ab1890a44c277f450bfe7f/lib/kernel/src/group_history.erl
  The only change is: the mode we have to put in :read_only
  """

  @default_history_file 'erlang-shell-log'
  @max_history_files 10
  # 512 kb total default
  @default_size 1024 * 512
  # @default_status :disabled
  # 50 kb, in bytes
  @min_history_size 50 * 1024
  # @default_drop []
  # @disk_log_format :internal # since we want repairs
  @log_name "$#group_history"
  # @mode :read_only
  @vsn {0, 1, 0}

  defp find_path() do
    :filename.basedir(:user_cache, 'erlang-history')
  end

  defp find_wrap_values() do
    conf_size =
      case :application.get_env(:kernel, :shell_history_file_bytes) do
        :undefined -> @default_size
        {:ok, s} -> s
      end

    size_per_file = :erlang.max(@min_history_size, :erlang.div(conf_size, @max_history_files))

    file_count =
      cond do
        size_per_file > @min_history_size ->
          @max_history_files

        size_per_file <= @min_history_size ->
          :erlang.max(1, :erlang.div(conf_size, size_per_file))
      end

    {size_per_file, file_count}
  end

  defp log_options() do
    path = find_path()
    file = :filename.join([path, @default_history_file])
    size = find_wrap_values()

    [
      {:name, to_charlist(@log_name)},
      {:file, file},
      {:repair, true},
      {:format, :internal},
      {:type, :wrap},
      {:size, size},
      {:notify, false},
      {:head, {:vsn, @vsn}},
      {:quiet, true},
      {:mode, :read_only}
    ]
    |> IO.inspect()
  end

  defp ensure_path(opts) do
    {:file, path} = :lists.keyfind(:file, 1, opts)
    :filelib.ensure_dir(path)
  end

  defp read_full_log(name) do
    case :disk_log.chunk(name, :start) do
      {:error, :no_such_log} ->
        []

      :eof ->
        []

      {cont, logs} ->
        Enum.reverse(maybe_drop_header(logs) ++ read_full_log(name, cont))
    end
  end

  defp read_full_log(name, cont) do
    case :disk_log.chunk(name, cont) do
      {:error, :no_such_log} ->
        []

      :eof ->
        []

      {nextCont, logs} ->
        maybe_drop_header(logs) ++ read_full_log(name, nextCont)
    end
  end

  defp maybe_drop_header([{:vsn, _} | rest]), do: rest
  defp maybe_drop_header(logs), do: logs

  defp open_log() do
    opts = log_options()
    _ = ensure_path(opts)
    :disk_log.open(opts)
  end

  defp report_error(reason) do
    IO.write(:stderr, "#{inspect(reason)}")
  end

  defp print_logs(nil), do: ""

  defp print_logs(logs) do
    Enum.each(logs, &IO.write/1)
  end

  def main(_args) do
    case open_log() do
      {:ok, log_name} ->
        read_full_log(log_name)

      {:repaired, log_name, {:recovered, _}, {:badbytes, _}} ->
        read_full_log(log_name)

      {:error, reason} ->
        report_error(reason)
    end
    |> print_logs()
  end
end
