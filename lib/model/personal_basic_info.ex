defmodule AdmiralStatsParser.Model.PersonalBasicInfo do
  @moduledoc """
  基本情報
  """

  defstruct [
    # 提督名
    :admiral_name,

    # 燃料
    :fuel,

    # 弾薬
    :ammo,

    # 鋼材
    :steel,

    # ボーキサイト
    :bauxite,

    # 修復バケツ
    :bucket,

    # 艦隊司令部Level
    :level,

    # 家具コイン
    :room_item_coin,

    # 戦果 (From API version 2)
    # 戦果は数値だが、なぜか STRING 型で返される。どういう場合に文字列が返されるのか？
    :result_point,

    # 暫定順位 (From API version 2)
    # 数値または「圏外」
    :rank,

    # 階級を表す数値 (From API version 2)
    :title_id,

    # 最大備蓄可能各資源量 (From API version 2)
    :material_max,

    # 戦略ポイント (From API version 2)
    :strategy_point,
  ]
end
