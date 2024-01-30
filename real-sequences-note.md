# All Iso-1 
SRR22822929 ont-ligation
SRR22822930 ont-ligation
SRR23215007 ont-ligation
SRR23215008 ont-ligation
SRR23215010 ont-ligation
SRR23215009 ont-ligation
SRR11906526 pb-rs2
SRR11906525 pb-sequel
iso1_hifi.fastq.gz  pb-hifi
iso1-R1041_ONT.fastq.gz ont-ligation
iso1-R941-2_ONT.fastq.gz    ont-ligation
iso1-R941_ONT.fastq.gz  ont-ligation
A4_hifi_099.min6k.fasta.gz  pb-hifi

# SRR22822929
=SRX18782374
Q20
male adult flies
LSK114 ligation kit
MinION R10.4.1 flow cell at 400bps
Guppy 6.4.2 in super-accuracy mode using the default quality filter.

# SRR23215008
=SRX19162819
Q20
duplex only
male adult flies
LSK114 ligation kit
MinION R10.4.1 flow cell at 400bps
Duplex basecalling
Guppy 6.4.2 in super-accuracy mode using the default quality filter
duplex_tools

# SRR23215007
=SRX19162820
Q20
simplex only
LSK114 ligation kit
MinION R10.4.1 flow cell at 400bps
Duplex basecalling
Guppy 6.4.2 in super-accuracy mode using the default quality filter
duplex_tools
Reads used for duplex calling were removed from the simplex read set

# SRR22822930
=SRX18782373
Q20
male adult flies
LSK114 ligation kit
MinION R10.4.1 flow cell at 260bps
Guppy 6.4.2 in super-accuracy mode using the default quality filter

# SRR23215010
=SRX19162817
Q20
duplex only
male adult flies
LSK114 ligation kit
MinION R10.4.1 flow cell at 260bps
Duplex basecalling
Guppy 6.4.2 in super-accuracy mode using the default quality filter
duplex_tools

# SRR23215009
=SRX19162818
Q20
simplex only
male adult flies
LSK114 ligation kit
MinION R10.4.1 flow cell at 260bps
Duplex basecalling
Guppy 6.4.2 in super-accuracy mode using the default quality filter
duplex_tools
Reads used for duplex calling were removed from the simplex read set

# SRR11906526
=SRX8453113
PacBio RS II
female virgin
20 kb , BluePippin Size-Selection
MagBead loading
two SMART cells

# SRR11906525
=SRX8453114
PACBIO_SMRT (Sequel)
female virgin
20 kb , BluePippin Size-Selection
MagBead loading
two SMART cells


prefetch -pcv SRR11906526 SRR11906525

tech="ONT"
for i in /pub/jenyuw/Eval-sv-temp/raw/{SRR22822929,SRR23215008,SRR23215007,SRR22822930,SRR23215010,SRR23215009}/*.sra
do
echo $i
name=`basename $i | sed "s/.sra/-R1041_${tech}.fastq.gz/"`
echo $name
fastq-dump --split-spot --stdout  $i | pigz -p 15 -v  >/pub/jenyuw/Eval-sv-temp/raw/${name}
done