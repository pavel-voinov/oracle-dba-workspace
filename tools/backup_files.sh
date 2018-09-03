for i in `seq 3 6`; do
  h="pcnadb${i}"
  mkdir -p $h
  for f in `cat files.lst`; do
    x=`dirname $f`
    mkdir -p $h/$x
    rsync -avP -L oracle@$h:/$f $h/$x/
  done
done
