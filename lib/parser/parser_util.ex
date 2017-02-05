defmodule AdmiralStatsParser.Parser.ParserUtil do
  @moduledoc """
  Parser が共通して用いる関数をまとめたモジュールです。
  """

  @doc """
  与えられた引数が、表示可能な文字列の場合に true を返します。

  ## パラメータ

    - term: 検査対象

  ## 返り値

    boolean
  """
  def is_string(term) do
    is_binary(term) and String.printable?(term)
  end

  @doc """
  snake_case で書かれたフィールド名を、JSON に書かれている camelCase（先頭は小文字）に変換します。

  ## パラメータ

    - snake_case: snake_case で書かれたフィールド名

  ## 返り値

    camelCase に変換されたフィールド名
  """
  def to_camel_case(snake_case) do
    [head | tails ] = String.split(snake_case, "_")
    tail = Enum.map(tails, &String.capitalize/1) |> Enum.join
    head <> tail
  end

  @doc """
  与えられた JSON オブジェクトに、必要なキーが、正しい型で含まれているかどうかを検査します。

  複数のエラーがある場合は、最初に発見されたエラーのみをエラーメッセージで通知します。

  ## パラメータ

    - json_obj: JSON オブジェクト
    - mandatory_keys: 必須のキー名（snake_case）と、検査のための関数のマップ
    - optional_keys: オプションのキー名（snake_case）と、検査のための関数のマップ

  ## 返り値

    {:ok, json_obj} |
    {:error, error_msg}
  """
  # 与えられた JSON オブジェクトに含まれるキーおよび値を検査します。
  def validate_keys(json_obj, mandatory_keys, optional_keys) do
    # 必須のキーだが、items に含まれないキーのリスト
    missing_man_keys = Enum.filter(mandatory_keys, fn {key, _} ->
      json_key = to_camel_case(key)
      !Map.has_key?(json_obj, json_key)
    end)

    # 必須のキーで、items に含まれるが、型が合わないキーのリスト
    invalid_man_keys = Enum.filter(mandatory_keys, fn {key, key_validator} ->
      json_key = to_camel_case(key)
      Map.has_key?(json_obj, json_key) and !key_validator.(json_obj[json_key])
    end)

    # 任意のキーで、items に含まれるが、型が合わないキーのリスト
    invalid_opt_keys = Enum.filter(optional_keys, fn {key, key_validator} ->
      json_key = to_camel_case(key)
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
  JSON オブジェクトに含まれる値を格納した構造体を返します。

  validation_res がエラーの場合は、validation_res をそのまま返します。

  ## パラメータ

    - validation_res: validate_keys 関数の返り値
    - obj: 返り値を格納する構造体
    - mandatory_keys: 必須のキー名（snake_case）と、検査のための関数のマップ
    - optional_keys: オプションのキー名（snake_case）と、検査のための関数のマップ

  ## 返り値

    {:ok, obj} |
    {:error, error_msg}
  """
  def create_struct(validation_res, obj, mandatory_keys, optional_keys) do
    case validation_res do
      {:ok, json_obj} ->
        # 結果を格納する構造体
        obj = obj |>
              set_mandatory_values(json_obj, Map.keys(mandatory_keys)) |>
              set_optional_values(json_obj, Map.keys(optional_keys))
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
    - keys: 構造体のフィールド名のリスト

  ## 返り値

    JSON オブジェクトの内容を格納した構造体
  """
  def set_mandatory_values(obj, json_obj, keys) do
    [ key | keys_tail ] = keys
    json_key = to_camel_case(key)
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
    - keys: 構造体のフィールド名のリスト

  ## 返り値

    JSON オブジェクトの内容を格納した構造体
  """
  def set_optional_values(obj, json_obj, keys) do
    [ key | keys_tail ] = keys

    json_key = to_camel_case(key)

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
