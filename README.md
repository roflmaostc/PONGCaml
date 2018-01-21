Implementation of PONG using [OCaml](http://ocaml.org/). Tested under Linux with OCaml 4.06, Windows may not supported.

Compilation is done via:
```bash
ocamlbuild -package graphics -package unix pong.native
```
As you can see we use the [Graphics package](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Graphics.html) for visualization. 
*unix* is used for delay.

Execution via:
```bash
./pong.native
```
The bar is moved via **l** and **r**.

