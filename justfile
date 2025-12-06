# https://just.systems
local-libpath := "~/.local/share/typst/packages/local"
libname := "libgost"
version := "1.0.0"
libpath := join(local-libpath, libname, version)
libpath_lib := join(libpath, "lib")
libpath_template := join(libpath, "template")

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
    cp ./typst.toml {{libpath}}
    cp ./thumbnail.png {{libpath}}
    cp -r ./lib/* {{libpath_lib}}
    cp -r ./template/* {{libpath_template}}
