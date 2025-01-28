local ls = require("luasnip")

ls.add_snippets("scala", {
  ls.parser.parse_snippet("main", "def main(args: Array[String]): Unit = {\n  $0\n}"),
  ls.parser.parse_snippet("println", 'println("$0")'),
})

