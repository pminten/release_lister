defmodule ReleaseLister.CLI do
  def run(args) do
    parsed = OptionParser.parse(args,
               aliases: [o: :output, d: :data, m: :mode])

    opts = elem(parsed, 0)
    args = elem(parsed, 1)
    
    if mode = opts[:mode] do
      if mode in ["full", "normal", "generate_only"] do
        opts = Keyword.put(opts, :mode, binary_to_atom(mode))
      else
        IO.puts "Invalid mode: #{mode}\n"
        print_usage()
      end
    end

    case args do
      [client_id, client_secret, repos_file] -> :ok
      [_,_,_|_] ->
        IO.puts "Too many arguments.\n"
        print_usage()
      _ ->
        IO.puts "Too few arguments.\n"
        print_usage()
    end

    unless Regex.match?(%r/^[a-fA-F0-9]+$/, client_id) do
      IO.puts "Invalid client_id: #{client_id}\n"
      print_usage()
    end
    
    unless Regex.match?(%r/^[a-fA-F0-9]+$/, client_secret) do
      IO.puts "Invalid client_secret: #{client_secret}\n"
      print_usage()
    end

    ReleaseLister.run(client_id, client_secret, repos_file, opts)
  end

  defp print_usage do
    IO.puts %S"""
    Usage:
      release_lister CLIENT_ID CLIENT_SECRET REPOS_FILE [OPTIONS]

    Options:
      -o, --output       Path to output dir, default: output
      -d, --data         Data directory, default: data
      -m, --mode         Mode ('full', 'normal' or 'generate_only')

    """
    exit(1)
  end

end
