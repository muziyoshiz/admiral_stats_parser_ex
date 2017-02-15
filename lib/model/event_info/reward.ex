defmodule AdmiralStatsParser.Model.EventInfo.Reward do
  @moduledoc """
  海域撃破ボーナス
  """

  defstruct [
    # 初回攻略時か2回目以降かを表すフラグ
    # "FIRST": 初回
    # "SECOND": 2回目以降
    # 未公開状態の場合は、項目なし
    :reward_type,

    # 表示順（0 〜）
    :data_id,

    # ボーナスの種類
    # "NONE": 未公開状態
    # "RESULT_POINT": 戦果
    # "STRATEGY_POINT": 戦略ポイント
    # "ROOM_ITEM_ICON": 家具コイン
    # "ROOM_ITEM_MEISTER": 特注家具職人
    # "EQUIP": 装備
    :kind,

    # 数値（戦果の場合はポイント数、家具コインの場合はコイン枚数）
    :value,
  ]
end
