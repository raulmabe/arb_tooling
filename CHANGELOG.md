# 0.0.7

- feat(file_rename): add `file_rename` command that allows to rename certain files from a certain directory.

# 0.0.6

- feat(from_csv): add `--json` flag to generate files with `.json` extension.
- fix(from_csv): do not generate meta key if `description` and `placeholders` are empty.

# 0.0.5

- fix: commands in docs having a typo.
- fix: `version.dart` not being generated after build.
- fix: `placeholders` were not being generated.
- fix: take into account if outputDir has trailing slash already.

# 0.0.4

- build: Downgrade `meta` dependency to `1.7.0`

# 0.0.3

- docs: Restructured README.md
- fix: Logo in README.md
- chore: Added binary to `bin` directory

# 0.0.2

- feat: Generate ARB files from a CSV file
- feat: Generate ARB files from URL which hosts a CSV file
- feat: Generate CSV file from ARB files
