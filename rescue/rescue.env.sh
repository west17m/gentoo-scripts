#!/bin/bash

# system-wide alias
alias la="ls -alh"
alias lA="ls -Alh"
alias l1="ls -1h"
alias l="ls"
alias e="nano -w"
alias clar="clear"

alias screen.sh="screen -DR && exit"
alias ssh.forget="ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
alias news.read.sh="eselect news read all && eselect news purge"

echo "caption always \"%{= kw}%-w%{= BW}%n %t%{-}%+w %-= %{y}@%H %{r}%1`%{w}| %{g}%l %{w} | %{y}%m/%d/%Y %c %{w}\"" >> ~/.screenrc
screen -DR && exit
