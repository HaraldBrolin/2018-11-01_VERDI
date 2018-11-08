rule convert_biom_table:
    output:
        "../../../data/processed/biom_table/biom_table.txt"
    run:
        shell("biom convert -i ../../../data/processed/biom_table/feature-table.biom -o {output} --to-tsv")
# Write rule that downloads the sequences from qiime2 view and then use the python script to create a csv
