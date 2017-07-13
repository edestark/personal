#!/bin/bash
#
# trap ctrl-c
trap ctrl_c INT

ctrl_c() {
        echo "** Sentaaaa o dedo no ctrl+c"
}
for i in $(seq 0 12345552 9999999999999); do echo "Número de pessoas enganadas:" $i; done
