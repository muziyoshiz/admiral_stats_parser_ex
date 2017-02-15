defmodule AdmiralStatsParser do
  @moduledoc """
  kancolle-arcade.net からエクスポートした JSON データをパースするためのモジュールです。
  """

  alias AdmiralStatsParser.Parser.PersonalBasicInfoParser
  alias AdmiralStatsParser.Parser.TcBookInfoParser
  alias AdmiralStatsParser.Parser.CharacterListInfoParser
  alias AdmiralStatsParser.Parser.EventInfoParser
  alias AdmiralStatsParser.Summarizer.EventInfoSummarizer

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
  def get_latest_api_version(), do: 5

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

  @doc """
  基本情報をパースし、その結果を格納した構造体を返します。

  ## パラメータ

    - json: JSON 文字列
    - version: API version

  ## 返り値

    {:ok, PersonalBasicInfo.t} |
    {:error, error_msg}
  """
  def parse_personal_basic_info(json, version) do
    cond do
      version == 1 ->
        PersonalBasicInfoParser.parse(json, 1)
      Enum.member?(2..5, version) ->
        PersonalBasicInfoParser.parse(json, 2)
      true ->
        {:error, "unsupported API version"}
    end
  end

  @doc """
  艦娘図鑑をパースし、その結果を格納した構造体のリストを返します。

  ## パラメータ

    - json: JSON 文字列
    - version: API version

  ## 返り値

    {:ok, [TcBookInfo.t]} |
    {:error, error_msg}
  """
  def parse_tc_book_info(json, version) do
    cond do
      version == 1 ->
        TcBookInfoParser.parse(json, 1)
      Enum.member?(2..5, version) ->
        TcBookInfoParser.parse(json, 2)
      true ->
        {:error, "unsupported API version"}
    end
  end

  @doc """
  艦娘一覧をパースし、その結果を格納した構造体のリストを返します。

  ## パラメータ

    - json: JSON 文字列
    - version: API version

  ## 返り値

    {:ok, [CharacterListInfo.t]} |
    {:error, error_msg}
  """
  def parse_character_list_info(json, version) do
    cond do
      version == 1 ->
        {:error, "API version 1 does not support character list info"}
      version == 2 ->
        CharacterListInfoParser.parse(json, 1)
      Enum.member?(3..4, version) ->
        CharacterListInfoParser.parse(json, 2)
      version == 5 ->
        CharacterListInfoParser.parse(json, 3)
      true ->
        {:error, "unsupported API version"}
    end
  end

  @doc """
  イベント海域情報をパースし、その結果を格納した構造体を返します。

  ## パラメータ

    - json: JSON 文字列
    - version: API version

  ## 返り値

    {:ok, EventInfo.t} |
    {:error, error_msg}
  """
  def parse_event_info(json, version) do
    cond do
      Enum.member?(1..3, version) ->
        {:error, "API version #{version} does not support event info"}
      Enum.member?(4..5, version) ->
        EventInfoParser.parse(json, 1)
      true ->
        {:error, "unsupported API version"}
    end
  end

  @doc """
  イベント海域情報のリストを受け取り、そのサマリを格納したマップを返します。

  ## パラメータ

    - event_info_list: EventInfo のリスト
    - level: 難易度を表す文字列
    - version: API version

  ## 返り値

    {:ok, %{}} |
    {:error, error_msg}
  """
  def summarize_event_info(event_info_list, level, version) do
    cond do
      Enum.member?(1..3, version) ->
        {:error, "API version #{version} does not support event info"}
      Enum.member?(4..5, version) ->
        %{
            opened: EventInfoSummarizer.opened?(event_info_list, level),
            all_cleared: EventInfoSummarizer.all_cleared?(event_info_list, level),
            current_loop_counts: EventInfoSummarizer.current_loop_counts(event_info_list, level),
            cleared_loop_counts: EventInfoSummarizer.cleared_loop_counts(event_info_list, level),
            cleared_stage_no: EventInfoSummarizer.cleared_stage_no(event_info_list, level),
            current_military_gauge_left: EventInfoSummarizer.current_military_gauge_left(event_info_list, level)
        }
      true ->
        {:error, "unsupported API version"}
    end
  end
end
