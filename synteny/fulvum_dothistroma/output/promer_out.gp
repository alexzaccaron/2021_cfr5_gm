set terminal png tiny size 800,800
set output "output/promer_out.png"
set xtics rotate ( \
 "tig00000003" 1.0, \
 "tig00000006" 11362290.0, \
 "tig00004032" 18398203.0, \
 "tig00000008" 24631067.0, \
 "tig00004034" 30772374.0, \
 "tig00000014" 36549838.0, \
 "tig00000019" 41611609.0, \
 "tig00000011" 46298403.0, \
 "tig00000022" 50639008.0, \
 "tig00000025" 54709499.0, \
 "tig00000028" 58727235.0, \
 "tig00000031" 62038456.0, \
 "tig00000033" 64645038.0, \
 "tig00000037" 66708184.0, \
 "tig00000039_mt" 67168462.0, \
 "" 67255117 \
)
set ytics ( \
 "KB446535.1" 1.0, \
 "KB446536.1" 5111597.0, \
 "KB446537.1" 8418473.0, \
 "KB446538.1" 11170686.0, \
 "KB446539.1" 13791392.0, \
 "KB446540.1" 16386939.0, \
 "KB446541.1" 18574617.0, \
 "KB446542.1" 20680678.0, \
 "KB446543.1" 22607931.0, \
 "KB446544.1" 24365756.0, \
 "KB446545.1" 26001522.0, \
 "KB446546.1" 27559830.0, \
 "KB446547.1" 28815863.0, \
 "KB446548.1" 29778432.0, \
 "" 30186412 \
)
set size 1,1
set grid
unset key
set border 0
set tics scale 0
set xlabel "REF"
set ylabel "QRY"
set format "%.0f"
set mouse format "%.0f"
set mouse mouseformat "[%.0f, %.0f]"
set xrange [1:67255117]
set yrange [1:30186412]
set zrange [0:100]
set colorbox default
set cblabel "%similarity"
set cbrange [0:100]
set cbtics 20
set pm3d map
set palette model RGB defined ( \
  0 "#000000", \
  4 "#DD00DD", \
  6 "#0000DD", \
  7 "#00DDDD", \
  8 "#00DD00", \
  9 "#DDDD00", \
 10 "#DD0000"  \
)
set style line 1  palette lw 3 pt 6 ps 1
set style line 2  palette lw 3 pt 6 ps 1
set style line 3  palette lw 3 pt 6 ps 1
splot \
 "output/promer_out.fplot" title "FWD" w l ls 1, \
 "output/promer_out.rplot" title "REV" w l ls 2
