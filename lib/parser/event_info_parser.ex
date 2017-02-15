defmodule AdmiralStatsParser.Parser.EventInfoParser do
  @moduledoc """
  イベント進捗情報をパースするためのモジュールです。
  """

  alias AdmiralStatsParser.Parser.ParserUtil
  alias AdmiralStatsParser.Model.EventInfo

  # API version ごとの必須キーを格納したマップ
  @mandatory_keys %{
    1 => %{
      "area_id" => &is_integer/1,
      "area_sub_id" => &is_integer/1,
      "level" => &ParserUtil.is_string/1,
      "area_kind" => &ParserUtil.is_string/1,
      "limit_sec" => &is_integer/1,
      "require_gp" => &is_integer/1,
      "sortie_limit" => &is_boolean/1,
      "stage_image_name" => &ParserUtil.is_string/1,
      "stage_mission_name" => &ParserUtil.is_string/1,
      "stage_mission_info" => &ParserUtil.is_string/1,
      "reward_list" => &__MODULE__.is_event_info_reward_list/1,
      "stage_drop_item_info" => &ParserUtil.is_string_list/1,
      "area_clear_state" => &ParserUtil.is_string/1,
      "military_gauge_status" => &ParserUtil.is_string/1,
      "ene_military_gauge_val" => &is_integer/1,
      "military_gauge_left" => &is_integer/1,
      "boss_status" => &ParserUtil.is_string/1,
      "loop_count" => &is_integer/1,
    }
  }

  # API version ごとの任意キーを格納したマップ
  @optional_keys %{
    1 => %{},
  }

  @doc """
  与えられた JSON 文字列をデコードし、構造体に格納して返します。

  ## パラメータ

    - json: JSON 文字列
    - version: API version

  ## 返り値

    {:ok, [EventInfo.t]} |
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

  @doc """
  与えられた引数が、Reward に変換可能なマップの場合に true を返します。
  このメソッドを private にすると、@mandatory_key 内で参照できないため、public で定義します。

  ## パラメータ

    - term: 検査対象

  ## 返り値

    boolean
  """
  def is_event_info_reward(term) do
    # 引数がマップで、かつ Reward に必須のキーを持つかどうかを確認
    # "rewardType" は任意のキーなので、検査しない
    is_map(term) and Map.has_key?(term, "dataId") and
      Map.has_key?(term, "kind") and Map.has_key?(term, "value")
  end

  @doc """
  与えられた引数が、Reward に変換可能なマップのリストの場合に true を返します。
  このメソッドを private にすると、@mandatory_key 内で参照できないため、public で定義します。

  ## パラメータ

    - term: 検査対象

  ## 返り値

    boolean
  """
  def is_event_info_reward_list(term) do
    ParserUtil.is_list_of(term, &__MODULE__.is_event_info_reward/1)
  end

  # json_objects からすべてのオブジェクトを取り出し終えたら、成功のレスポンスを返す
  defp create_structs(objects, [], _, _), do: {:ok, objects}

  # json_objects の1個目のオブジェクトを取り出し、構造体に変換
  defp create_structs(objects, json_objects, mandatory_keys, optional_keys) do
    [json_obj | rest_json_objects] = json_objects
    {res, obj} =
      json_obj
      |> ParserUtil.validate_keys(mandatory_keys, optional_keys)
      |> ParserUtil.create_struct(%EventInfo{}, mandatory_keys, optional_keys)
      |> create_reward_list()
    case res do
      :ok ->
        objects = objects ++ [obj]
        create_structs(objects, rest_json_objects, mandatory_keys, optional_keys)
      :error ->
        {:error, obj}
    end
  end

  # 引数のオブジェクトに含まれる reward_list を [EventInfo.Reward] に変換する
  defp create_reward_list(creation_res) do
    case creation_res do
      {:ok, obj} ->
        {:ok, Map.put(obj, :reward_list, create_rewards([], obj.reward_list))}
      _ ->
        creation_res
    end
  end

  # reward_list からすべてのマップを取り出し終えたら、結果を返す
  defp create_rewards(rewards, []) do
    rewards
  end

  # reward_list から1個ずつマップを取り出して、EventInfo.Reward 構造体に変換する
  defp create_rewards(rewards, reward_list) do
    [reward | rest_reward_list] = reward_list
    obj = %EventInfo.Reward{
      reward_type: reward["rewardType"],
      data_id: reward["dataId"],
      kind: reward["kind"],
      value: reward["value"],
    }
    rewards = rewards ++ [obj]
    create_rewards(rewards, rest_reward_list)
  end
end
