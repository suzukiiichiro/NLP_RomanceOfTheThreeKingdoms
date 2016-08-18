#!/bin/bash

#堀内作成
glist="../gaiji/jislist.txt";
#orginal/01/吉川英治\ 三国志\ 序.htm
mkconvert(){
  :>"$cvfname";
  cat "$list"|nkf -wLu > tmp.txt;
  startflg="";
  endflg="";
  while read line;do
    #見出し取り出し
#<h2 class="subtitle">桃園の巻</h2>
    if echo "$line" |grep "subtitle">/dev/null;then
      line=`echo "$line"|sed -e "s|.*<h2[^>]*>||" -e "s|</h2>.*||"`;
      echo "$line"|sed -e "s|<br>||g" |tee -a "$cvfname";
      continue;
    fi
    if [ -z "$startflg" ];then
      if echo "$line" |grep "main_text">/dev/null;then
        startflg="true";
        echo "startflgを立てました。";
      else
        echo "startflgが立ってないのでスキップ";
      fi
        continue;
    fi
    if [ -z "$endflg" ];then
      if echo "$line" |grep "bibliographical_information">/dev/null;then
        echo "endflgを立てました。";
        endflg="true";
      fi
    fi
    if [ -n "$endflg" ];then
      echo "endflgが立っているのでスキップ";
      continue; 
    fi
    #</div>のみは削除 
    if echo "$line"|grep "^</div>$" >/dev/null;then
      echo "</div> のみなのでスキップ";
      continue;
    fi
    #字下げは削除
    if echo "$line"|grep "jisage_2" >/dev/null;then
      echo "jisage_2 なのでスキップ";
      continue;
    fi
    #外字処理
    if echo "$line"|grep "<img" >/dev/null;then
    #<img src="./吉川英治 三国志 桃園の巻_files/1-86-80.png" alt="※(「さんずい＋（冢−冖）」、第3水準1-86-80)" class="gaiji">
      echo "$line" |sed -e "s|<img|\n<img|g" |grep -v "^$">gj.txt;
      line="";
      while read gj;do
        key=`echo "$gj"|grep "<img"|sed -e "s|.*alt=\"||" -e "s|>.*||"|sed -e "s|.*、||"|sed -e "s|)\".*||"|sed -e "s|\".*||"`;
        gaiji="";
        if [ -n "$key" ];then
          gaiji=`cat "$glist"|grep "$key,"|awk -F, '{print $3;}'`;  
        fi
        #<img src="./吉川英治 三国志 桃園の巻_files/1-92-64.png" alt="※(「丕＋おおざと」、第3水準1-92-64)" class="gaiji">
        if [ -n "$gaiji" ];then
          gj=`echo "$gj"|sed -e "s|<img[^>]*>|$gaiji|"`;
        fi
        line="$line$gj";
      done < gj.txt
    fi
    #ルビ処理
    if echo "$line"|grep "<ruby>" >/dev/null;then
      #１行にrubyが複数ある場合を考えrubyごとに複数行に変換して処理する
      echo "$line" |sed -e "s|<ruby|\n<ruby|g" |grep -v "^$">rb.txt;
      line="";
      while read rb;do
        rb=`echo "$rb"|sed -e "s|<ruby>.*<rb>||g" -e "s|</rb>.*</ruby>||"`;
        line="$line$rb";
      done < rb.txt
    fi
    #em タグ除去
    if echo "$line"|grep "</em>" >/dev/null;then
      line=`echo "$line"|sed -e "s|<em[^>]*>||g"  -e "s|</em>||g"`;
    fi
    #"kaeriten 除去
    if echo "$line"|grep "kaeriten" >/dev/null;then
      line=`echo "$line"|sed -e "s|<sub[^>]*>||g"  -e "s|</sub>||g"`;
    fi
    if echo "$line"|grep "chitsuki_2" >/dev/null;then
#<div class="chitsuki_2" style="text-align:right; margin-right: 2em">青州<ruby><rb>太守</rb><rp>（</rp><rt>タイシュ</rt><rp>）</rp></ruby><ruby><rb><img src="./吉川英治 三国志 桃園の巻_files/1-94-87.png" alt="※(「龍／共」、第3水準1-94-87)" class="gaiji">景</rb><rp>（</rp><rt>キョウケイ</rt><rp>）</rp></ruby></div>
      line=`echo "$line"|sed -e "s|<div[^>]*>||g" -e "s|</div>||"`;
    fi
    #noteタグ （中身も）除去 #１行にspanが複数あったらダメなので注意
    if echo "$line"|grep "notes" >/dev/null;then
      line=`echo "$line"|sed -e "s|<span[^<]*</span>||g" -e "s|※||g"`;
    fi
    if echo "$line"|grep -e "jisage_7" -e "isage_3">/dev/null;then
      line=`echo "$line"|sed -e "s|.*<a[^>]*>||g" -e "s|</a>.*||"`;
    fi
    #書き出す
    echo "$line"|sed -e "s|<br>||g" |tee -a "$cvfname";
  done < tmp.txt
}
mklist(){
  find original -name "*htm" > list.txt;
  while read list;do
    dir=`dirname "$list"|sed -e "s|original/||"`;
    cvfname="convert/${dir}.txt";
    #
    mkconvert;
  done < list.txt
}

mklist;
exit;
