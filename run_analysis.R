library(dplyr)
library(reshape2)

datadir = "UCI HAR Dataset"

## grab data if necessary and unzip
if (!file.exists(datadir)) {
    url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(url, destfile = "uci-har-dataset.zip", method = "curl")
    unzip("uci-har-dataset.zip")
}

## read tables
x_test <- read.table(paste(datadir, "test", "X_test.txt", sep="/"))
x_train <- read.table(paste(datadir, "train", "X_train.txt", sep="/"))
y_test <- read.table(paste(datadir, "test", "y_test.txt", sep="/"))
y_train <- read.table(paste(datadir, "train", "y_train.txt", sep="/"))
subject_test <- read.table(paste(datadir, "test", "subject_test.txt", sep="/"))
subject_train <- read.table(paste(datadir, "train", "subject_train.txt", sep="/"))
features <- read.table(paste(datadir, "features.txt", sep="/"))
activity_labels <- read.table(paste(datadir, "activity_labels.txt", sep="/"))

## merge test and training data
data <- rbind(x_test, x_train)

## merge corresponding activities and subjects tables
activities <- rbind(y_test, y_train)
subjects <- rbind(subject_test, subject_train)

## set column names as indicated in the features table
names(data) <- features$V2

## extract only the measurements on the mean and standard deviation
data <- subset(data, select = grepl("std\\(\\)|mean\\(\\)", names(data)))

## remove parens from names and spell out prefixes for clarity
names(data) <- sub("\\(\\)","",names(data))
names(data) <- sub("^t", "time", names(data))
names(data) <- sub("^f", "frequency", names(data))

## use descriptive activity names instead of numeric label
names(activities) <- c("activity")
activities$activity <- activity_labels$V2[activities$activity]

## bind subject and activity columns to the main data frame
names(subjects) <- c("subject")
data <- cbind(subjects, activities, data)

## create second tidy data set with averages for each measurement per subject+activity
melted <- melt(data, id.vars = c("subject", "activity"))
melted <- transform(melted, subject = factor(subject))

## wide form
## averages <- dcast(melted, subject + activity ~ variable, fun = mean, na.rm = TRUE)
## write.table(averages, file="tidy-wide.txt", row.name=FALSE)

## create a long form tidy data set
tidy <- summarize(group_by(melted, subject, activity, variable), mean(value))
names(tidy)[4] <- ("average")

## decompose the variable into constituent parts, all of which can be factors
tidy$unit <- factor(sub("^(time|frequency).*", "\\1", tidy$variable))
tidy$device <- sub(".*(Acc|Gyro).*", "\\1", tidy$variable)
tidy$device <- sub("Acc", "accelerometer", tidy$device)
tidy$device <- sub("Gyro", "gyroscope", tidy$device)
tidy$signal <- factor(sub("^(time|frequency)(.*)(Acc|Gyro)(.*?)-.*$", "\\2\\4", tidy$variable))
tidy$measure <- factor(sub(".*-(mean|std).*", "\\1", tidy$variable))
tidy$axis <- sub(".*-([XYZ])$", "\\1", tidy$variable)
tidy$axis <- sub("^(time|frequency).*$", NA, tidy$axis)
tidy <- transform(tidy, device = factor(device))
tidy <- transform(tidy, axis = factor(axis))

## move 'average' to end and drop 'variable' now that it has been decomposed
tidy <- tidy[,c(1,2,5,6,7,8,9,4)]

write.table(tidy, file="tidy.txt", row.name=FALSE)
