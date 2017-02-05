defmodule AdmiralStatsParser.Model.TcBookInfo do
  @moduledoc """
  艦娘図鑑
  """

  # 図鑑No.
  defstruct book_no: nil,

    # 艦型
    # 未取得の場合は、空文字列
    ship_class: nil,

    # 艦番号（1〜）
    # 未取得の場合は、-1
    ship_class_index: nil,

    # 艦種
    # 未取得の場合は、空文字列
    ship_type: nil,

    # 艦名
    # 未取得の場合は、"未取得"
    ship_name: nil,

    # 一覧に表示する画像のファイル名
    # 未取得の場合は、空文字列
    card_index_img: nil,

    # 取得済み画像のファイル名
    # Array
    # 未取得の場合は、空の Array
    card_img_list: nil,

    # 画像のバリエーション数
    # 未取得の場合は、0
    variation_num: nil,

    # 取得済みの画像数
    # 未取得の場合は、0
    acquire_num: nil,

    # Lv. (From API version 2)
    # 未取得の場合は、0
    lv: nil,

    # 艦娘のステータス画像（横長の画像）のファイル名 (From API version 2)
    # Array
    # 未取得の場合は、空の Array
    status_img: nil
end
