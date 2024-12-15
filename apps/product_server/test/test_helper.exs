ExUnit.start()


Path.wildcard("../basket_server/test/support/**/*.ex")
|> Enum.each(&Code.require_file/1)
