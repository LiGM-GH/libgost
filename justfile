# https://just.systems
manifest := "typst.toml"
libname := "libgost"
version := "1.0.0"

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
    typst compile --pages=1 ./template/main.typ {{thumbnail_file}}

watch-png:
    typst watch --pages=1 ./template/main.typ {{thumbnail_file}}

watch:
    watchexec -w ./lib -w ./template -w ./typst.toml -w {{thumbnail_file}} just deploy

deploy:
    cp {{manifest}} {{local-lib}}
    cp {{thumbnail_file}} {{local-lib}}
    cp -r ./lib/* {{ll_lib}}
    cp -r ./template/* {{ll_template}}
