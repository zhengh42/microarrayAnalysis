wget ftp://ftp.ncbi.nlm.nih.gov/geo/platforms/GPL15nnn/GPL15048/soft/GPL15048_family.soft.gz

zcat GPL15048_family.soft.gz | egrep -v '^!|^#|DATABASE|PLATFORM|SERIES|VALUE' > GPL15048_family.soft.tmp
split -a 4 -d -l 60608 GPL15048_family.soft.tmp GPL15048_family.soft.split
mv GPL15048_family.soft.split0000 GPL15048_family.soft.IDs

for f in ` ls GPL15048_family.soft.split*`; do 
	sed -i '1s/\^SAMPLE\s=\s/ID\t/' $f; 
	match.pl $f 1 GPL15048_family.soft.IDs 1 > $f.ordered 
done

for f in ` ls GPL15048_family.soft.split*ordered*`; do
	cut -f2 $f > $f.col2
done

paste GPL15048_family.soft.IDs GPL15048_family.soft.split*ordered.col2  > GPL15048_family.soft.ID.expr

rm *split* *tmp
