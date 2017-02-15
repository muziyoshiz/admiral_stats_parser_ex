defmodule AdmiralStatsParser.Model.TcBookInfo do
  @moduledoc """
  艦娘図鑑
  """

  defstruct [
    # 図鑑No.
    :book_no,

    # 艦型
    # 未取得の場合は、空文字列
    :ship_class,

    # 艦番号（1〜）
    # 未取得の場合は、-1
    :ship_class_index,

    # 艦種
    # 未取得の場合は、空文字列
    :ship_type,

    # 艦名
    # 未取得の場合は、"未取得"
    :ship_name,

    # 一覧に表示する画像のファイル名
    # 未取得の場合は、空文字列
    :card_index_img,

    # 取得済み画像のファイル名
    # List
    # 未取得の場合は、空の List
    :card_img_list,

    # 画像のバリエーション数
    # 未取得の場合は、0
    :variation_num,

    # 取得済みの画像数
    # 未取得の場合は、0
    :acquire_num,

    # Lv. (From API version 2)
    # 未取得の場合は、0
    :lv,

    # 艦娘のステータス画像（横長の画像）のファイル名 (From API version 2)
    # List
    # 未取得の場合は、空の List
    :status_img,
  ]
end
