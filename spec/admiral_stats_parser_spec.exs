defmodule AdmiralStatsParserSpec do
  use ESpec

  describe "get_latest_api_version()" do
    it "returns 5" do
      expect AdmiralStatsParser.get_latest_api_version
      |> to(eq(5))
    end
  end

  describe "guess_api_version(exported_at)" do
    # 2016-04-26 〜 2016-06-29
    it "returns 1" do
      expect AdmiralStatsParser.guess_api_version(Timex.parse!("2016-04-26T00:00:00+09:00", "{ISO:Extended}"))
      |> to(eq(1))
      expect AdmiralStatsParser.guess_api_version(Timex.parse!("2016-06-30T06:59:59+09:00", "{ISO:Extended}"))
      |> to(eq(1))
    end

    # 2016-06-30（REVISION 2 のリリース日）〜 2016-09-14
    it "returns 2" do
      expect AdmiralStatsParser.guess_api_version(Timex.parse!("2016-06-30T07:00:00+09:00", "{ISO:Extended}"))
      |> to(eq(2))
      expect AdmiralStatsParser.guess_api_version(Timex.parse!("2016-09-15T06:59:59+09:00", "{ISO:Extended}"))
      |> to(eq(2))
    end

    # 2016-09-15 〜 2016-10-26
    it "returns 3" do
      expect AdmiralStatsParser.guess_api_version(Timex.parse!("2016-09-15T07:00:00+09:00", "{ISO:Extended}"))
      |> to(eq(3))
      expect AdmiralStatsParser.guess_api_version(Timex.parse!("2016-10-27T06:59:59+09:00", "{ISO:Extended}"))
      |> to(eq(3))
    end

    # 2016-10-27 〜 2016-12-20
    it "returns 4" do
      expect AdmiralStatsParser.guess_api_version(Timex.parse!("2016-10-27T07:00:00+09:00", "{ISO:Extended}"))
      |> to(eq(4))
      expect AdmiralStatsParser.guess_api_version(Timex.parse!("2016-12-21T06:59:59+09:00", "{ISO:Extended}"))
      |> to(eq(4))
    end

    # 2016-12-21 〜
    it "returns 5" do
      expect AdmiralStatsParser.guess_api_version(Timex.parse!("2016-12-21T07:00:00+09:00", "{ISO:Extended}"))
      |> to(eq(5))
    end

    it "returns latest version" do
      # 遠い未来の場合は、最新バージョンを返す
      expect AdmiralStatsParser.guess_api_version(Timex.parse!("2200-01-01T00:00:00+09:00", "{ISO:Extended}"))
      |> to(eq(AdmiralStatsParser.get_latest_api_version))
    end
  end

  describe "parse_personal_basic_info(json, 1)" do
    it "returns PersonalBasicInfo" do
      json = """
        {"admiralName":"ABCDEFGH","fuel":838,"ammo":974,"steel":482,"bauxite":129,"bucket":7,"level":5,"roomItemCoin":0}
        """
      {res, result} = AdmiralStatsParser.parse_personal_basic_info(json, 1)

      expect result.admiral_name |> to(eq("ABCDEFGH"))
      expect result.fuel |> to(eq(838))
      expect result.ammo |> to(eq(974))
      expect result.steel |> to(eq(482))
      expect result.bauxite |> to(eq(129))
      expect result.bucket |> to(eq(7))
      expect result.level |> to(eq(5))
      expect result.room_item_coin |> to(eq(0))
      expect result.result_point |> to(be_nil())
      expect result.rank |> to(be_nil())
      expect result.title_id |> to(be_nil())
      expect result.material_max |> to(be_nil())
      expect result.strategy_point |> to(be_nil())
    end
  end

  describe "parse_personal_basic_info(json_without_admiral_name, 1)" do
    it "returns PersonalBasicInfo" do
      json = """
        {"fuel":838,"ammo":974,"steel":482,"bauxite":129,"bucket":7,"level":5,"roomItemCoin":0}
        """
      {res, result} = AdmiralStatsParser.parse_personal_basic_info(json, 1)

      expect result.admiral_name |> to(be_nil())
      expect result.fuel |> to(eq(838))
      expect result.ammo |> to(eq(974))
      expect result.steel |> to(eq(482))
      expect result.bauxite |> to(eq(129))
      expect result.bucket |> to(eq(7))
      expect result.level |> to(eq(5))
      expect result.room_item_coin |> to(eq(0))
      expect result.result_point |> to(be_nil())
      expect result.rank |> to(be_nil())
      expect result.title_id |> to(be_nil())
      expect result.material_max |> to(be_nil())
      expect result.strategy_point |> to(be_nil())
    end
  end

  # admiralName を含まない場合のテスト
  describe "parse_personal_basic_info(json_without_admiral_name, 2..5)" do
    it "returns PersonalBasicInfo" do
      for version <- 2..5 do
        json = """
          {"fuel":6750,"ammo":6183,"steel":7126,"bauxite":6513,"bucket":46,"level":32,"roomItemCoin":82,"resultPoint":"3571","rank":"圏外","titleId":7,"materialMax":7200,"strategyPoint":915}
          """
        {res, result} = AdmiralStatsParser.parse_personal_basic_info(json, version)

        expect result.admiral_name |> to(be_nil())
        expect result.fuel |> to(eq(6750))
        expect result.ammo |> to(eq(6183))
        expect result.steel |> to(eq(7126))
        expect result.bauxite |> to(eq(6513))
        expect result.bucket |> to(eq(46))
        expect result.level |> to(eq(32))
        expect result.room_item_coin |> to(eq(82))
        expect result.result_point |> to(eq("3571"))
        expect result.rank |> to(eq("圏外"))
        expect result.title_id |> to(eq(7))
        expect result.material_max |> to(eq(7200))
        expect result.strategy_point |> to(eq(915))
      end
    end
  end

  # admiralNameを含む場合のテスト
  describe "parse_personal_basic_info(json, 2..5)" do
    it "returns PersonalBasicInfo" do
      for version <- 2..5 do
        json = """
          {"admiralName":"ABCDEFGH","fuel":6750,"ammo":6183,"steel":7126,"bauxite":6513,"bucket":46,"level":32,"roomItemCoin":82,"resultPoint":"3571","rank":"圏外","titleId":7,"materialMax":7200,"strategyPoint":915}
          """
        {res, result} = AdmiralStatsParser.parse_personal_basic_info(json, version)

        expect result.admiral_name |> to(eq("ABCDEFGH"))
        expect result.fuel |> to(eq(6750))
        expect result.ammo |> to(eq(6183))
        expect result.steel |> to(eq(7126))
        expect result.bauxite |> to(eq(6513))
        expect result.bucket |> to(eq(46))
        expect result.level |> to(eq(32))
        expect result.room_item_coin |> to(eq(82))
        expect result.result_point |> to(eq("3571"))
        expect result.rank |> to(eq("圏外"))
        expect result.title_id |> to(eq(7))
        expect result.material_max |> to(eq(7200))
        expect result.strategy_point |> to(eq(915))
      end
    end
  end
end
