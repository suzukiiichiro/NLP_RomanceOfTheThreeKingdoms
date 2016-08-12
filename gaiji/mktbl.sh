#!/bin/bash

##堀内作成
menflg="OFF";
#sui="第4水準";
#gmen="2面"
#igmen="2";
list="jis_4.html";
sui="第3水準";
gmen="1面"
igmen="1";
list="jis_3.html";
:>tbl.txt;
while read line;do
  if echo "$line"|grep "$gmen" > /dev/null;then
      men=`echo "$line"|sed -e "s|.*$gmen|${igmen}-|" -e "s|区||g" -e "s|<BR>||g" -e "s|</TD>||g" -e "s|||g"`;
  else
    if echo "$line"|grep -v "<TD" >/dev/null;then
      continue;
    fi
    if echo "$line"|grep "面区" >/dev/null;then
      continue;
    fi
    if echo "$line"|grep -v "</TR>" >/dev/null;then
      echo "topline:$line";
      top=`echo "$line"|grep "center"|sed -e "s|.*<TD[^>]*>||" -e "s|</TD>.*||"`;
      
    else
      echo "$line"|sed -e "s|<TD|\n<TD|g" >tmp.txt;
      #<TD align="center">0</TD>
      if echo "$line" |grep "center" >/dev/null;then
        top=`cat "tmp.txt"|grep "center"|sed -e "s|.*<TD[^>]*>||" -e "s|</TD>.*||"`;
      fi
      cat "tmp.txt"|grep -v "center" |grep -v "^$"> tmp2.txt;
      cnt="$top";
      echo "$cnt";
      cat "tmp2.txt"
      while read td;do
        chr=`echo "$td"|sed -e "s|.*<TD[^>]*>||" -e "s|</TD>.*||"`;
        echo "$sui$men-$cnt,$chr" >> tbl.txt;
        cnt=`expr $cnt + 1`;
      done < tmp2.txt;
    fi
  fi

done < "$list"
