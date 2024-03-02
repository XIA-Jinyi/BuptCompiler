#!/bin/sh
for src in `ls ./test/*.bpl`; do
    bin/bplc $src
done
