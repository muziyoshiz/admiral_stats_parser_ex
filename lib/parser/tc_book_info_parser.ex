defmodule AdmiralStatsParser.Parser.TcBookInfoParser do
  @moduledoc """
  艦娘図鑑をパースするためのモジュールです。
  """

  alias AdmiralStatsParser.Parser.ParserUtil
  alias AdmiralStatsParser.Model.TcBookInfo

  # API version ごとの必須キーを格納したマップ
  @mandatory_keys %{
    1 => %{
      "book_no" => &is_integer/1,
      "ship_class" => &ParserUtil.is_string/1,
      "ship_class_index" => &is_integer/1,
      "ship_type" => &ParserUtil.is_string/1,
      "ship_name" => &ParserUtil.is_string/1,
      "card_index_img" => &ParserUtil.is_string/1,
      "card_img_list" => &ParserUtil.is_string_list/1,
      "variation_num" => &is_integer/1,
      "acquire_num" => &is_integer/1,
    },
    2 => %{
      "book_no" => &is_integer/1,
      "ship_class" => &ParserUtil.is_string/1,
      "ship_class_index" => &is_integer/1,
      "ship_type" => &ParserUtil.is_string/1,
      "ship_name" => &ParserUtil.is_string/1,
      "card_index_img" => &ParserUtil.is_string/1,
      "card_img_list" => &ParserUtil.is_string_list/1,
      "variation_num" => &is_integer/1,
      "acquire_num" => &is_integer/1,
      "lv" => &is_integer/1,
      "status_img" => &ParserUtil.is_string_list/1,
    }
  }

  # API version ごとの任意キーを格納したマップ
  @optional_keys %{
    1 => %{},
    2 => %{}
  }

  @doc """
  与えられた JSON 文字列をデコードし、構造体に格納して返します。

  ## パラメータ

    - json: JSON 文字列
    - version: API version

  ## 返り値

    {:ok, [TcBookInfo.t]} |
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
    {res, obj} = json_obj
      |> ParserUtil.validate_keys(mandatory_keys, optional_keys)
      |> ParserUtil.create_struct(%TcBookInfo{}, mandatory_keys, optional_keys)
    case res do
      :ok ->
        objects = objects ++ [obj]
        create_structs(objects, rest_json_objects, mandatory_keys, optional_keys)
      :error ->
        {:error, obj}
    end
  end
end
