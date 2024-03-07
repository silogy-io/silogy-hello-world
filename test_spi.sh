#!/bin/bash
while [ "$1" != "--" ] && [ ! -z "$1" ]; do
    shift
done
shift
./obj_dir/Vtop $*
