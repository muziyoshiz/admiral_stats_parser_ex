defmodule AdmiralStatsParser.Parser.PersonalBasicInfoParser do
  @moduledoc """
  基本情報をパースするためのモジュールです。
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
    - version: API version

  ## 返り値

    {:ok, PersonalBasicInfo.t} |
    {:error, error_msg}
  """
  def parse(json, version) do
    case Poison.decode(json) do
      {:ok, json_obj} ->
        json_obj
        |> ParserUtil.validate_keys(@mandatory_keys[version], @optional_keys[version])
        |> ParserUtil.create_struct(%PersonalBasicInfo{}, @mandatory_keys[version], @optional_keys[version])
      {:error, {:invalid, msg}} ->
        {:error, "Failed to decode json: " <> msg}
      {:error, _} ->
        {:error, "Failed to decode json"}
    end
  end
end
