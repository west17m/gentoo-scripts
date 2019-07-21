#!/bin/bash
# fix scrolling
echo 'termcapinfo xterm* ti@:te@' >> ~/.screenrc

#add info line
echo 'caption always "%{= kw}%-w%{= BW}%n %t%{-}%+w %-= %{y}@%H %{r}%1`%{w}| %{g}%l %{w} | %{y}%m/%d/%Y %c %{w}"' >> ~/.screenrc

