#!/bin/sh

#堀内作成
:>jislist.txt;
cat "jisx0213_2004code-u8.txt"|awk -F, '{print $8","$10;}'> jis.txt;
while read line;do
  uni=`echo "$line"|awk -F, '{print $2;}' | tr "[:upper:]" "[:lower:]"|sed -e "s|.*x||" -e "s|;||"`;
  echo "$uni";
  if [ -n "$uni" ];then
    #(僧)<add>
    jis=`cat "jis.txt"|grep "$uni"|sed -e "s|.*(||" -e "s|).*||"`;
    echo "$line,$jis" |tee -a jislist.txt;
  fi

done < tbl.txt 
