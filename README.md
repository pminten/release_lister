# ReleaseLister

Lists published releases of github projects.

To run this you first have to register it as an application at github, the
callback URL doesn't matter (not used).

Then run `bin/release_lister your_client_id your_client_secret repo_file` where
`repo_file` is the filename of a file containing repo full names (like
`pminten/release_lister`), one per line.

With the `-m` switch you can set a mode. Normally project descriptions are
pulled from the cache (data dir), if possible, and release info is loaded from
github. In `full` mode all project descriptions are fetched from github as well.
In `generate_only` mode (mostly useful for developers) nothing is downloaded but
cached info is used.
