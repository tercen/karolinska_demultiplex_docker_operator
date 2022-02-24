# Karolinsa's Demultiplex Docker Operator

#### Description

The Karolinska's Demultiplex Docker operator implements a FastQ demultiplexing script inside Tercen.

#### Usage

Input projection|.
---|---
Leave empty

For this operator to work there must be two folders on the file system (replace <username> and <projectname> with the user and project names for this run):
    
    - /var/lib/tercen/external/read/<username>/<project_name>/files_to_demultiplex
    - /var/lib/tercen/external/write/<username>/<project_name>/

The operator will look for the following files inside the first of these folders (`files_to_demultiplex`):

    1) A forward read FastQ file (includes "_R1_" in it's name);
    2) A reverse read FastQ file (includes "_R2_" in it's name);
    3) A `col.txt` file;
    4) A `row.txt` file;

If these four files are present in the folder, the operator will run the demultiplexing script script. The demultiplexed FastQ files will be outputed to the `/var/lib/tercen/external/write/<username>/<project_name>/demultiplexed_fastqs` folder. File names will come from the `col.txt` and `row.txt` files.

In addition, the following Tercen table will be outputed from the operator

Outputs|.
---|---
sample | String, sample name from the col.txt and row.txt files
read_number | Integer, number of reads assigned to each sample

