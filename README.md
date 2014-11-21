#Tidy Data Project

To generate the tidy data set, *source("run_analysis.R")* from an R console or RStudio.

**NOTE:** this script uses the *dplyr* and *reshape2* packages. Those should be installed if necessary beforehand.

##explanation of the **run_analysis.R** script

The *run_analysis.R* script executes the following steps:

1. downloads and unzips the source data files if not already present in the working directory (if the "UCI HAR Dataset" directory exists in the working directory as a result of unzipping the project data, it will work with that data)
2. reads those datasets into tables, including the test and training data, the list of corresponding subjects, the list of corresponding activities, and the feature names
3. merges the test and training datasets into single datasets, preserving order
4. sets the column names of the merged dataset according to the names provided in *features.txt*
5. filters the dataset to include only measurements on mean and standard deviation
6. cleans up names (removing parenthesis) and clarifies the time and frequency prefixes
7. converts numeric activity identifiers to meaningful names
8. binds the corresponding activity values as a column to the dataset
9. binds the corresponding subject values as a column to the dataset
10. uses *melt* (from the *reshape2* library) to create a new dataset with averages for each variable per combined subject + activity
11. creates a long form tidy data set and decomposes the variable names into: unit, device, signal, measure, and axis columns
12. ensures that each column uses *factors* except for the "average" value itself
13. reorders the columns so that the average value is at the end, and also drops the variable column now that it has been decomposed
14. writes the result to the current directory as a table including header names with the filename: *tidy.txt*

For more detail, refer to [run_analysis.R](run_analysis.R) itself as it is well-commented.

##background and motivations

As described in the [CodeBook](CodeBook.md), the original data contained multiple recorded values per measurement type per subject and activity. It also was available as 2 separate data sets: one for training and one for testing. Additionally, the measurement data did not include header names, but rather those were available in a separate *features.txt* file that has been used here to provide the names for each variable. Likewise, the subjects and activity types for each recorded value were available in separate files. Those needed to be bound as new columns, after those files were also combined from their training and test source data files. The order of those rows needed to be preserved so that they lined up correctly with the measurement data. 

Another goal for the tidy data was to filter to measurement types that included corresponding *mean* and *std* values. That disinction has been made here based on the presence of '-mean' or '-std' in the feature name. The resulting set of features to be included was thus reduced from 561 to 66.

Finally, the dimensions of the data were reduced so that here a single row corresponds to an average of those recorded mean and standard deviation values per measurement type for a given subject/activity pair.

The resulting tidy data is in long form. That means there is one row per combination of subject, activity, and measurement. The table has 11,880 rows since there are 30 subjects, 6 activities, and 66 types of measurement (30 * 6 * 66 = 11,880). The final column is "average", and that includes the average value for all measurements of that type for the subject participating in the activity.

##long-form vs. wide-form

The script actually includes commented-out code that could be used to generate wide-form data, where the table would have only 180 rows (one per subject and activity, thus 30 * 6), but each row would have 68 columns: subject, activity, and one for each of the average values of the 66 measurement types. I decided to leave that *commented out* code as a reference and in case there were any specific use-cases where a wide-form data set would be better suited.

However, I chose the long-form data set as the result for this project since most of the references I have read regarding tidy data emphasize the flexibility of long-form data, e.g. for plotting and summarizing. Furthermore, it allowed me to break down the signal name into its constituent parts, which I felt led to a better description in the [CodeBook](CodeBook.md).

##CodeBook

Please refer to the [CodeBook](CodeBook.md) for more information about the source data, the transformations applied to variables, and the descriptions of the resulting dataset variables.
