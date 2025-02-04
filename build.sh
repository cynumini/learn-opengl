#!/usr/bin/env sh

cmake -DCMAKE_BUILD_TYPE=Debug -B out/debug
cmake -DCMAKE_BUILD_TYPE=Release -B out/release
