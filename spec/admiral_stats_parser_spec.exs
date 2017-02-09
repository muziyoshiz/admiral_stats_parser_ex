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

      expect res |> to(eq(:ok))
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

      expect res |> to(eq(:ok))
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

        expect res |> to(eq(:ok))
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

        expect res |> to(eq(:ok))
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

  describe "parse_tc_book_info(json, 1)" do
    it "returns TcBookInfo[]" do
      json = """
        [{"bookNo":1,"shipClass":"","shipClassIndex":-1,"shipType":"","shipName":"未取得","cardIndexImg":"","cardImgList":[],"variationNum":0,"acquireNum":0},{"bookNo":2,"shipClass":"長門型","shipClassIndex":2,"shipType":"戦艦","shipName":"陸奥","cardIndexImg":"s/tc_2_tjpm66z1epc6.jpg","cardImgList":["s/tc_2_tjpm66z1epc6.jpg","","","","",""],"variationNum":6,"acquireNum":1}]
        """

      {res, results} = AdmiralStatsParser.parse_tc_book_info(json, 1)

      expect res |> to(eq(:ok))
      expect Enum.count(results) |> to(eq(2))

      result = Enum.at(results, 0)
      expect result.book_no |> to(eq(1))
      expect result.ship_class |> to(eq(""))
      expect result.ship_class_index |> to(eq(-1))
      expect result.ship_type |> to(eq(""))
      expect result.ship_name |> to(eq("未取得"))
      expect result.card_index_img |> to(eq(""))
      expect result.card_img_list |> to(eq([]))
      expect result.variation_num |> to(eq(0))
      expect result.acquire_num |> to(eq(0))
      expect result.lv |> to(be_nil())
      expect result.status_img |> to(be_nil())

      result = Enum.at(results, 1)
      expect result.book_no |> to(eq(2))
      expect result.ship_class |> to(eq("長門型"))
      expect result.ship_class_index |> to(eq(2))
      expect result.ship_type |> to(eq("戦艦"))
      expect result.ship_name |> to(eq("陸奥"))
      expect result.card_index_img |> to(eq("s/tc_2_tjpm66z1epc6.jpg"))
      expect result.card_img_list |> to(eq(["s/tc_2_tjpm66z1epc6.jpg","","","","",""]))
      expect result.variation_num |> to(eq(6))
      expect result.acquire_num |> to(eq(1))
      expect result.lv |> to(be_nil())
      expect result.status_img |> to(be_nil())
    end
  end

  # 艦娘図鑑は version 2 〜 5 で仕様が同じ
  describe "parse_tc_book_info(json, 2..5)" do
    it "returns TcBookInfo[]" do
      for version <- 2..5 do
        json = """
          [{"bookNo":1,"shipClass":"長門型","shipClassIndex":1,"shipType":"戦艦","shipName":"長門","cardIndexImg":"s/tc_1_d7ju63kolamj.jpg","cardImgList":["","","s/tc_1_gk42czm42s3p.jpg","","",""],"variationNum":6,"acquireNum":1,"lv":23,"statusImg":["i/i_d7ju63kolamj_n.png"]},{"bookNo":5,"shipClass":"","shipClassIndex":-1,"shipType":"","shipName":"未取得","cardIndexImg":"","cardImgList":[],"variationNum":0,"acquireNum":0,"lv":0,"statusImg":[]}]
          """

        {res, results} = AdmiralStatsParser.parse_tc_book_info(json, version)

        expect res |> to(eq(:ok))
        expect Enum.count(results) |> to(eq(2))

        result = Enum.at(results, 0)
        expect result.book_no |> to(eq(1))
        expect result.ship_class |> to(eq("長門型"))
        expect result.ship_class_index |> to(eq(1))
        expect result.ship_type |> to(eq("戦艦"))
        expect result.ship_name |> to(eq("長門"))
        expect result.card_index_img |> to(eq("s/tc_1_d7ju63kolamj.jpg"))
        expect result.card_img_list |> to(eq(["","","s/tc_1_gk42czm42s3p.jpg","","",""]))
        expect result.variation_num |> to(eq(6))
        expect result.acquire_num |> to(eq(1))
        expect result.lv |> to(eq(23))
        expect result.status_img |> to(eq(["i/i_d7ju63kolamj_n.png"]))

        result = Enum.at(results, 1)
        expect result.book_no |> to(eq(5))
        expect result.ship_class |> to(eq(""))
        expect result.ship_class_index |> to(eq(-1))
        expect result.ship_type |> to(eq(""))
        expect result.ship_name |> to(eq("未取得"))
        expect result.card_index_img |> to(eq(""))
        expect result.card_img_list |> to(eq([]))
        expect result.variation_num |> to(eq(0))
        expect result.acquire_num |> to(eq(0))
        expect result.lv |> to(eq(0))
        expect result.status_img |> to(eq([]))
      end
    end
  end

  # API version 1 には艦娘一覧が存在しなかった
  describe "parse_character_list_info(json, 1)" do
    it "returns {:error, error_msg}" do
      json = """
        [
          {"bookNo":11,"lv":20,"shipType":"駆逐艦","shipSortNo":1800,"remodelLv":0,"shipName":"吹雪","statusImg":"i/i_u6jw00e3ey3p_n.png"},{"bookNo":85,"lv":36,"shipType":"駆逐艦","shipSortNo":1800,"remodelLv":0,"shipName":"朝潮","statusImg":"i/i_69ex6r4uutp3_n.png"},
          {"bookNo":85,"lv":36,"shipType":"駆逐艦","shipSortNo":1800,"remodelLv":1,"shipName":"朝潮改","statusImg":"i/i_umacfn9qcwp1_n.png"}
        ]
        """

      {res, error_msg} = AdmiralStatsParser.parse_character_list_info(json, 1)
      expect res |> to(eq(:error))
      expect error_msg |> to(eq("API version 1 does not support character list info"))
    end
  end

  describe "parse_character_list_info(json, 2)" do
    it "returns CharacterListInfo[]" do
      json = """
        [
          {"bookNo":11,"lv":20,"shipType":"駆逐艦","shipSortNo":1800,"remodelLv":0,"shipName":"吹雪","statusImg":"i/i_u6jw00e3ey3p_n.png"},
          {"bookNo":85,"lv":36,"shipType":"駆逐艦","shipSortNo":1800,"remodelLv":0,"shipName":"朝潮","statusImg":"i/i_69ex6r4uutp3_n.png"},
          {"bookNo":85,"lv":36,"shipType":"駆逐艦","shipSortNo":1800,"remodelLv":1,"shipName":"朝潮改","statusImg":"i/i_umacfn9qcwp1_n.png"}
        ]
        """

      {res, results} = AdmiralStatsParser.parse_character_list_info(json, 2)

      expect res |> to(eq(:ok))
      expect Enum.count(results) |> to(eq(3))

      result = Enum.at(results, 0)
      expect result.book_no |> to(eq(11))
      expect result.lv |> to(eq(20))
      expect result.ship_type |> to(eq("駆逐艦"))
      expect result.ship_sort_no |> to(eq(1800))
      expect result.remodel_lv |> to(eq(0))
      expect result.ship_name |> to(eq("吹雪"))
      expect result.status_img |> to(eq("i/i_u6jw00e3ey3p_n.png"))

      result = Enum.at(results, 1)
      expect result.book_no |> to(eq(85))
      expect result.lv |> to(eq(36))
      expect result.ship_type |> to(eq("駆逐艦"))
      expect result.ship_sort_no |> to(eq(1800))
      expect result.remodel_lv |> to(eq(0))
      expect result.ship_name |> to(eq("朝潮"))
      expect result.status_img |> to(eq("i/i_69ex6r4uutp3_n.png"))

      result = Enum.at(results, 2)
      expect result.book_no |> to(eq(85))
      expect result.lv |> to(eq(36))
      expect result.ship_type |> to(eq("駆逐艦"))
      expect result.ship_sort_no |> to(eq(1800))
      expect result.remodel_lv |> to(eq(1))
      expect result.ship_name |> to(eq("朝潮改"))
      expect result.status_img |> to(eq("i/i_umacfn9qcwp1_n.png"))
    end
  end

  # 艦娘一覧は version 3 〜 4 で仕様が同じ
  describe "parse_character_list_info(json, 3..4)" do
    it "returns CharacterListInfo[]" do
      for version <- 3..4 do
        json = """
          [
            {"bookNo":11,"lv":20,"shipType":"駆逐艦","shipSortNo":1800,"remodelLv":0,"shipName":"吹雪","statusImg":"i/i_u6jw00e3ey3p_n.png","starNum":1},
            {"bookNo":85,"lv":36,"shipType":"駆逐艦","shipSortNo":1800,"remodelLv":0,"shipName":"朝潮","statusImg":"i/i_69ex6r4uutp3_n.png","starNum":5},
            {"bookNo":85,"lv":36,"shipType":"駆逐艦","shipSortNo":1800,"remodelLv":1,"shipName":"朝潮改","statusImg":"i/i_umacfn9qcwp1_n.png","starNum":3}
          ]
          """

        {res, results} = AdmiralStatsParser.parse_character_list_info(json, version)

        expect res |> to(eq(:ok))
        expect Enum.count(results) |> to(eq(3))

        result = Enum.at(results, 0)
        expect result.book_no |> to(eq(11))
        expect result.lv |> to(eq(20))
        expect result.ship_type |> to(eq("駆逐艦"))
        expect result.ship_sort_no |> to(eq(1800))
        expect result.remodel_lv |> to(eq(0))
        expect result.ship_name |> to(eq("吹雪"))
        expect result.status_img |> to(eq("i/i_u6jw00e3ey3p_n.png"))
        expect result.star_num |> to(eq(1))

        result = Enum.at(results, 1)
        expect result.book_no |> to(eq(85))
        expect result.lv |> to(eq(36))
        expect result.ship_type |> to(eq("駆逐艦"))
        expect result.ship_sort_no |> to(eq(1800))
        expect result.remodel_lv |> to(eq(0))
        expect result.ship_name |> to(eq("朝潮"))
        expect result.status_img |> to(eq("i/i_69ex6r4uutp3_n.png"))
        expect result.star_num |> to(eq(5))

        result = Enum.at(results, 2)
        expect result.book_no |> to(eq(85))
        expect result.lv |> to(eq(36))
        expect result.ship_type |> to(eq("駆逐艦"))
        expect result.ship_sort_no |> to(eq(1800))
        expect result.remodel_lv |> to(eq(1))
        expect result.ship_name |> to(eq("朝潮改"))
        expect result.status_img |> to(eq("i/i_umacfn9qcwp1_n.png"))
        expect result.star_num |> to(eq(3))
      end
    end
  end

  # 艦娘一覧は、version 5 で各艦娘が装備中のアイテムが追加された
  describe "parse_character_list_info(json, 5)" do
    it "returns CharacterListInfo[]" do
      # 朝潮、朝潮改、鈴谷、鈴谷改のデータ
      json = """
         [
           {"bookNo":85,"lv":97,"shipType":"駆逐艦","shipSortNo":1800,"remodelLv":0,"shipName":"朝潮","statusImg":"i/i_69ex6r4uutp3_n.png","starNum":5,"shipClass":"朝潮型","shipClassIndex":1,"tcImg":"s/tc_85_69ex6r4uutp3.jpg","expPercent":97,"maxHp":16,"realHp":16,"damageStatus":"NORMAL","slotNum":2,"slotEquipName":["","","",""],"slotAmount":[0,0,0,0],"slotDisp":["NONE","NONE","NONE","NONE"],"slotImg":["","","",""]},
           {"bookNo":85,"lv":97,"shipType":"駆逐艦","shipSortNo":1800,"remodelLv":1,"shipName":"朝潮改","statusImg":"i/i_umacfn9qcwp1_n.png","starNum":5,"shipClass":"朝潮型","shipClassIndex":1,"tcImg":"s/tc_85_umacfn9qcwp1.jpg","expPercent":97,"maxHp":31,"realHp":31,"damageStatus":"NORMAL","slotNum":3,"slotEquipName":["10cm高角砲＋高射装置","10cm高角砲＋高射装置","61cm四連装(酸素)魚雷",""],"slotAmount":[0,0,0,0],"slotDisp":["NONE","NONE","NONE","NONE"],"slotImg":["equip_icon_26_rv74l134q7an.png","equip_icon_26_rv74l134q7an.png","equip_icon_5_c4bcdscek33o.png",""]},
           {"bookNo":124,"lv":70,"shipType":"重巡洋艦","shipSortNo":1500,"remodelLv":0,"shipName":"鈴谷","statusImg":"i/i_zrr1yq3annrq_n.png","starNum":5,"shipClass":"最上型","shipClassIndex":3,"tcImg":"s/tc_124_2uejd60gndj3.jpg","expPercent":4,"maxHp":40,"realHp":40,"damageStatus":"NORMAL","slotNum":3,"slotEquipName":["","","",""],"slotAmount":[2,2,2,0],"slotDisp":["NOT_EQUIPPED_AIRCRAFT","NOT_EQUIPPED_AIRCRAFT","NOT_EQUIPPED_AIRCRAFT","NONE"],"slotImg":["","","",""]},
           {"bookNo":129,"lv":70,"shipType":"航空巡洋艦","shipSortNo":1400,"remodelLv":1,"shipName":"鈴谷改","statusImg":"i/i_6cc94esr14nz_n.png","starNum":5,"shipClass":"最上型","shipClassIndex":3,"tcImg":"s/tc_129_7k4atc4mguna.jpg","expPercent":4,"maxHp":50,"realHp":50,"damageStatus":"NORMAL","slotNum":4,"slotEquipName":["20.3cm(3号)連装砲","瑞雲","15.5cm三連装副砲","三式弾"],"slotAmount":[5,6,5,6],"slotDisp":["NOT_EQUIPPED_AIRCRAFT","EQUIPPED_AIRCRAFT","NOT_EQUIPPED_AIRCRAFT","NOT_EQUIPPED_AIRCRAFT"],"slotImg":["equip_icon_2_n8b0sex6xclf.png","equip_icon_10_lpoysb3zk6s4.png","equip_icon_4_mgy58yrghven.png","equip_icon_13_jdkmrexetpvn.png"]}
         ]
         """

      {res, results} = AdmiralStatsParser.parse_character_list_info(json, 5)

      expect res |> to(eq(:ok))
      expect Enum.count(results) |> to(eq(4))

      result = Enum.at(results, 0)
      expect result.book_no |> to(eq(85))
      expect result.lv |> to(eq(97))
      expect result.ship_type |> to(eq("駆逐艦"))
      expect result.ship_sort_no |> to(eq(1800))
      expect result.remodel_lv |> to(eq(0))
      expect result.ship_name |> to(eq("朝潮"))
      expect result.status_img |> to(eq("i/i_69ex6r4uutp3_n.png"))
      expect result.star_num |> to(eq(5))
      expect result.ship_class |> to(eq("朝潮型"))
      expect result.ship_class_index |> to(eq(1))
      expect result.tc_img |> to(eq("s/tc_85_69ex6r4uutp3.jpg"))
      expect result.exp_percent |> to(eq(97))
      expect result.max_hp |> to(eq(16))
      expect result.real_hp |> to(eq(16))
      expect result.damage_status |> to(eq("NORMAL"))
      expect result.slot_num |> to(eq(2))
      expect result.slot_equip_name |> to(eq(["", "", "", ""]))
      expect result.slot_amount |> to(eq([0, 0, 0, 0]))
      expect result.slot_disp |> to(eq(~w(NONE NONE NONE NONE)))
      expect result.slot_img |> to(eq(["", "", "", ""]))

      result = Enum.at(results, 1)
      expect result.book_no |> to(eq(85))
      expect result.lv |> to(eq(97))
      expect result.ship_type |> to(eq("駆逐艦"))
      expect result.ship_sort_no |> to(eq(1800))
      expect result.remodel_lv |> to(eq(1))
      expect result.ship_name |> to(eq("朝潮改"))
      expect result.status_img |> to(eq("i/i_umacfn9qcwp1_n.png"))
      expect result.star_num |> to(eq(5))
      expect result.ship_class |> to(eq("朝潮型"))
      expect result.ship_class_index |> to(eq(1))
      expect result.tc_img |> to(eq("s/tc_85_umacfn9qcwp1.jpg"))
      expect result.exp_percent |> to(eq(97))
      expect result.max_hp |> to(eq(31))
      expect result.real_hp |> to(eq(31))
      expect result.damage_status |> to(eq("NORMAL"))
      expect result.slot_num |> to(eq(3))
      expect result.slot_equip_name |> to(eq(["10cm高角砲＋高射装置", "10cm高角砲＋高射装置", "61cm四連装(酸素)魚雷", ""]))
      expect result.slot_amount |> to(eq([0, 0, 0, 0]))
      expect result.slot_disp |> to(eq(~w(NONE NONE NONE NONE)))
      expect result.slot_img |> to(eq(["equip_icon_26_rv74l134q7an.png", "equip_icon_26_rv74l134q7an.png", "equip_icon_5_c4bcdscek33o.png", ""]))

      result = Enum.at(results, 2)
      expect result.book_no |> to(eq(124))
      expect result.lv |> to(eq(70))
      expect result.ship_type |> to(eq("重巡洋艦"))
      expect result.ship_sort_no |> to(eq(1500))
      expect result.remodel_lv |> to(eq(0))
      expect result.ship_name |> to(eq("鈴谷"))
      expect result.status_img |> to(eq("i/i_zrr1yq3annrq_n.png"))
      expect result.star_num |> to(eq(5))
      expect result.ship_class |> to(eq("最上型"))
      expect result.ship_class_index |> to(eq(3))
      expect result.tc_img |> to(eq("s/tc_124_2uejd60gndj3.jpg"))
      expect result.exp_percent |> to(eq(4))
      expect result.max_hp |> to(eq(40))
      expect result.real_hp |> to(eq(40))
      expect result.damage_status |> to(eq("NORMAL"))
      expect result.slot_num |> to(eq(3))
      expect result.slot_equip_name |> to(eq(["", "", "", ""]))
      expect result.slot_amount |> to(eq([2, 2, 2, 0]))
      expect result.slot_disp |> to(eq(~w(NOT_EQUIPPED_AIRCRAFT NOT_EQUIPPED_AIRCRAFT NOT_EQUIPPED_AIRCRAFT NONE)))
      expect result.slot_img |> to(eq(["", "", "", ""]))

      # {"bookNo":129,"lv":70,"shipType":"航空巡洋艦","shipSortNo":1400,"remodelLv":1,"shipName":"鈴谷改",
      # "statusImg":"i/i_6cc94esr14nz_n.png","starNum":5,"shipClass":"最上型","shipClassIndex":3,
      # "tcImg":"s/tc_129_7k4atc4mguna.jpg","expPercent":4,"maxHp":50,"realHp":50,"damageStatus":"NORMAL",
      # "slotNum":4,"slotEquipName":["20.3cm(3号)連装砲","瑞雲","15.5cm三連装副砲","三式弾"],"slotAmount":[5,6,5,6],
      # "slotDisp":["NOT_EQUIPPED_AIRCRAFT","EQUIPPED_AIRCRAFT","NOT_EQUIPPED_AIRCRAFT","NOT_EQUIPPED_AIRCRAFT"],
      # "slotImg":["equip_icon_2_n8b0sex6xclf.png","equip_icon_10_lpoysb3zk6s4.png","equip_icon_4_mgy58yrghven.png","equip_icon_13_jdkmrexetpvn.png"]}]
      result = Enum.at(results, 3)
      expect result.book_no |> to(eq(129))
      expect result.lv |> to(eq(70))
      expect result.ship_type |> to(eq("航空巡洋艦"))
      expect result.ship_sort_no |> to(eq(1400))
      expect result.remodel_lv |> to(eq(1))
      expect result.ship_name |> to(eq("鈴谷改"))
      expect result.status_img |> to(eq("i/i_6cc94esr14nz_n.png"))
      expect result.star_num |> to(eq(5))
      expect result.ship_class |> to(eq("最上型"))
      expect result.ship_class_index |> to(eq(3))
      expect result.tc_img |> to(eq("s/tc_129_7k4atc4mguna.jpg"))
      expect result.exp_percent |> to(eq(4))
      expect result.max_hp |> to(eq(50))
      expect result.real_hp |> to(eq(50))
      expect result.damage_status |> to(eq("NORMAL"))
      expect result.slot_num |> to(eq(4))
      expect result.slot_equip_name |> to(eq(["20.3cm(3号)連装砲", "瑞雲", "15.5cm三連装副砲", "三式弾"]))
      expect result.slot_amount |> to(eq([5, 6, 5, 6]))
      expect result.slot_disp |> to(eq(~w(NOT_EQUIPPED_AIRCRAFT EQUIPPED_AIRCRAFT NOT_EQUIPPED_AIRCRAFT NOT_EQUIPPED_AIRCRAFT)))
      expect result.slot_img |> to(eq(~w(equip_icon_2_n8b0sex6xclf.png equip_icon_10_lpoysb3zk6s4.png equip_icon_4_mgy58yrghven.png equip_icon_13_jdkmrexetpvn.png)))
    end
  end
end
