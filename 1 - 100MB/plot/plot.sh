for dir in */; do
    echo $dir
    cd $dir
    for plot in *.gp; do
        echo -e "\t$plot"
        gnuplot $plot
    done
    cd ..
done
