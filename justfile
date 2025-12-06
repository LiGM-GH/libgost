# https://just.systems
local-libpath := "~/.local/share/typst/packages/local"
libname := "libgost"
version := "1.0.0"
libpath := join(local-libpath, libname, version)
libpath_lib := join(libpath, "lib")
libpath_template := join(libpath, "template")

default:
    just --list

watch-pdf:
    typst watch ./template/main.typ vision.pdf

watch-png:
    typst watch --pages=1 ./template/main.typ ./thumbnail.png

watch:
    watchexec -w ./lib -w ./template -w ./typst.toml -w thumbnail.png just deploy

deploy:
    cp ./typst.toml {{libpath}}
    cp ./thumbnail.png {{libpath}}
    cp -r ./lib/* {{libpath_lib}}
    cp -r ./template/* {{libpath_template}}
