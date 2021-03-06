library(tercen)
library(dplyr, warn.conflicts = FALSE)
library(stringr)

ctx <- tercenCtx()

if(!("folder"  %in% ctx$cnames)) {
  stop("No column named 'folder' found.")
}

folder = ctx$cselect(c("folder"))[[1]][[1]]

parts =  unlist(strsplit(folder, '/'))
volume = parts[[1]]
input_folder <- paste(parts[-1], collapse="/")


# Define input and output paths
input_path <- paste0("/var/lib/tercen/share/", volume, "/", input_folder)


# Check if a "files_to_demultiplex" folder exists and is not empty
if( dir.exists(input_path) == FALSE) {

  stop(paste("ERROR:", input_folder, "folder does not exist in project volume ", volume ))

}

if (length(dir(input_path)) == 0) {
  stop(paste("ERROR:", input_folder, "folder is empty  in project volume ", volume))
}

# Define and create output paths

output_volume = "write"
output_folder <- paste0(output_volume, "/",
                        format(Sys.time(), "%Y_%m_%d_%H_%M_%S"),
                        "_demultiplexed_fastqs")

output_path <- paste0("/var/lib/tercen/share/",
                      output_folder, "/")

system(paste("mkdir -p", output_path))

# Check if individual files are present in the input folder

r1_file <- list.files(input_path, "_R1_", recursive = TRUE,
                      full.names = TRUE)

if (length(r1_file) == 0) stop("ERROR: could not find a forward read file.")

r2_file <- list.files(input_path, "_R2_", recursive = TRUE,
                      full.names = TRUE)

if (length(r2_file) == 0) stop("ERROR: could not find a reverse read file.")

col_file <- list.files(input_path, "col.txt", recursive = TRUE,
                       full.names = TRUE)

if (length(col_file) == 0) stop("ERROR: could not find a col.txt file.")

row_file <- list.files(input_path, "row.txt", recursive = TRUE,
                       full.names = TRUE)

if (length(row_file) == 0) stop("ERROR: could not find a row.txt file.")


print(paste0("python3 demultiplex_TCR_fastqs_by_row_and_column_barcodes_v3.py ",
              r1_file, " ", r2_file, " ", output_path, " --gzip_output yes --row_barcodes_file ",
              row_file, " --col_barcodes_file ", col_file))

system(paste0("python3 demultiplex_TCR_fastqs_by_row_and_column_barcodes_v3.py ",
              r1_file, " ", r2_file, " ", output_path, " --gzip_output yes --row_barcodes_file ",
              row_file, " --col_barcodes_file ", col_file))

output_r1_files <- list.files(output_path,
                              "_R1.fastq",
                              full.names = TRUE)

output_table <- c()

for (sample_R1 in output_r1_files) {
  
  sample_name <- str_split(basename(sample_R1),
                           "_R1.fastq")[[1]][[1]]
  
  number_of_lines <- as.integer(system(paste("zcat",
                                             sample_R1,
                                             "| wc -l | awk '{print $1}'"),
                                       intern = TRUE))
  
  number_of_reads <- number_of_lines / 4
  
  output_table <- bind_rows(output_table,
                            tibble(sample = sample_name,
                                   read_number = number_of_reads))
  
}

output_table %>%
  mutate(.ci = 0,
         demultiplexed_folder = output_folder) %>%
  ctx$addNamespace() %>%
  ctx$save()
