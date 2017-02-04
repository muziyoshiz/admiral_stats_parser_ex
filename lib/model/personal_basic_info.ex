defmodule AdmiralStatsParser.Model.PersonalBasicInfo do
  @moduledoc """
  基本情報
  """

  # 階級を表す数値と、階級名の対応関係
  # 新米少佐
  # 中堅少佐
  # 少佐
  # 新米中佐
  # 中佐
  # 大佐
  # 少将
  # 7: 中将
  # 大将
  # 元帥
  # 集計中
  @titles %{
    7 => "中将",
  }

  # 提督名
  defstruct admiral_name: nil,
    # 燃料
    fuel: nil,

    # 弾薬
    ammo: nil,

    # 鋼材
    steel: nil,

    # ボーキサイト
    bauxite: nil,

    # 修復バケツ
    bucket: nil,

    # 艦隊司令部Level
    level: nil,

    # 家具コイン
    room_item_coin: nil,

    # 戦果 (From API version 2)
    # 戦果は数値だが、なぜか STRING 型で返される。どういう場合に文字列が返されるのか？
    result_point: nil,

    # 暫定順位 (From API version 2)
    # 数値または「圏外」
    rank: nil,

    # 階級を表す数値 (From API version 2)
    title_id: nil,

    # 最大備蓄可能各資源量 (From API version 2)
    material_max: nil,

    # 戦略ポイント (From API version 2)
    strategy_point: nil
end
