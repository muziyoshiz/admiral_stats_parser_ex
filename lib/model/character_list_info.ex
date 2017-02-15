defmodule AdmiralStatsParser.Model.CharacterListInfo do
  @moduledoc """
  艦娘一覧
  """

  defstruct [
    # 図鑑No.
    :book_no,

    # Lv.
    :lv,

    # 艦種
    :ship_type,

    # 艦種順でソートする際に使うキー
    :ship_sort_no,

    # 艦娘の改造度合いを表す数値
    # （未改造の艦娘と、改造済みの艦娘が、別のデータとして返される）
    # 0: 未改造
    # 1: 改
    :remodel_lv,

    # 艦名
    :ship_name,

    # 艦娘のステータス画像（横長の画像）のファイル名
    :status_img,

    # 星の数（1〜5）
    :star_num,

    # 艦型
    # 未取得の場合は、空文字列
    :ship_class,

    # 艦番号（1〜）
    # 未取得の場合は、-1
    :ship_class_index,

    # 詳細画面で表示する画像のファイル名
    :tc_img,

    # 経験値の獲得割合(%)
    :exp_percent,

    # 最大HP
    :max_hp,

    # 現在HP
    :real_hp,

    # 被弾状態を表す文字列（"NORMAL" 以外に何がある？）
    :damage_status,

    # 装備スロット数
    :slot_num,

    # 各スロットの装備名を表す文字列の List（スロット数が4未満でも、要素は4個）
    :slot_equip_name,

    # 各スロットに搭載可能な艦載機数の List（スロット数が4未満でも、要素は4個）
    # 艦載機を搭載できない場合は 0
    :slot_amount,

    # 各スロットの搭載状況を表す文字列の List（スロット数が4未満でも、要素は4個）
    # "NONE":
    # "NOT_EQUIPPED_AIRCRAFT": 艦載機を装備可能なスロットだが、艦載機を装備していない
    # "EQUIPPED_AIRCRAFT": 艦載機を装備している
    :slot_disp,

    # 各スロットの装備画像のファイル名の List（スロット数が4未満でも、要素は4個）
    # 何も装備していない場合、および装備可能なスロットでない場合は、空文字列
    :slot_img,
  ]
end
