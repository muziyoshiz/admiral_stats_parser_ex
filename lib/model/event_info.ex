defmodule AdmiralStatsParser.Model.EventInfo do
  @moduledoc """
  イベント進捗情報
  """

  # 海域番号
  # 期間限定海域「敵艦隊前線泊地殴り込み」では、共通して 1000
  defstruct area_id: nil,

    # サブ海域番号
    # 期間限定海域「敵艦隊前線泊地殴り込み」では、1 〜 10
    area_sub_id: nil,

    # 難易度
    # "HEI": 丙
    # "OTU": 乙
    level: nil,

    # 海域の種類
    # ボス戦は "BOSS"
    # 掃討戦は "SWEEP"
    # それ以外は "NORMAL"
    area_kind: nil,

    # 作戦時間（秒）
    # 未表示の場合は 0
    limit_sec: nil,

    # 必要GP
    # 未表示の場合は 0
    require_gp: nil,

    # 出撃条件の有無（true ならある）
    sortie_limit: nil,

    # 海域画像のファイル名
    stage_image_name: nil,

    # 作戦名
    # 未表示の場合は "？"
    stage_mission_name: nil,

    # 作戦内容
    # 未表示の場合は "？"
    stage_mission_info: nil,

    # 海域撃破ボーナス(EventInfo.Reward)のリスト
    reward_list: nil,

    # 主な出現アイテム
    # アイテムを表す文字列の配列（要素数は4固定）
    stage_drop_item_info: nil,

    # クリア状態を表す文字列
    # CLEAR: クリア済み
    # NOTCLEAR: 出撃可能だが未クリア
    # NOOPEN: 出撃不可（掃討戦クリア後は CLEAR にならず NOOPEN に戻る）
    area_clear_state: nil,

    # 海域ゲージの状態
    # "NORMAL": 攻略中
    # "BREAK": 攻略後
    military_gauge_status: nil,

    # 海域ゲージの最大値
    # E-1 攻略開始前は 1000、攻略後も 1000
    ene_military_gauge_val: nil,

    # 海域ゲージの現在値
    # E-1 攻略開始前は 1000、攻略後は 0
    military_gauge_left: nil,

    # ボスのランク
    # 泊地棲鬼は "ONI"
    # ゲージ半減して泊地棲姫になると "HIME"
    # それ以外は "NONE"
    boss_status: nil,

    # 周回数
    # E-1 攻略開始前は 1、攻略後も 1
    loop_count: nil
end
