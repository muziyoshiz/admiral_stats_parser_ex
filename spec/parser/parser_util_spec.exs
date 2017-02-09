# テストに使う構造体
# ParserUtilSpec の定義の後に書くと、CompileError が発生する
# > (CompileError) spec/parser/parser_util_spec.exs:143: AdmiralStats.Parser.ParserUtilSpec.TestStruct.__struct__/1 is
# > undefined, cannot expand struct AdmiralStats.Parser.ParserUtilSpec.TestStruct
defmodule AdmiralStats.Parser.ParserUtilSpec.TestStruct do
  defstruct man_int: nil,
    man_str: nil,
    opt_int: nil,
    opt_str: nil
end

defmodule AdmiralStats.Parser.ParserUtilSpec do
  use ESpec

  import AdmiralStatsParser.Parser.ParserUtil
  alias AdmiralStats.Parser.ParserUtilSpec.TestStruct

  describe "is_string(term)" do
    it "returns true" do
      expect is_string("") |> to(be_true())
      expect is_string("ABC") |> to(be_true())
      expect is_string("日本語") |> to(be_true())
    end

    it "returns false" do
      expect is_string(1) |> to(be_false())
      expect is_string('') |> to(be_false())
      expect is_string(true) |> to(be_false())
      expect is_string(false) |> to(be_false())
      expect is_string(nil) |> to(be_false())
    end
  end

  describe "is_integer_list(term)" do
    it "returns true" do
      expect is_integer_list([]) |> to(be_true())
      expect is_integer_list([0]) |> to(be_true())
      expect is_integer_list([1]) |> to(be_true())
      expect is_integer_list([-1]) |> to(be_true())
      expect is_integer_list([0, 1, -1]) |> to(be_true())

      # 空のリストとみなされるため true
      expect is_integer_list('') |> to(be_true())
    end

    it "returns false" do
      expect is_integer_list(1) |> to(be_false())
      expect is_integer_list("") |> to(be_false())
      expect is_integer_list(true) |> to(be_false())
      expect is_integer_list(false) |> to(be_false())
      expect is_integer_list(nil) |> to(be_false())
      expect is_integer_list(["1"]) |> to(be_false())
      expect is_integer_list(["1", 2, 3]) |> to(be_false())
    end
  end

  describe "is_string_list(term)" do
    it "returns true" do
      expect is_string_list([]) |> to(be_true())
      expect is_string_list([""]) |> to(be_true())
      expect is_string_list(["1"]) |> to(be_true())
      expect is_string_list(["ABC"]) |> to(be_true())
      expect is_string_list(["日本語"]) |> to(be_true())
      expect is_string_list(["1", "ABC", "日本語"]) |> to(be_true())

      # 空のリストとみなされるため true
      expect is_string_list('') |> to(be_true())
    end

    it "returns false" do
      expect is_string_list(1) |> to(be_false())
      expect is_string_list("") |> to(be_false())
      expect is_string_list(true) |> to(be_false())
      expect is_string_list(false) |> to(be_false())
      expect is_string_list(nil) |> to(be_false())
      expect is_string_list([1]) |> to(be_false())
      expect is_string_list(["ABC", 1, "日本語"]) |> to(be_false())
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

  describe "validate_keys(json_obj, mandatory_keys, optional_keys)" do
    let :mandatory_keys do
      %{
        "man_int" => &is_integer/1,
        "man_str" => &is_string/1,
      }
    end

    let :optional_keys do
      %{
        "opt_int" => &is_integer/1,
        "opt_str" => &is_string/1,
      }
    end

    context "json_obj contains valid mandatory keys and valid optional keys" do
      it "returns :ok" do
        json = """
          {"manInt":10,"manStr":"Test String","optInt":20,"optStr":"Option String","unknownKey":"Unknown String"}
          """
        json_obj = Poison.decode!(json)
        {res, json_obj2} = validate_keys(json_obj, mandatory_keys(), optional_keys())

        expect res |> to(eq(:ok))
        expect json_obj2 |> to(eq(json_obj))
      end
    end

    context "json_obj contains valid mandatory keys and no optional keys" do
      it "returns :ok" do
        json = """
          {"manInt":10,"manStr":"Test String","unknownKey":"Unknown String"}
          """
        json_obj = Poison.decode!(json)
        {res, json_obj2} = validate_keys(json_obj, mandatory_keys(), optional_keys())

        expect res |> to(eq(:ok))
        expect json_obj2 |> to(eq(json_obj))
      end
    end

    context "json_obj contains no mandatory keys" do
      it "returns :error" do
        json = """
          {"manStr": "Test String","optInt":20,"optStr":"Option String","unknownKey":"Unknown String"}
          """
        json_obj = Poison.decode!(json)
        {res, error_msg} = validate_keys(json_obj, mandatory_keys(), optional_keys())

        expect res |> to(eq(:error))
        expect error_msg |> to(eq("Mandatory key man_int does not exist"))

      end
    end

    context "json_obj contains valid mandatory keys and invalid mandatory keys" do
      it "returns :error" do
        json = """
          {"manInt":"10","manStr":"Test String","optInt":20,"optStr":"Option String","unknownKey":"Unknown String"}
          """
        json_obj = Poison.decode!(json)
        {res, error_msg} = validate_keys(json_obj, mandatory_keys(), optional_keys())

        expect res |> to(eq(:error))
        expect error_msg |> to(eq("Mandatory key man_int is invalid"))
      end
    end

    context "json_obj contains valid mandatory keys and invalid optional keys" do
      it "returns :error" do
        json = """
          {"manInt":10,"manStr":"Test String","optInt":20,"optStr":10,"unknownKey":"Unknown String"}
          """
        json_obj = Poison.decode!(json)
        {res, error_msg} = validate_keys(json_obj, mandatory_keys(), optional_keys())

        expect res |> to(eq(:error))
        expect error_msg |> to(eq("Optional key opt_str is invalid"))
      end
    end
  end

  describe("create_struct(validation_res, obj, mandatory_keys, optional_keys)") do
    let :mandatory_keys do
      %{
        "man_int" => &is_integer/1,
        "man_str" => &is_string/1,
      }
    end

    let :optional_keys do
      %{
        "opt_int" => &is_integer/1,
        "opt_str" => &is_string/1,
      }
    end

    let :less_mandatory_keys do
      %{
        "man_int" => &is_integer/1,
      }
    end

    let :less_optional_keys do
      %{
        "opt_str" => &is_string/1,
      }
    end

    context "validation_res is {:ok, json_obj}" do
      it "returns {:ok, obj}" do
        json = """
          {"manInt":10,"manStr":"Test String","optInt":20,"optStr":"Option String","unknownKey":"Unknown String"}
          """
        json_obj = Poison.decode!(json)
        {res, obj} = validate_keys(json_obj, mandatory_keys(), optional_keys()) |>
          create_struct(%TestStruct{}, mandatory_keys(), optional_keys())

        expect res |> to(eq(:ok))
        expect obj.man_int |> to(eq(10))
        expect obj.man_str |> to(eq("Test String"))
        expect obj.opt_int |> to(eq(20))
        expect obj.opt_str |> to(eq("Option String"))
      end

      it "returns {:ok, obj}" do
        json = """
          {"manInt":10,"manStr":"Test String","optInt":20,"optStr":"Option String","unknownKey":"Unknown String"}
          """
        json_obj = Poison.decode!(json)
        {res, obj} = validate_keys(json_obj, less_mandatory_keys(), less_optional_keys()) |>
          create_struct(%TestStruct{}, less_mandatory_keys(), less_optional_keys())

        expect res |> to(eq(:ok))
        expect obj.man_int |> to(eq(10))
        expect obj.man_str |> to(be_nil())
        expect obj.opt_int |> to(be_nil())
        expect obj.opt_str |> to(eq("Option String"))
      end
    end

    context "validation_res is {:error, error_msg}" do
      it "returns {:error, error_msg}" do
        validation_res = {:error, "Error Message"}
        {res, error_msg} = create_struct(validation_res, %TestStruct{}, mandatory_keys(), optional_keys())

        expect res |> to(eq(:error))
        expect error_msg |> to(eq("Error Message"))
      end
    end
  end
end
