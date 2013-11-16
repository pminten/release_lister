defmodule ReleaseLister.Fetcher do
  alias ReleaseLister.HttpClient
  alias ReleaseLister.Release

  def start(config) do
    HttpClient.start(config.client_id, config.client_secret)
  end

  def fetch_descriptions(repos) do
    Enum.flat_map(repos, fn repo ->
      IO.puts("Fetching description of #{repo}")
      r = ReleaseLister.HttpClient.get("repos/#{repo}")
      if r.status_code == 200 do
        [{ repo, r.body["description"] }]
      else
        IO.puts(:stderr, "Error #{r.status_code} for repo #{repo}: #{inspect r.body}")
        []
      end
    end) |> HashDict.new()
  end

  def fetch_releases(repos) do
    Enum.flat_map(repos, fn repo ->
      IO.puts("Fetching releases of #{repo}")
      r = ReleaseLister.HttpClient.get("repos/#{repo}/releases")
      if r.status_code == 200 do
        Enum.map(r.body, &Release[repo: repo].update(Dict.to_list(&1)))
      else
        IO.puts(:stderr, "Error #{r.status_code} for releases of repo #{repo}: #{inspect r.body}")
        []
      end
    end)
  end
end

defmodule ReleaseLister.HttpClient do
  use HTTPotion.Base

  def start(client_id, client_secret) do
    Process.put(:rl_client_id, client_id)
    Process.put(:rl_client_secret, client_secret)
    start()
  end

  def process_url(url) do
    client_id = Process.get(:rl_client_id)
    client_secret = Process.get(:rl_client_secret)
    "https://api.github.com/#{url}?client_id=#{client_id}&client_secret=#{client_secret}"
  end

  def process_response_body(body) do
    JSON.decode!(body)
  end
end
