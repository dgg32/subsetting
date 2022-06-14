DIR="$(dirname "${1}")"

echo $DIR

cd $DIR

pwd
samtools view -H $1 > header.txt

samtools view $1 |  gawk  '{ print > substr($1,0,20)"_test"}'

for sam in ./*_test; do cat header.txt "$sam" > "$sam.sam"; done

rename 's/([A-Z]\d+)L(\d)(C\d+)(R\d+)_test.sam/$1_L0$2_$3$4_Read1_test.sam/' ./*_test.sam