defmodule AdmiralStatsParserSpec do
  use ESpec

  describe "get_latest_api_version()" do
    it "returns 5" do
      expect(AdmiralStatsParser.get_latest_api_version).to eq(5)
    end
  end

  describe "guess_api_version(exported_at)" do
    # 2016-04-26 〜 2016-06-29
    it "returns 1" do
      expect(AdmiralStatsParser.guess_api_version(Timex.parse!("2016-04-26T00:00:00+09:00", "{ISO:Extended}"))).to eq(1)
      expect(AdmiralStatsParser.guess_api_version(Timex.parse!("2016-06-30T06:59:59+09:00", "{ISO:Extended}"))).to eq(1)
    end

    # 2016-06-30（REVISION 2 のリリース日）〜 2016-09-14
    it "returns 2" do
      expect(AdmiralStatsParser.guess_api_version(Timex.parse!("2016-06-30T07:00:00+09:00", "{ISO:Extended}"))).to eq(2)
      expect(AdmiralStatsParser.guess_api_version(Timex.parse!("2016-09-15T06:59:59+09:00", "{ISO:Extended}"))).to eq(2)
    end

    # 2016-09-15 〜 2016-10-26
    it "returns 3" do
      expect(AdmiralStatsParser.guess_api_version(Timex.parse!("2016-09-15T07:00:00+09:00", "{ISO:Extended}"))).to eq(3)
      expect(AdmiralStatsParser.guess_api_version(Timex.parse!("2016-10-27T06:59:59+09:00", "{ISO:Extended}"))).to eq(3)
    end

    # 2016-10-27 〜 2016-12-20
    it "returns 4" do
      expect(AdmiralStatsParser.guess_api_version(Timex.parse!("2016-10-27T07:00:00+09:00", "{ISO:Extended}"))).to eq(4)
      expect(AdmiralStatsParser.guess_api_version(Timex.parse!("2016-12-21T06:59:59+09:00", "{ISO:Extended}"))).to eq(4)
    end

    # 2016-12-21 〜
    it "returns 5" do
      expect(AdmiralStatsParser.guess_api_version(Timex.parse!("2016-12-21T07:00:00+09:00", "{ISO:Extended}"))).to eq(5)
    end

    it "returns latest version" do
      # 遠い未来の場合は、最新バージョンを返す
      expect(AdmiralStatsParser.guess_api_version(Timex.parse!("2200-01-01T00:00:00+09:00", "{ISO:Extended}"))).to eq(AdmiralStatsParser.get_latest_api_version)
    end
  end
end
