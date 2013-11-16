defmodule ReleaseLister do
  alias ReleaseLister.Fetcher
  alias ReleaseLister.Templates

  defrecord Config, output: "output", data: "data", mode: :normal,
                    client_id: nil, client_secret: nil

  # These correspond to the field names in the GitHub API for releases.
  defrecord Release, repo: nil, name: nil, body: nil, draft: nil,
                     published_at: nil, html_url: nil

  @doc """
  Create the releases list.
  """
  def run(client_id, client_secret, repos_file, opts) do
    repos = load_repos_file(repos_file)

    config = Config[client_id: client_id, client_secret: client_secret].update(opts)

    File.mkdir_p!(config.data)
    File.mkdir_p!(config.output)

    Fetcher.start(config)
    
    case config.mode do
      :full ->
        descrs = Fetcher.fetch_descriptions(repos)
        save_descriptions(descrs, config)
        rels = Fetcher.fetch_releases(repos)
        save_releases(rels, config)
        generate_output(descrs, rels, config)
      :normal ->
        loaded_descrs = load_descriptions(config)
        descrs = repos
                 |> Enum.reject(&Dict.has_key?(loaded_descrs, &1))
                 |> Fetcher.fetch_descriptions()
                 |> Dict.merge(loaded_descrs)
        save_descriptions(descrs, config)
        rels = Fetcher.fetch_releases(repos)
        save_releases(rels, config)
        generate_output(descrs, rels, config)
      :generate_only ->
        descrs = load_descriptions(config)
        rels = load_releases(config)
        generate_output(descrs, rels, config)
    end
  end

  defp load_repos_file(repos_file) do
    File.read!(repos_file)
    |> String.split(%r/\r\n?|\n/)
    |> Stream.map(fn line ->
        stripped = String.strip(line)
        if Regex.match?(%r{^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$}, stripped) do
          stripped
        else
          unless stripped == "" or String.starts_with?(stripped, "#") do
            IO.puts(:stderr, "Invalid repo: #{stripped}")
          end
          nil
        end
      end)
    |> Enum.reject(&nil?/1)
  end
  
  defp load_descriptions(config) do
    path = Path.join(config.data, "descriptions.json")
    case File.read(path) do
      { :ok, s }          -> JSON.decode!(s)
      { :error, :enoent } -> HashDict.new()
      { :error, e       } ->
        IO.puts(:stderr, "Could not read #{path}: #{e}")
        []
    end
  end

  defp save_descriptions(descrs, config) do
    Path.join(config.data, "descriptions.json") |> File.write!(JSON.encode!(descrs))
  end

  defp load_releases(config) do
    path = Path.join(config.data, "releases.json")
    case File.read(path) do
      { :ok, s }          -> JSON.decode!(s) |> Enum.map(&Release.new(Dict.to_list(&1)))
      { :error, :enoent } -> []
      { :error, e       } ->
        IO.puts(:stderr, "Could not read #{path}: #{e}")
        []
    end
  end

  defp save_releases(rels, config) do
    # Make a dict of field key -> field tuple index.
    fields = Release.__record__(:fields)
             |> Dict.keys()
             |> Enum.map(fn k -> {k, Release.__record__(:index, k)} end)
  
    path = Path.join(config.data, "releases.json")
    dicts = Enum.map(rels, fn rel ->
              Enum.map(fields, fn { k, i } -> {k, elem(rel, i)} end)
            end)
    File.write!(path, JSON.encode!(dicts))
  end

  defp generate_output(descrs, rels, config) do
    IO.puts("Generating release list")
    rels = Enum.reject(rels, &(&1.draft))
           |> Enum.sort(&(&1.published_at > &2.published_at))
    File.cp_r!(Path.join(__DIR__, "release_lister/templates/assets"),
               config.output)
    path = Path.join(config.output, "index.html")
    File.write!(path, Templates.index_template(descrs, rels))
  end
end
