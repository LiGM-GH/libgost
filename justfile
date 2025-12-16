# https://just.systems

manifest := "typst.toml"
libname := "libgost"
version := "0.1.3"
assetpath := "assets"
thumbnail_file := join(assetpath, "thumbnail.png")
os := if os_family() == "windows" { "windows" } else if os() == "macos" { "macos" } else { "unix" }
share := if os == "windows" { env("APPDATA") } else if os == "macos" { "~/Library/Application Support" } else if os == "unix" { "~/.local/share" } else { error("OS must be either windows, or unix, or macos") }
local-namespace := join(share, "typst", "packages", "local")
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
    @if [ -e {{ local-lib }}   ]; then echo '{{ local-lib }} \t\t {{ BG_GREEN }}exists{{ NORMAL }}'  ; else mkdir -p {{ local-lib }}  ; fi
    @if [ -e {{ ll_lib }}      ]; then echo '{{ ll_lib }} \t\t {{ BG_GREEN }}exists{{ NORMAL }}'     ; else mkdir -p {{ ll_lib }}     ; fi
    @if [ -e {{ ll_template }} ]; then echo '{{ ll_template }} \t\t {{ BG_GREEN }}exists{{ NORMAL }}'; else mkdir -p {{ ll_template }}; fi
    @if cp {{ manifest }} {{ local-lib }}       ; then echo "{{ BG_GREEN }}Success copying {{ manifest }} {{ NORMAL }}"       ; else echo "{{ BG_RED }}ERROR copying {{ manifest }} {{ NORMAL }}"      ; fi
    @if cp {{ thumbnail_file }} {{ local-lib }} ; then echo "{{ BG_GREEN }}Success copying {{ thumbnail_file }} {{ NORMAL }}" ; else echo "{{ BG_RED }}ERROR copying {{ thumbnail_file }} {{ NORMAL }}"; fi
    @if cp -r ./lib/* {{ ll_lib }}              ; then echo "{{ BG_GREEN }}Success copying ./lib/* {{ NORMAL }}"              ; else echo "{{ BG_RED }}ERROR copying ./lib/* {{ NORMAL }}"             ; fi
    @if cp -r ./template/* {{ ll_template }}    ; then echo "{{ BG_GREEN }}Success copying ./template/* {{ NORMAL }}"         ; else echo "{{ BG_RED }}ERROR copying ./template/* {{ NORMAL }}"        ; fi

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
    {{ version }}

release VERSION:
    just update-version {{ VERSION }}
    git add $(nu -c 'git status --porcelain --no-renames | lines | split column " " --collapse-empty | where column1 =~ "M" | get column2 | to text | fzf --multi')
    git commit
    just deploy
    git tag {{ VERSION }}
    gh release create "v{{ VERSION }}"
