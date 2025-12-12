# https://just.systems

manifest := "typst.toml"
libname := "libgost"
version := "0.1.2"
assetpath := "assets"
thumbnail_file := join(assetpath, "thumbnail.png")
local-namespace := "~/.local/share/typst/packages/local"
local-lib := join(local-namespace, libname, version)
ll_lib := join(local-lib, "lib")
ll_template := join(local-lib, "template")

default:
    just --list

update-pdf:
    typst compile ./template/main.typ vision.pdf

watch-pdf:
    typst watch ./template/main.typ vision.pdf

update-png:
    typst compile --pages=1 ./template/main.typ {{ thumbnail_file }}

watch-png:
    typst watch --pages=1 ./template/main.typ {{ thumbnail_file }}

watch:
    watchexec -w ./lib -w ./template -w ./typst.toml -w {{ thumbnail_file }} just deploy

deploy:
    if [ -f {{ local-lib }} ]; then echo 'Lib exists'; else mkdir -p {{ local-lib }}; fi
    if [ -f {{ local-lib }} ]; then echo 'Lib exists'; else mkdir -p {{ ll_lib }}; fi
    if [ -f {{ local-lib }} ]; then echo 'Lib exists'; else mkdir -p {{ ll_template }}; fi
    cp {{ manifest }} {{ local-lib }}
    cp {{ thumbnail_file }} {{ local-lib }}
    cp -r ./lib/* {{ ll_lib }}
    cp -r ./template/* {{ ll_template }}

update-version NEW_VERSION:
    #!/usr/bin/env -S nu --stdin
    let version = open typst.toml | get package.version
    (
        grep
        --exclude='*.pdf'
        --recursive
        --files-with-matches
        --ignore-case
        --fixed-strings
        --regexp $version
    )
    | lines
    | each { (
        sed $in
            --in-place
            --expression $"s/($version)/{{ NEW_VERSION }}/"
    ) }

version:
    {{version}}

release VERSION:
    just update-version {{ VERSION }}
    git add $(nu -c 'git status --porcelain --no-renames | lines | split column " " --collapse-empty | where column1 =~ "M" | get column2 | to text | fzf --multi')
    git commit
    just deploy
    git tag {{ VERSION }}
    gh release create "v{{ VERSION }}"
