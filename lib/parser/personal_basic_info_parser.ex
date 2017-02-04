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
  defp validate_keys(json_obj, api_version) do
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

  @doc """
  JSON オブジェクトに含まれる値を格納した PersonalBasicInfo 構造体を返します。

  ## パラメータ

    - validation_res: validate_keys 関数の返り値
    - api_version: API version

  ## 返り値

    {:ok, PersonalBasicInfo.t} |
    {:error, error_msg}
  """
  defp create_struct(validation_res, api_version) do
    case validation_res do
      {:ok, json_obj} ->
        # 結果を格納する構造体
        obj = %PersonalBasicInfo{} |>
              set_mandatory_values(json_obj, Map.to_list(@mandatory_keys[api_version])) |>
              set_optional_values(json_obj, Map.to_list(@optional_keys[api_version]))
        {:ok, obj}
      _ ->
        validation_res
    end
  end

  def set_mandatory_values(obj, _json_obj, []) do
    obj
  end

  @doc """
  与えられた構造体に、与えられた JSON オブジェクトの内容を格納した結果を返します。
  json_obj には、keys が示すキーがすべて含まれている必要があります。

  ## パラメータ

    - obj: 返り値として使われる構造体
    - json_obj: JSON オブジェクト
    - keys: {キー名, バリデーション関数} のリスト

  ## 返り値

  JSON オブジェクトの内容を格納した構造体
  """
  def set_mandatory_values(obj, json_obj, keys) do
    [ {key, _} | keys_tail ] = keys
    json_key = ParserUtil.to_camel_case(key)
    atom = String.to_atom(key)
    obj = Map.put(obj, atom, json_obj[json_key])
    set_mandatory_values(obj, json_obj, keys_tail)
  end

  def set_optional_values(obj, _json_obj, []) do
    obj
  end

  @doc """
  与えられた構造体に、与えられた JSON オブジェクトの内容を格納した結果を返します。
  json_obj には、keys が示すキーがすべて含まれている必要はありません。

  ## パラメータ

    - obj: 返り値として使われる構造体
    - json_obj: JSON オブジェクト
    - keys: {キー名, バリデーション関数} のリスト

  ## 返り値

  JSON オブジェクトの内容を格納した構造体
  """
  def set_optional_values(obj, json_obj, keys) do
    [ {key, _} | keys_tail ] = keys

    json_key = ParserUtil.to_camel_case(key)

    case Map.has_key?(json_obj, json_key) do
      true ->
        atom = String.to_atom(key)
        obj = Map.put(obj, atom, json_obj[json_key])
        set_optional_values(obj, json_obj, keys_tail)
      false ->
        set_optional_values(obj, json_obj, keys_tail)
    end
  end
end
