defmodule AdmiralStats.Parser.ParserUtilSpec do
  use ESpec
  import AdmiralStatsParser.Parser.ParserUtil

  describe "is_string(term)" do
    it "returns true" do
      expect is_string("") |> to(be_true())
      expect is_string("ABC") |> to(be_true())
      expect is_string("日本語") |> to(be_true())
    end

    it "returns false" do
      expect is_string(1) |> to(be_false())
      expect is_string('') |> to(be_false())
      expect is_string(true)  |> to(be_false())
      expect is_string(false)  |> to(be_false())
      expect is_string(nil)  |> to(be_false())
    end
  end

  describe "to_camel_case(snake_case)" do
    it "returns original string" do
      expect to_camel_case("") |> to(eq(""))
      expect to_camel_case("name") |> to(eq("name"))
      expect to_camel_case("admiralName") |> to(eq("admiralName"))
    end

    it "returns camel-cased string" do
      expect to_camel_case("admiral_name") |> to(eq("admiralName"))
      expect to_camel_case("room_item_coin") |> to(eq("roomItemCoin"))
    end
  end
end
