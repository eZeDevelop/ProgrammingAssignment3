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

# Create the data folder if it does not already exists
if ( !dir.exists("data") )
{
   dir.create("data")
}

# ----------------------------------------------------------------- Dependences

# Document and create reports on data cleanliness.
library("dataReporter")

# Convert the dataReporter .rmd report in .md
library("knitr")

# Nice print of file paths tree
library("data.tree")

# Join the club
library("tidyverse")

# ----------------------------------------------------------- Utility functions

# Load a table from a file compressed into the downloaded zip
load_zipped_table <- function(file_name, extract_in = "data") {
   
   # Identify only the file of interest
   file_in_zip <- grep(pattern = paste0("(^|.*/)", file_name),
                       value   = T,
                       zip_files)
   unzipped_file_path <- file.path(extract_in, file_in_zip)
   
   # Do not extract the file if it has already been decompressed
   if ( !file.exists(unzipped_file_path) )
   {
      unzip(zip_file_path,
            files = c(file_in_zip),
            exdir = extract_in)
   }
   
   # Load the table and return it as tibble
   as_tibble(read.table(unzipped_file_path))
}

# Save the table as in txt file
save_to_txt <- function(table_data, base_path = "data") {
   
   # Rename the input table to its original name
   table_name <- deparse(substitute(table_data))
   code <- paste0(table_name, " <- table_data")
   eval(parse(text = code))
   
   # Generate file paths
   txt_file_name <- "table.txt"
   txt_file_path <- file.path(base_path, table_name, txt_file_name)

   # Create the folder if it does not already exists
   if ( !dir.exists(file.path(base_path, table_name)) )
   {
      dir.create(file.path(base_path, table_name))
   }
   
   # Let's export what we obtained
   write.table(eval(parse(text = table_name)),
               file = txt_file_path,
               row.names = F)
}

# Generate the CodeBook report
make_codebook <- function(table_data, base_path = "data") {
   
   # Rename the input table to its original name
   table_name <- deparse(substitute(table_data))
   code <- paste0(table_name, " <- table_data")
   eval(parse(text = code))
   
   # Generate file paths
   rmd_file_name <- "CodeBook.rmd"
   rmd_file_path <- file.path(base_path, table_name, rmd_file_name)
   md_file_path <- sub("rmd", "md", rmd_file_path)
   
   # Create the folder if it does not already exists
   if ( !dir.exists(file.path(base_path, table_name)) )
   {
      dir.create(file.path(base_path, table_name))
   }
   
   # Auto-generated report in rmd format
   makeDataReport(data        = eval(parse(text = table_name)),
                  file        = rmd_file_path,
                  mode        = c("summarize", "visualize", "check"),
                  reportTitle = table_name,
                  codebook    = T, 
                  smartNum    = F,
                  replace     = T,
                  openResult  = F,
                  render      = F)
   
   # Convert the rmd file in md
   opts_knit$set(base.dir   = file.path(base_path, table_name))
   opts_knit$set(out.format = "github_document")
   knit(input  = rmd_file_path,
        output = md_file_path)
   
   # Clean-up removing not needed files
   file.remove(rmd_file_path)
   
   # Nothing to return
   invisible(T)
}

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

# Save the data
save_to_txt(tbl_tidy_1)

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
   summarise(across(matches("mean|std"),
                    ~ mean(.x,
                           na.rm = T))) %>%
   
   # Since the "mean" and "std" columns result from applying a further "mean"
   # operation over time, rename the corresponding columns
   rename(mean.mean = mean,
          std.mean  = std)


# Save the data
save_to_txt(tbl_tidy_2)

# -------------------------------------------------------------------- CodeBook

# Give some information on the data
attr(tbl_tidy_1$time, "label") <- "Timestamp of last window sample"
attr(tbl_tidy_1$time, "shortDescription") <- paste0(
   "The 'time' column provides the riconstructed information about ",
   "the time the variable is computed. This information is only ",
   "indirectly available in the original data set, where time domain ",
   "signals were captured at a constant rate of 50 Hz (20 ms period) ",
   "and sampled in fixed-width sliding windows of 2.56 sec and 50% ",
   "overlap (128 readings/window)."
)
attr(tbl_tidy_1$activity, "label") <- "Activity performed by the person"
attr(tbl_tidy_1$activity, "shortDescription") <- paste0(
   "Each person performed six activities (WALKING, WALKING_UPSTAIRS, ",
   "WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING). The experiments ",
   "have been video-recorded to label the data manually."
)
attr(tbl_tidy_1$subject, "label") <- "Person performing the activity"
attr(tbl_tidy_1$subject, "shortDescription") <- paste0(
   "A group of 30 volunteers within an age bracket of 19-48 years ",
   "carried out the experiments."
)
attr(tbl_tidy_1$domain, "label") <- "Physical domain of the variable"
attr(tbl_tidy_1$domain, "shortDescription ") <- paste0(
   "From each window, a vector of features was obtained by calculating ",
   "variables either from the time or frequency domain."
)
attr(tbl_tidy_1$component, "label") <- "Physical domain of the variable"
attr(tbl_tidy_1$component, "shortDescription") <- paste0(
   "The sensor acceleration signals have gravitational and body motion ",
   "components, separated using a Butterworth low-pass filter into body ",
   "acceleration and gravity. The gravitational force is assumed to have ",
   "only low frequency components, therefore a filter with 0.3 Hz cutoff ",
   "frequency was used. Gyroscope signals have only body motion component."
)
attr(tbl_tidy_1$sensor, "label") <- "Embedded accelerometer or gyroscope"
attr(tbl_tidy_1$sensor, "shortDescription") <- paste0(
   "Linear acceleration and angular velocity are captured using  a ",
   "smartphone's embedded accelerometer and gyroscope sensors. The body ",
   "linear acceleration and angular velocity were derived in time to ",
   "obtain Jerk signals."
)
attr(tbl_tidy_1$axis, "label") <- "3-axial signals"
attr(tbl_tidy_1$axis, "shortDescription") <- paste0(
   "3-axial linear acceleration and 3-axial angular velocity are captured. ",
   "Also the magnitude of these three-dimensional signals were calculated ",
   "using the Euclidean norm."
)
attr(tbl_tidy_1$mean, "label") <- "Mean value"
attr(tbl_tidy_1$mean, "shortDescription") <- paste0(
   "Mean value normalized and bounded within [-1,1], estimated from the ",
   "3-axial linear acceleration and 3-axial angular velocity signals."
)
attr(tbl_tidy_1$std, "label") <- "Standard deviation"
attr(tbl_tidy_1$std, "shortDescription") <- paste0(
   "Standard deviation normalized and bounded within [-1,1], estimated ",
   "from the 3-axial linear acceleration and 3-axial angular velocity ",
   "signals."
)
attr(tbl_tidy_1$time, "label") <- "Timestamp of last window sample"
attr(tbl_tidy_1$time, "shortDescription") <- paste0(
   "The 'time' column provides the riconstructed information about ",
   "the time the variable is computed. This information is only ",
   "indirectly available in the original data set, where time domain ",
   "signals were captured at a constant rate of 50 Hz (20 ms period) ",
   "and sampled in fixed-width sliding windows of 2.56 sec and 50% ",
   "overlap (128 readings/window)."
)
attr(tbl_tidy_1$activity, "label") <- "Activity performed by the person"
attr(tbl_tidy_1$activity, "shortDescription") <- paste0(
   "Each person performed six activities (WALKING, WALKING_UPSTAIRS, ",
   "WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING). The experiments ",
   "have been video-recorded to label the data manually."
)
attr(tbl_tidy_1$subject, "label") <- "Person performing the activity"
attr(tbl_tidy_1$subject, "shortDescription") <- paste0(
   "A group of 30 volunteers within an age bracket of 19-48 years ",
   "carried out the experiments."
)
attr(tbl_tidy_1$domain, "label") <- "Physical domain of the variable"
attr(tbl_tidy_1$domain, "shortDescription") <- paste0(
   "From each window, a vector of features was obtained by calculating ",
   "variables either from the time or frequency domain."
)
attr(tbl_tidy_1$component, "label") <- "Physical domain of the variable"
attr(tbl_tidy_1$component, "shortDescription") <- paste0(
   "The sensor acceleration signals have gravitational and body motion ",
   "components, separated using a Butterworth low-pass filter into body ",
   "acceleration and gravity. The gravitational force is assumed to have ",
   "only low frequency components, therefore a filter with 0.3 Hz cutoff ",
   "frequency was used. Gyroscope signals have only body motion component."
)
attr(tbl_tidy_1$sensor, "label") <- "Embedded accelerometer or gyroscope"
attr(tbl_tidy_1$sensor, "shortDescription") <- paste0(
   "Linear acceleration and angular velocity are captured using  a ",
   "smartphone's embedded accelerometer and gyroscope sensors. The body ",
   "linear acceleration and angular velocity were derived in time to ",
   "obtain Jerk signals."
)
attr(tbl_tidy_1$axis, "label") <- "3-axial signals"
attr(tbl_tidy_1$axis, "shortDescription") <- paste0(
   "3-axial linear acceleration and 3-axial angular velocity are captured. ",
   "Also the magnitude of these three-dimensional signals were calculated ",
   "using the Euclidean norm."
)
attr(tbl_tidy_1$mean, "label") <- "Mean value"
attr(tbl_tidy_1$mean, "shortDescription") <- paste0(
   "Mean value normalized and bounded within [-1,1], estimated from the ",
   "3-axial linear acceleration and 3-axial angular velocity signals."
)
attr(tbl_tidy_1$std, "label") <- "Standard deviation"
attr(tbl_tidy_1$std, "shortDescription") <- paste0(
   "Standard deviation normalized and bounded within [-1,1], estimated ",
   "from the 3-axial linear acceleration and 3-axial angular velocity ",
   "signals."
)

attr(tbl_tidy_2$activity, "label") <- attr(tbl_tidy_1$activity, "label")
attr(tbl_tidy_2$activity, "shortDescription") <- 
   attr(tbl_tidy_1$activity, "shortDescription")
attr(tbl_tidy_2$subject, "label") <- attr(tbl_tidy_1$subject, "label")
attr(tbl_tidy_2$subject, "shortDescription") <- 
   attr(tbl_tidy_1$subject, "shortDescription")
attr(tbl_tidy_2$domain, "label") <- attr(tbl_tidy_1$domain, "label")
attr(tbl_tidy_2$domain, "shortDescription") <- 
   attr(tbl_tidy_1$domain, "shortDescription")
attr(tbl_tidy_2$component, "label") <- attr(tbl_tidy_1$component, "label")
attr(tbl_tidy_2$component, "shortDescription") <- 
   attr(tbl_tidy_1$component, "shortDescription")
attr(tbl_tidy_2$sensor, "label") <- attr(tbl_tidy_1$sensor, "label")
attr(tbl_tidy_2$sensor, "shortDescription") <- 
   attr(tbl_tidy_1$sensor, "shortDescription")
attr(tbl_tidy_2$axis, "label") <- attr(tbl_tidy_1$axis, "label")
attr(tbl_tidy_2$axis, "shortDescription") <- 
   attr(tbl_tidy_1$axis, "shortDescription")
attr(tbl_tidy_2$mean.mean, "label") <- "Mean of the data windows' mean over time"
attr(tbl_tidy_2$mean.mean, "shortDescription") <- 
   attr(tbl_tidy_1$mean, "shortDescription")
attr(tbl_tidy_2$std.mean, "label") <- "Mean of the data windows' std over time"
attr(tbl_tidy_2$std.mean, "shortDescription") <- 
   attr(tbl_tidy_1$std, "shortDescription")

# Generate reports
make_codebook(tbl_tidy_1)
make_codebook(tbl_tidy_2)

# ---------------------------------------------------------------- Example plot 

# Specify the image file the example plot will be saved to
plot_image_path <- file.path("data", "example_plot.png")
if (file.exists(plot_image_path)) {
   file.remove(plot_image_path)
}
png(filename = plot_image_path,
    width    = 1024,
    height   = 1024/(16/9))

# Now we can plot some graphs
tbl_tidy_1 %>%
   # Select a subject and only the time analyses
   filter(subject   == 2,
          domain    == "TIME",
          component == "Body",
          sensor    == "Acc",
          axis      == "MAG") %>%
   # Convert the activity to a number in order to plot it
   plot(mean ~ time,
        data = .,
        type = "o",
        main = "Accelerometer signal over time",
        ylab = "Normalised accelleration magnitude [-1,1]",
        xlab = "Time [s]",
        col  = activity,
        pch  = 16)
# Add grid to the plot
grid()
# Add legend to the plot
legend("topleft",
       legend = unique(tbl_tidy_1$activity),
       pch    = 16,
       col    = unique(tbl_tidy_1$activity))

# Save the plot
dev.off()
