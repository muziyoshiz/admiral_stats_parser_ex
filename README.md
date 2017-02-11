# admiral_stats_parser (Elixir version)

Parser for admiral stats JSON data exported from kancolle-arcade.net (Elixir version)

Original Ruby version: https://github.com/muziyoshiz/admiral_stats_parser

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `admiral_stats_parser` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:admiral_stats_parser, "~> 0.1.0"}]
    end
    ```

  2. Ensure `admiral_stats_parser` is started before your application:

    ```elixir
    def application do
      [applications: [:admiral_stats_parser]]
    end
    ```

## Usage

[オリジナルの Admiral Stats Parser](https://github.com/muziyoshiz/admiral_stats_parser) に実装済みの機能のうち、[Admiral Stats API](https://github.com/muziyoshiz/admiral_stats_api) で必要となる機能のみを Elixir に移植済み。

```elixir
# 基本情報
AdmiralStatsParser.parse_personal_basic_info(json, version)

# 艦娘図鑑
AdmiralStatsParser.parse_tc_book_info(json, version)

# 艦娘一覧
AdmiralStatsParser.parse_character_list_info(json, version)

# イベント海域情報
AdmiralStatsParser.parse_event_info(json, version)
```

## Specification

API version については [オリジナルの Admiral Stats Parser](https://github.com/muziyoshiz/admiral_stats_parser) の "Specification" を参照のこと。

## Test

```
$ mix espec
```

## Release

```
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/muziyoshiz/admiral_stats_parser_ex. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
