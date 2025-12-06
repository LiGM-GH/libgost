# https://just.systems
libname := "libgost"
version := "0.1.0"
local-lib := "~/.local/share/typst/packages/local"
ll := join(local-lib, libname, version)
ll_lib := join(ll, "lib")
ll_template := join(ll, "template")

assetpath := "assets"
thumbnail_file := join(assetpath, "thumbnail.png")

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
    if [ -f {{local-lib}} ]; then echo 'Lib exists'; else mkdir -p {{local-lib}}; fi
    if [ -f {{ll_lib}} ]; then echo 'Lib exists'; else mkdir -p {{ll_lib}}; fi
    if [ -f {{ll_template}} ]; then echo 'Lib exists'; else mkdir -p {{ll_template}}; fi
    cp ./typst.toml {{ll}}
    cp ./assets/thumbnail.png {{ll}}
    cp -r ./lib/* {{ll_lib}}
    cp -r ./template/* {{ll_template}}
