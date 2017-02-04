defmodule AdmiralStatsParser.Parser.PersonalBasicInfoParser do
  @moduledoc """

  """

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
      "result_point" => &AdmiralStatsParser.Parser.PersonalBasicInfoParser.is_string/1,
      "rank" => &AdmiralStatsParser.Parser.PersonalBasicInfoParser.is_string/1,
      "title_id" => &is_integer/1,
      "material_max" => &is_integer/1,
      "strategy_point" => &is_integer/1,
    }
  }

  # API version ごとの任意キーを格納したマップ
  @optional_keys %{
    1 => %{
      # 元のデータには必ず提督名が含まれるが、データ解析の上では不要のため、オプションとする
      "admiral_name" => &AdmiralStatsParser.Parser.PersonalBasicInfoParser.is_string/1,
    },
    2 => %{
      "admiral_name" => &AdmiralStatsParser.Parser.PersonalBasicInfoParser.is_string/1,
    }
  }

  def is_string(term) do
    is_binary(term) and String.printable?(term)
  end

  def snake_case_to_camel_case(snake_case) do
    [head | tails ] = String.split(snake_case, "_")
    tail = Enum.map(tails, &String.capitalize/1) |> Enum.join
    head <> tail
  end

  @doc """

  """
  def parse(json, api_version) do
    # JSON のデコード（キー名は camelCase）
    {res, items} = Poison.decode(json)
    case res do
      :ok ->
        items
        |> validate_keys(api_version)
        |> create_struct(api_version)
      :error ->
        {:error, "Failed to decode json"}
    end
  end

  # キーの検査
  def validate_keys(items, api_version) do
    # 必須のキーだが、items に含まれないキーのリスト
    missing_man_keys = Enum.filter(@mandatory_keys[api_version], fn {key, _} ->
      camel_case_key = snake_case_to_camel_case(key)
      !Map.has_key?(items, camel_case_key)
    end)

    # 必須のキーで、items に含まれるが、型が合わないキーのリスト
    invalid_man_keys = Enum.filter(@mandatory_keys[api_version], fn {key, key_validator} ->
      camel_case_key = snake_case_to_camel_case(key)
      Map.has_key?(items, camel_case_key) and !key_validator.(items[camel_case_key])
    end)

    # 任意のキーで、items に含まれるが、型が合わないキーのリスト
    invalid_opt_keys = Enum.filter(@optional_keys[api_version], fn {key, key_validator} ->
      camel_case_key = snake_case_to_camel_case(key)
      Map.has_key?(items, camel_case_key) and !key_validator.(items[camel_case_key])
    end)

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
        {:ok, items}
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
    camel_case_key = snake_case_to_camel_case(key)
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
    camel_case_key = snake_case_to_camel_case(key)

    if Map.has_key?(items, camel_case_key) do
      atom = String.to_atom(key)
      result = Map.put(result, atom, items[camel_case_key])
    end

    bbb(result, items, keys_tail)
  end
end
