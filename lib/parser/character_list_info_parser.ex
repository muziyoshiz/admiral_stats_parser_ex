defmodule AdmiralStatsParser.Parser.CharacterListInfoParser do
  @moduledoc """
  艦娘一覧をパースするためのモジュールです。
  """

  alias AdmiralStatsParser.Parser.ParserUtil
  alias AdmiralStatsParser.Model.CharacterListInfo

  # API version ごとの必須キーを格納したマップ
  @mandatory_keys %{
    1 => %{
      "book_no" => &is_integer/1,
      "lv" => &is_integer/1,
      "ship_type" => &ParserUtil.string?/1,
      "ship_sort_no" => &is_integer/1,
      "remodel_lv" => &is_integer/1,
      "ship_name" => &ParserUtil.string?/1,
      "status_img" => &ParserUtil.string?/1,
    },
    2 => %{
      "book_no" => &is_integer/1,
      "lv" => &is_integer/1,
      "ship_type" => &ParserUtil.string?/1,
      "ship_sort_no" => &is_integer/1,
      "remodel_lv" => &is_integer/1,
      "ship_name" => &ParserUtil.string?/1,
      "status_img" => &ParserUtil.string?/1,
      "star_num" => &is_integer/1,
    },
    3 => %{
      "book_no" => &is_integer/1,
      "lv" => &is_integer/1,
      "ship_type" => &ParserUtil.string?/1,
      "ship_sort_no" => &is_integer/1,
      "remodel_lv" => &is_integer/1,
      "ship_name" => &ParserUtil.string?/1,
      "status_img" => &ParserUtil.string?/1,
      "star_num" => &is_integer/1,
      "ship_class" => &ParserUtil.string?/1,
      "ship_class_index" => &is_integer/1,
      "tc_img" => &ParserUtil.string?/1,
      "exp_percent" => &is_integer/1,
      "max_hp" => &is_integer/1,
      "real_hp" => &is_integer/1,
      "damage_status" => &ParserUtil.string?/1,
      "slot_num" => &is_integer/1,
      "slot_equip_name" => &ParserUtil.string_list?/1,
      "slot_amount" => &ParserUtil.integer_list?/1,
      "slot_disp" => &ParserUtil.string_list?/1,
      "slot_img" => &ParserUtil.string_list?/1,
    }
  }

  # API version ごとの任意キーを格納したマップ
  @optional_keys %{
    1 => %{},
    2 => %{},
    3 => %{}
  }

  @doc """
  与えられた JSON 文字列をデコードし、構造体に格納して返します。

  ## パラメータ

    - json: JSON 文字列
    - version: API version

  ## 返り値

    {:ok, [CharacterListInfo.t]} |
    {:error, error_msg}
  """
  def parse(json, version) do
    case Poison.decode(json) do
      {:ok, json_objects} ->
        create_structs([], json_objects, @mandatory_keys[version], @optional_keys[version])
      {:error, {:invalid, msg}} ->
        {:error, "Failed to decode json: " <> msg}
      {:error, _} ->
        {:error, "Failed to decode json"}
    end
  end

  # json_objects からすべてのオブジェクトを取り出し終えたら、成功のレスポンスを返す
  defp create_structs(objects, [], _, _) do
    {:ok, objects}
  end

  # json_objects の1個目のオブジェクトを取り出し、構造体に変換
  defp create_structs(objects, json_objects, mandatory_keys, optional_keys) do
    [json_obj | rest_json_objects] = json_objects
    {res, obj} =
      json_obj
      |> ParserUtil.validate_keys(mandatory_keys, optional_keys)
      |> ParserUtil.create_struct(%CharacterListInfo{}, mandatory_keys, optional_keys)
    case res do
      :ok ->
        objects = objects ++ [obj]
        create_structs(objects, rest_json_objects, mandatory_keys, optional_keys)
      :error ->
        {:error, obj}
    end
  end
end
