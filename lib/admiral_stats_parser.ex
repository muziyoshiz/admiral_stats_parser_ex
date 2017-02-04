defmodule AdmiralStatsParser do
  @moduledoc """
  kancolle-arcade.net からエクスポートした JSON データをパースするためのモジュールです。
  """

  # 各 API version の開始時刻
  # 艦これアーケードは朝 7:00 から稼働するため、開始時刻は 7:00 であると想定する。
  @start_of_v2 Timex.parse!("2016-06-30T07:00:00+09:00", "{ISO:Extended}")
  @start_of_v3 Timex.parse!("2016-09-15T07:00:00+09:00", "{ISO:Extended}")
  @start_of_v4 Timex.parse!("2016-10-27T07:00:00+09:00", "{ISO:Extended}")
  @start_of_v5 Timex.parse!("2016-12-21T07:00:00+09:00", "{ISO:Extended}")

  @doc """
  最新の API version を返します。

  kancolle-arcade.net の提督情報ページから返される JSON メッセージの形式は、
  過去に何度か変更されており、今後も変更される可能性があります。
  このツールでは、kancolle-arcade.net が返す JSON メッセージの形式のことを API version と呼びます。
  """
  def get_latest_api_version() do
    5
  end

  @doc """
  与えられたエクスポート時刻から推測される API version を返します。

  ## パラメータ

    - exported_at: エクスポート時刻

  ## 返り値

    API version（1以上の整数）
  """
  def guess_api_version(exported_at) do
    cond do
      # version 2 の開始日
      Timex.before?(exported_at, @start_of_v2) ->
        1
      # version 3 の開始日
      Timex.before?(exported_at, @start_of_v3) ->
        2
      # version 4 の開始日
      Timex.before?(exported_at, @start_of_v4) ->
        3
      # version 5 の開始日
      Timex.before?(exported_at, @start_of_v5) ->
        4
      true ->
        get_latest_api_version()
    end
  end

  # 基本情報をパースします。
  @doc """
  基本情報をパースし、その結果を格納した構造体を返します。

  ## パラメータ

    - json: JSON 文字列
    - api_version: API version

  ## 返り値

    {:ok, PersonalBasicInfo.t} |
    {:error, error_msg}
  """
  def parse_personal_basic_info(json, api_version) do
    cond do
      api_version == 1 ->
        AdmiralStatsParser.Parser.PersonalBasicInfoParser.parse(json, 1)
      Enum.member?(2..5, api_version) ->
        AdmiralStatsParser.Parser.PersonalBasicInfoParser.parse(json, 2)
      true ->
        {:error, "unsupported API version"}
    end
  end
end
