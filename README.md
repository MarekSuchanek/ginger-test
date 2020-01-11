# ginger-test

Simple example to test [Ginger](https://github.com/tdammers/ginger)

## Macros example

```console
$ stack build

$ stack exec ginger-test-exe data/lipsum1.html.j2 100 > out1.html

$ stack exec ginger-test-exe data/lipsum2.html.j2 100 > out2.html

$ stack exec ginger-test-exe data/lipsum3.html.j2 100 > out3.html
```
