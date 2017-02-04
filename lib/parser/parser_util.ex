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
end
