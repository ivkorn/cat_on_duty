![ci](https://github.com/ivkorn/cat_on_duty/actions/workflows/ci.yml/badge.svg)
# Contributing
You should install the following packages depending on your linux distro or OS:
 - `sqlite3` package for DB support
 - `gcc` for NIF compilation
 - `graphviz` for ERD generation
 - `just` for running commands
 - `ansible` for deploying app

This project use `asdf-vm` as version manager. All tools versions listed in [.tool-versions](https://github.com/ivkorn/cat_on_duty/blob/main/.tool-versions).
All default coomands listed in [justfile](https://github.com/ivkorn/cat_on_duty/blob/main/justfile).
### Commands examples
Setup project:
```sh
just setup
```
Lint, audit and test the whole project:
```sh
just full-check
```
Deploy:
```sh
just deploy <tag>
```
Remote console:
```sh
just remsh
```

# License

This software is released under the [MIT License](/LICENSE).
© 2022 Pavel Solovev
