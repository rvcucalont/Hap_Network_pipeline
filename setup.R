# This script will be used a source to setup input files paths with user-specific paths
if(!file.exists("config.yaml")){
  cat("file.name: ''\nmetadata.file: ''", file = "config.yaml")
  stop("A config.yaml file has been created. Please edit it with the correct file paths and run the script again.")
} else {
  # Load user-specific configuration file with file paths
  config <- yaml::read_yaml("config.yaml") 
  cat(paste0("Configuration loaded from config.yaml:\n",
             "file.name: ", config$file.name, "\n",
             "metadata.file: ", config$metadata.file, "\n"))
}