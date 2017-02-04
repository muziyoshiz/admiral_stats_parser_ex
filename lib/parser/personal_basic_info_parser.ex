defmodule AdmiralStatsParser.Parser.PersonalBasicInfoParser do
  @moduledoc """

  """

  alias AdmiralStatsParser.Parser.ParserUtil
  alias AdmiralStatsParser.Model.PersonalBasicInfo

  # API version ごとの必須キーを格納したマップ
  @mandatory_keys %{
    1 => %{
      "fuel" => &is_integer/1,
      "ammo" => &is_integer/1,
      "steel" => &is_integer/1,
      "bauxite" => &is_integer/1,
      "bucket" => &is_integer/1,
      "level" => &is_integer/1,
      "room_item_coin" => &is_integer/1,
    },
    2 => %{
      "fuel" => &is_integer/1,
      "ammo" => &is_integer/1,
      "steel" => &is_integer/1,
      "bauxite" => &is_integer/1,
      "bucket" => &is_integer/1,
      "level" => &is_integer/1,
      "room_item_coin" => &is_integer/1,
      "result_point" => &ParserUtil.is_string/1,
      "rank" => &ParserUtil.is_string/1,
      "title_id" => &is_integer/1,
      "material_max" => &is_integer/1,
      "strategy_point" => &is_integer/1,
    }
  }

  # API version ごとの任意キーを格納したマップ
  @optional_keys %{
    1 => %{
      # 元のデータには必ず提督名が含まれるが、データ解析の上では不要のため、オプションとする
      "admiral_name" => &ParserUtil.is_string/1,
    },
    2 => %{
      "admiral_name" => &ParserUtil.is_string/1,
    }
  }

  @doc """
  与えられた JSON 文字列をデコードし、構造体に格納して返します。

  ## パラメータ

    - json: JSON 文字列
    - api_version: API version

  ## 返り値

    {:ok, PersonalBasicInfo.t} |
    {:error, error_msg}
  """
  def parse(json, api_version) do
    case Poison.decode(json) do
      {:ok, json_obj} ->
        json_obj
        |> validate_keys(api_version)
        |> create_struct(api_version)
      {:error, {:invalid, msg}} ->
        {:error, "Failed to decode json: " <> msg}
      {:error, _} ->
        {:error, "Failed to decode json"}
    end
  end

  @doc """
  与えられた JSON オブジェクトに含まれるキーおよび値を検査します。

  ## パラメータ

    - json_obj: JSON を Poison.decode/1 でデコードした結果
    - api_version: API version

  ## 返り値

    {:ok, json_obj} |
    {:error, error_msg}
  """
  def validate_keys(json_obj, api_version) do
    # 必須のキーだが、items に含まれないキーのリスト
    missing_man_keys = Enum.filter(@mandatory_keys[api_version], fn {key, _} ->
      json_key = ParserUtil.to_camel_case(key)
      !Map.has_key?(json_obj, json_key)
    end)

    # 必須のキーで、items に含まれるが、型が合わないキーのリスト
    invalid_man_keys = Enum.filter(@mandatory_keys[api_version], fn {key, key_validator} ->
      json_key = ParserUtil.to_camel_case(key)
      Map.has_key?(json_obj, json_key) and !key_validator.(json_obj[json_key])
    end)

    # 任意のキーで、items に含まれるが、型が合わないキーのリスト
    invalid_opt_keys = Enum.filter(@optional_keys[api_version], fn {key, key_validator} ->
      json_key = ParserUtil.to_camel_case(key)
      Map.has_key?(json_obj, json_key) and !key_validator.(json_obj[json_key])
    end)

    # validation に失敗した場合、一番最初に発見されたエラーのみを返す
    cond do
      !Enum.empty?(missing_man_keys) ->
        [{key, _} | _ ] = missing_man_keys
        {:error, "Mandatory key #{key} does not exist"}
      !Enum.empty?(invalid_man_keys) ->
        [{key, _} | _ ] = invalid_man_keys
        {:error, "Mandatory key #{key} is invalid"}
      !Enum.empty?(invalid_opt_keys) ->
        [{key, _} | _ ] = invalid_opt_keys
        {:error, "Optional key #{key} is invalid"}
      true ->
        {:ok, json_obj}
    end
  end

  def create_struct(validation_result, api_version) do
    cond do
      {:ok, items} = validation_result ->
        # 結果を格納する構造体
        result = %PersonalBasicInfo{}
        result = aaa(result, items, Map.to_list(@mandatory_keys[api_version]))
        result = bbb(result, items, Map.to_list(@optional_keys[api_version]))
        {:ok, result}
      true ->
        validation_result
    end
  end

  def aaa(result, _items, []) do
    result
  end

  def aaa(result, items, keys) do
    [ {key, _} | keys_tail ] = keys
    # キー名を snake_case から camelCase に変換する
    camel_case_key = ParserUtil.to_camel_case(key)
    atom = String.to_atom(key)
    result = Map.put(result, atom, items[camel_case_key])
    aaa(result, items, keys_tail)
  end

  def bbb(result, _items, []) do
    result
  end

  def bbb(result, items, keys) do
    [ {key, _} | keys_tail ] = keys
    # キー名を snake_case から camelCase に変換する
    camel_case_key = ParserUtil.to_camel_case(key)

    if Map.has_key?(items, camel_case_key) do
      atom = String.to_atom(key)
      result = Map.put(result, atom, items[camel_case_key])
    end

    bbb(result, items, keys_tail)
  end
end
