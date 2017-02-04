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
