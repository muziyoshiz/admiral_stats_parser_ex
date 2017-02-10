defmodule AdmiralStatsParser.Summarizer.EventInfoSummarizer do
  @doc """
  与えられた EventInfo のリストから、現在の周回数を返します。

  ## パラメータ

    - event_info_list: EventInfo のリスト
    - level: 難易度を表す文字列

  ## 返り値

    integer
  """
  def current_loop_counts(event_info_list, level) do
    # 指定されたレベルの情報のみ取り出し
    event_info_list
    |> Enum.filter(&(&1.level == level))
    |> Enum.map(&(&1.loop_count))
    |> Enum.max(fn -> 0 end)
  end

  @doc """
  与えられた EventInfo のリストから、クリア済みの周回数を返します。

  ## パラメータ

    - event_info_list: EventInfo のリスト
    - level: 難易度を表す文字列

  ## 返り値

    integer
  """
  def cleared_loop_counts(event_info_list, level) do
    # 現在の周回数
    loop_count = current_loop_counts(event_info_list, level)

    # その周回をクリア済みなら周回数、そうでなければ周回数 - 1 がクリア済み周回数
    case all_cleared?(event_info_list, level) do
      true -> loop_count
      false -> loop_count - 1
    end
  end

  # 与えられたリストから、現在の周回でクリア済みのステージ No. を返します。
  # 丙 E-1 クリア済みの場合も、乙 E-1 クリア済みの場合も 1 を返します。
  # E-1 未クリアの場合は 0 を返します。
  def cleared_stage_no(event_info_list, level) do
    case opened?(event_info_list, level) do
      # その難易度が未開放の場合は、0 を返す
      false -> 0
      true ->
        event_info_list
        |> Enum.filter(&(&1.level == level))
        |> Enum.sort_by(&(&1.area_sub_id))
        |> last_cleared_stage_no(0)
    end
  end

  # すべてのステージをクリア済みの場合は、最後のステージの番号を返します。
  defp last_cleared_stage_no([], prev_stage_no) do
    prev_stage_no
  end

  # 最後に area_clear_stage が "NOTCLEAR" ではなかったステージの番号を返します。
  # event_info_list は area_sub_id の順にソートされているものとします。
  defp last_cleared_stage_no(event_info_list, prev_stage_no) do
    [event_info | event_info_list] = event_info_list
    case event_info.area_clear_state do
      "NOTCLEAR" ->
        prev_stage_no
      _ ->
        last_cleared_stage_no(event_info_list, prev_stage_no + 1)
    end
  end

  # 与えられたリストから、攻略中のステージの海域ゲージの現在値を返します。
  # 全ステージクリア後、および掃討戦の場合は 0 を返します。
  def current_military_gauge_left(event_info_list, level) do
    event_info_list
    |> Enum.filter(&(&1.level == level))
    |> Enum.sort_by(&(&1.area_sub_id))
    |> first_military_gauge_left()
  end

  # すべてのステージをクリア済みの場合は 0 を返します。
  defp first_military_gauge_left([]) do
    0
  end

  # 最初に area_clear_stage が "NOTCLEAR" または "NOOPEN" だったステージの残りゲージを返します。
  # event_info_list は area_sub_id の順にソートされているものとします。
  defp first_military_gauge_left(event_info_list) do
    [event_info | event_info_list] = event_info_list
    cond do
      event_info.area_clear_state == "NOTCLEAR" || event_info.area_clear_state == "NOOPEN" ->
        event_info.military_gauge_left
      true ->
        first_military_gauge_left(event_info_list)
    end
  end

  @doc """
  与えられた難易度が解放済みの場合に true を返します。

  ## パラメータ

    - event_info_list: EventInfo のリスト
    - level: 難易度を表す文字列

  ## 返り値

    boolean
  """
  def opened?(event_info_list, level) do
    # 指定されたレベルの情報を、サブ海域番号の小さい順に取り出し
    list = event_info_list
      |> Enum.filter(&(&1.level == level))
      |> Enum.sort_by(&(&1.area_sub_id))

    cond do
      # その難易度のデータがなければ、未開放と見なす（通常は発生しない）
      Enum.count(list) == 0 -> false
      # 最初の海域の状態が NOOPEN の場合は未開放
      Enum.at(list, 0).area_clear_state == "NOOPEN" -> false
      # それ以外の場合は解放済み
      true -> true
    end
  end

  @doc """
  与えられた難易度の全海域をクリア済みの場合に true を返します。
  その難易度が解放済みで、かつ "NOTCLEAR" の海域が存在しない場合はクリア済みとみなします。

  ## パラメータ

    - event_info_list: EventInfo のリスト
    - level: 難易度を表す文字列

  ## 返り値

    boolean
  """
  def all_cleared?(event_info_list, level) do
    case opened?(event_info_list, level) do
      true ->
        event_info_list
        |> Enum.filter(&(&1.level == level))
        |> Enum.filter(&(&1.area_clear_state == "NOTCLEAR"))
        |> Enum.count() == 0
      # 海域を未開放なら、当然未クリア
      false ->
        false
    end
  end
end
