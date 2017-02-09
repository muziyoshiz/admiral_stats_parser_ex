defmodule AdmiralStatsParser.Summarizer.EventInfoSummarizer do
  # # 与えられたリストから、現在の周回数を返します。
  def current_loop_counts(event_info_list, level) do
  #   # 指定されたレベルの情報のみ取り出し
  #   list = event_info_list.select{|info| info.level == level }
  #
  #   # 現在の周回数
  #   list.map{|i| i.loop_count }.max
    0
  end

  # 与えられたリストから、クリア済みの周回数を返します。
  def cleared_loop_counts(event_info_list, level) do
  #   # 指定されたレベルの情報のみ取り出し
  #   list = event_info_list.select{|info| info.level == level }
  #
  #   # その周回をクリア済みかどうか
  #   cleared = EventInfoParser.all_cleared?(event_info_list, level)
  #
  #   # 現在の周回数
  #   loop_count = list.map{|i| i.loop_count }.max
  #
  #   cleared ? loop_count : loop_count - 1
    0
  end

  # 与えられたリストから、現在の周回でクリア済みのステージ No. を返します。
  # 丙 E-1 クリア済みの場合も、乙 E-1 クリア済みの場合も 1 を返します。
  # E-1 未クリアの場合は 0 を返します。
  def cleared_stage_no(event_info_list, level) do
  #   # その難易度が未開放の場合は、0 を返す
  #   return 0 unless EventInfoParser.opened?(event_info_list, level)
  #
  #   # 指定されたレベルの情報を、サブ海域番号の小さい順に取り出し
  #   list = event_info_list.select{|info| info.level == level}.sort_by {|info| info.area_sub_id }
  #
  #   list.each_with_index do |info, prev_stage_no|
  #     return prev_stage_no if info.area_clear_state == 'NOTCLEAR'
  #   end
  #
  #   # NOTCLEAR のエリアがなければ、最終海域の番号を返す
  #   list.size
    0
  end

  # 与えられたリストから、攻略中のステージの海域ゲージの現在値を返します。
  # 全ステージクリア後、および掃討戦の場合は 0 を返します。
  def current_military_gauge_left(event_info_list, level) do
  #   # 全ステージクリア後は 0 を返す
  #   return 0 if EventInfoParser.all_cleared?(event_info_list, level)
  #
  #   # 指定されたレベルの情報を、サブ海域番号の小さい順に取り出し
  #   list = event_info_list.select{|info| info.level == level}.sort_by {|info| info.area_sub_id }
  #
  #   list.each do |info|
  #     if info.area_clear_state == 'NOTCLEAR' or info.area_clear_state == 'NOOPEN'
  #       return info.military_gauge_left
  #     end
  #   end
  #
  #   # NOTCLEAR のエリアがなければ 0 を返す
  #   0
    0
  end

  # 与えられた難易度が解放済みの場合に true を返します。
  def opened?(event_info_list, level) do
  #   # 指定されたレベルの情報を、サブ海域番号の小さい順に取り出し
  #   list = event_info_list.select{|info| info.level == level}.sort_by {|info| info.area_sub_id }
  #
  #   # その難易度のデータがなければ、未開放と見なす（通常は発生しない）
  #   return false if list.size == 0
  #
  #   # 最初の海域の状態が NOOPEN の場合は未開放
  #   return false if list.first.area_clear_state == 'NOOPEN'
  #
  #   true
    true
  end

  # 与えられた難易度の全海域をクリア済みの場合に true を返します。
  # その難易度が解放済みで、かつ 'NOTCLEAR' の海域が存在しない場合はクリア済みとみなします。
  def all_cleared?(event_info_list, level) do
  #   return false unless EventInfoParser.opened?(event_info_list, level)
  #
  #   # 指定されたレベルの情報を、サブ海域番号の小さい順に取り出し
  #   list = event_info_list.select{|info| info.level == level}.sort_by {|info| info.area_sub_id }
  #   list.select{|i| i.area_clear_state == 'NOTCLEAR' }.size == 0
    true
  end
end
