cd data
../../archiver -c h ../result * 2> /dev/null
cd ../tmp
rm *
../../archiver -d h ../result 2> /dev/null

failed=""
for i in *
do 
    tmp=$(diff -q -b $i ./../data/$i)
    if [ -z "$tmp" ]
    then
        echo $i: ok
    else
        echo $i: fail
        failed="$failed, $i"
    fi
done

if [ -z "$tmp" ]
then
    echo ========
    echo = Pass =
    echo ========
else
    echo ========
    echo = Fail =
    echo ========
    echo failed: $failed
fi
