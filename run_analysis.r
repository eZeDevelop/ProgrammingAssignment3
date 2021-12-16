# Run Analysis
#
# You should create one R script called run_analysis.R that does the following.
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each
#    measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set
#  with the average of each variable for each activity and each subject.

# --------------------------------------------------------------- Prerequisites

# Clear the environment
rm( list = ls() )

# R and RStudio are stupid as there is no straightforward way to specify a
# the root folder to this script file
if ( dir.exists("03-getting-and-cleaning-data") )
{
   # Assume the working directory is RStudio project root
   setwd(paste(getwd(), "03-getting-and-cleaning-data", sep = "/"))
}

# Create the data folder if it does not already exists
if ( !dir.exists("data") )
{
   dir.create("data")
}

# ----------------------------------------------------------------- Dependences

# Nice print of file paths tree
library("data.tree")

# Join the club
library("tidyverse")

# --------------------------------------------------------------- Retrieve data

# Download the data if it does not already exists
zip_file_path <- paste("data", "samsung-sensors-data.zip", sep = "/")
if ( !file.exists(zip_file_path) )
{
   download.file(url      = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                 destfile = zip_file_path,
                 method   = "curl")
}

# Get the list of files compressed into the zip
zip_files <- unzip(zip_file_path, list = T)$Name
zip_tree <- data.tree::as.Node(data.frame(pathString = zip_files))
zip_tree

# Utility function to load a table from a file compressed into the downloaded
# zip
load_zipped_table <- function(file_name, extract_in = "data") {
   # Identify only the file of interest
   file_in_zip <- grep(pattern = paste0("(^|.*/)", file_name),
                       value   = T,
                       zip_files)
   unzipped_file_path <- file.path(extract_in, file_in_zip)

   # Do not extract the file if it has already been decompressed
   if( ! file.exists(unzipped_file_path) )
   {
      unzip(zip_file_path,
            files = c(file_in_zip),
            exdir = extract_in)
   }
   # Load the table and return it as tibble
   as_tibble(read.table(unzipped_file_path))
}

# -------------------------------------------------------------------- 1. Merge
# Merges the training and the test sets to create one data set.

# Load relevant tables
tbl_test <- load_zipped_table("X_test.txt")
tbl_train <- load_zipped_table("X_train.txt")
tbl_test_activity <- load_zipped_table("y_test.txt")
tbl_train_activity <- load_zipped_table("y_train.txt")
tbl_test_subject <- load_zipped_table("subject_test.txt")
tbl_train_subject <- load_zipped_table("subject_train.txt")

# Basic checks before going on
if ( (ncol(tbl_test) != ncol(tbl_train))
     | (nrow(tbl_test_activity) != nrow(tbl_test))
     | (nrow(tbl_train_activity) != nrow(tbl_train))
     | (nrow(tbl_test_subject) != nrow(tbl_test))
     | (nrow(tbl_train_subject) != nrow(tbl_train)) ) {
   stop("Something with the loaded tables is wrong")
}

# Merge separately the train and test tables to the corresponding activity and
# subject ones
tbl_test <- tbl_test %>%
   add_column(activity = deframe(tbl_test_activity)) %>%
   add_column(subject  = deframe(tbl_test_subject))
tbl_train <- tbl_train %>%
   add_column(activity = deframe(tbl_train_activity)) %>%
   add_column(subject  = deframe(tbl_train_subject))

# Merge the tables into a single one
tbl_merged <- bind_rows(tbl_test, tbl_train)

# ------------------------------------------------------------------ 2. Extract
# 2. Extracts only the measurements on the mean and standard deviation for each
#    measurement.

# Load relevant tables
tbl_variables <- load_zipped_table("features.txt")
lst_variables <- tbl_variables[[ncol(tbl_variables)]]

# Basic checks before going on
if ( length(lst_variables) != ncol(tbl_merged) - 2 ) {
   stop("Something with the loaded tables is wrong")
}

# Identify the columns of interest and the corresponding names, i.e. those
# corresponding to "mean()" and "std()" computations
sel_columns <- grepl(".*(mean|std)\\(\\).*",
                     lst_variables)

# Select the columns of interest (consider also the added activity and subject
# columns at the end)
tbl_merged <- tbl_merged[c(sel_columns, T, T)]

# --------------------------------------------------------------- 3. Activities
# Uses descriptive activity names to name the activities in the data set

# Load relevant tables
tbl_activity_map <- load_zipped_table("activity_labels.txt")

# Basic checks before going on
if ( !all(tbl_merged[["activity"]][[1]] %in% tbl_activity_map[[1]] ) ) {
   stop("Something with the loaded tables is wrong")
}

# Convert the activities column to labels
tbl_merged$activity <- tbl_activity_map[tbl_merged$activity, ][[2]]

# ----------------------------------------------------------- 4. Variable names
# Appropriately labels the data set with descriptive variable names.

# Identify how the columns shall be renamed (in table tbl_merged consider also
# the presence of the )
new_names <- lst_variables[sel_columns]
old_names <- names(tbl_merged)[1:(ncol(tbl_merged) - 2)]

# Try to apply some tidy principles
tbl_tidy_1 <- tbl_merged %>%

   # Rename and select the columns of interest
   rename_with(~ new_names, all_of(old_names)) %>%

   # Create a time column (windows of 2.56 sec and 50% overlap) so that in
   # following pivot operations data from different events is not mixed
   add_column(time    = seq(from = 2.56,
                           by   = 2.56/2,
                           length.out = nrow(tbl_merged)),
              .before = 1) %>%

   # Some variables are magnitudes (e.g. not associated with a specific axis).
   # Modify their name to match the pattern of the following 'pivot_longer'
   # operation (i.e. remove Mag from the name and add -MAG at the end)
   rename_with(~ paste0(sub("Mag-", "-", .x), "-MAG"),
               ends_with("()")) %>%

   # Separate the applied statistic functions and axis information
   pivot_longer(cols          = -c(time, activity, subject),
                names_to      = c("domain", "component", "sensor", "statistic", "axis"),
                values_to     = "value",
                names_pattern = "(.)([A-Z][a-z]*)(.*)-(.*)\\(\\)-(.*)") %>%

   # Convert to factor the columns with qualitative information
   mutate(activity  = factor(activity),
          subject   = factor(subject),
          component = factor(component),
          sensor    = factor(sensor),
          axis      = factor(axis),
          domain    = factor(domain,
                            labels = c("TIME", "FREQUENCY"),
                            levels = c("t", "f"))) %>%

   # Widen the table by axis
   pivot_wider(names_from   = statistic,
               values_from  = value)

# Let's export what we obtained
write.table(tbl_tidy_1,
            file = file.path("data", "tbl_tidy_1.txt"),
            row.names = F)

# Now we can plot some graphs
tbl_tidy_1 %>%
   # Select a subject and only the time analyses
   filter(subject   == 2,
          domain    == "TIME",
          component == "Body",
          sensor    == "Acc",
          axis      == "MAG") %>%
   # Convert the activity to a number in order to plot it
   with(plot(time, mean,
             type = "o",
             main = "Accelerometer signal over time",
             ylab = "Normalised accelleration magnitude [-1,1]",
             xlab = "Time [s]",
             col  = activity,
             pch  = 16))  %>%
   with(grid()) %>%
   with(legend("topleft",
               legend = unique(tbl_tidy_1$activity),
               pch    = 16,
               col    = unique(tbl_tidy_1$activity)))

# ----------------------------------------------------------- 5. Second dataset
# From the data set in step 4, creates a second, independent tidy data set with
# the average of each variable for each activity and each subject.

tbl_tidy_2 <- tbl_tidy_1 %>%

   # Remove the time column artificially added
   select(-time) %>%

   # The data is placed in the columns denoted by "mean" and "std", hence group
   # the table by the other columns
   group_by(across(-matches("mean|std"))) %>%

   # Draw the requested statistics observing that the only numerical columns
   # corresponds to the values (other columns previously converted to factor)
   summarise(across(where(is.numeric),
                    ~ mean(.x,
                           na.rm = T)))

# Let's export what we obtained
write.table(tbl_tidy_2,
            file = file.path("data", "tbl_tidy_2.txt"),
            row.names = F)

