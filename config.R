# This script will be used as a source to setup input files paths with user-specific paths
if(!file.exists("config.yaml")){
  cat("file.name: '' # path/to/fasta\nmetadata.file: '' # path/to/excel.xlxs\n", file = "config.yaml")
  cat("Please provide fasta file and excel file paths:.\n")
  Sys.sleep(1)
  utils::file.edit("config.yaml")
  stop("A config.yaml file has been created and opened for editing.")
} else {
  # Load user-specific configuration file with file paths
  config <- yaml::read_yaml("config.yaml") 
  cat("Configuration loaded from config.yaml:\n")
  
  # Check if required fields are empty
  if(is.null(config$file.name) || config$file.name == "" ||
     is.null(config$metadata.file) || config$metadata.file == "") {
    cat("One or more required fields in config.yaml are empty.\n")
    cat("Please provide fasta file and excel file paths:.\n")
    Sys.sleep(1)
    utils::file.edit("config.yaml")
  }
}