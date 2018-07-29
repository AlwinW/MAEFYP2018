# Create required setup files
# Create session files
# N_P=( 3 4 5 6 7 8 9 10 11 )
N_P=( 3 4 )
for i in $N_P[*]; do
  name=$(printf "%02d" i)
  echo N_P = $i
  sed "s/N_P =/N_P       = $i/g" naca0012 > results/naca0012-N_P$name.sesh
done
# Run dns on session file
cp bndry_prf.dat results/bndry_prf.dat
cd results
for sessionfile in *.sesh; do
  f="${sessionfile%.*}"                   &&
  cp $sessionfile  $f                     &&
  meshpr    $f > $f.msh                   &&
  meshpr -i $f > $f.mshi                  &&
  enumerate $f > $f.num                   &&
  dns $f | grep "Divergence Energy:"      &&
  addvortfield -G -s $f $f.fld > $f.Gfld  &&
  convert  $f.Gfld   > $f.flddump         &&
# compare  $f $f.fld > /dev/null          &&
# wallmesh $f $f.msh > $f.wallmsh         &&
  wallgrad $f $f.msh > $f.wallgrad        &&
  csplit -z "$f.flddump" /Session/ '{*}' >/dev/null &&
  for i in [xx]*; do 
    mv $i "$f.dump"; done                 &&
  echo $sessionfile complete
  rm $f.msh $f.num $f.fld $f.Gfld $f.mdl $f.flddump $f.his $f.flx
done
cd ..