#!/usr/bin/env bash

#  Copyright 2013 Manuel Gutierrez <dhunterkde@gmail.com>
#  https://github.com/xr09/rainbow.sh
#  Bash helper functions to put colors on your scripts
#
#  Usage example:
#  green=$(green "Grass is green")
#  echo "Coming next: $green"
#

__RAINBOWPALETTE="38;5"

function __color()
{
  echo -e " \e[$__RAINBOWPALETTE;$2m$1\e[0m"
}

function red()
{
  echo $(__color "$1" "1")
}

function _red()
{
  echo -n $(__color "$1" "1")
}

function green()
{
  echo $(__color "$1" "2")
}

function _green()
{
  echo -n $(__color "$1" "2")
}

function yellow()
{
  echo $(__color "$1" "3")
}

function _yellow()
{
  echo -n $(__color "$1" "3")
}

function blue()
{
  echo $(__color "$1" "27")
}

function _blue()
{
  echo -n $(__color "$1" "27")
}

function cyan()
{
  echo $(__color "$1" "6")
}

function _cyan()
{
  echo -n $(__color "$1" "6")
}

function purple()
{
  echo $(__color "$1" "171")
}

function _purple()
{
  echo -n $(__color "$1" "171")
}

