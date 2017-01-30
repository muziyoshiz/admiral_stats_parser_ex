defmodule AdmiralStatsParser do
  @start_of_v2 Timex.parse!("2016-06-30T07:00:00+09:00", "{ISO:Extended}")
  @start_of_v3 Timex.parse!("2016-09-15T07:00:00+09:00", "{ISO:Extended}")
  @start_of_v4 Timex.parse!("2016-10-27T07:00:00+09:00", "{ISO:Extended}")
  @start_of_v5 Timex.parse!("2016-12-21T07:00:00+09:00", "{ISO:Extended}")

  def get_latest_api_version() do
    5
  end

  def guess_api_version(exported_at) do
    cond do
      # version 2 の開始日
      Timex.before?(exported_at, @start_of_v2) ->
        1
      # version 3 の開始日
      Timex.before?(exported_at, @start_of_v3) ->
        2
      # version 4 の開始日
      Timex.before?(exported_at, @start_of_v4) ->
        3
      # version 5 の開始日
      Timex.before?(exported_at, @start_of_v5) ->
        4
      true ->
        get_latest_api_version()
    end
  end
end
