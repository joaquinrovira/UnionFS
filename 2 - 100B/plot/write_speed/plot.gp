# set terminal latex
set terminal pngcairo
set datafile separator ','
#set key autotitle columnhead

#set grid
#set key outside
set title "Write I/O speed - 100B"
set ylabel 'Speed (kB/s)'

set xrange [-0.5:4.5]

set xtic rotate by -30

set boxwidth 0.25
set style fill solid


set output 'plot0.png'

plot \
"data.csv" using 0:2:xtic(1) with boxes notitle ls 2,\
"data.csv" using 0:2:3:xticlabels(1) with yerrorbars ls 1 notitle,\


# set output 'plot1.png'

# set yrange [0:250]

# plot \
# "data.csv" using 0:2:xtic(1) with boxes notitle ls 2,\
# "data.csv" using 0:2:3:xticlabels(1) with yerrorbars ls 1 notitle,\

