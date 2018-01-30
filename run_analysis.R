## Setting the working directory to download the data 
setwd("/Users/admin/Documents/R/Data Science Specialization JHU/03 Getting and Cleaning Data/Week 4")

## Downloading the data
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

## Unzip DataSet to "/data" directory
unzip(zipfile="./data/Dataset.zip",exdir="./data")

## Working with the "UCI HAR Dataset" folder
filesPath <- "/Users/admin/Documents/R/Data Science Specialization JHU/03 Getting and Cleaning Data/Week 4/data/UCI HAR Dataset"
## Load required packages
library(dplyr)
library(data.table)
library(plyr)
library(tidyr)

## Read data from the files into the variables
## Read Activity files
dataActivityTest  <- read.table(file.path(filesPath, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(filesPath, "train", "Y_train.txt"),header = FALSE)
## Read Subject files
dataSubjectTrain <- read.table(file.path(filesPath, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(filesPath, "test" , "subject_test.txt"),header = FALSE)
## Read Features files.
dataFeaturesTest  <- read.table(file.path(filesPath, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(filesPath, "train", "X_train.txt"),header = FALSE)

### 1. Merges the training and the test sets to create one data set.
## Merge the training and test Data Tables by rows using "rbind"
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)
## Renaming the variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(filesPath, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2
## Merge columns (with cbind) to get the data frame "FinalData" for ALL data
dataSub_Act <- cbind(dataSubject, dataActivity)
FinalData <- cbind(dataFeatures, dataSub_Act)

### 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## Create a Subset of the Features Names by measurements on the mean "mean()" and standard deviation "std()"
subset_dataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
## Subset the data frame "FinalData" by the subset of selected names of Features
selectedNames<-c(as.character(subset_dataFeaturesNames), "subject", "activity" )
Data<-subset(FinalData,select=selectedNames)

### 3. Uses descriptive activity names to name the activities in the data set.
## Read descriptive activity names from "activity_labels.txt"
activityLabels <- read.table(file.path(filesPath, "activity_labels.txt"),header = FALSE)
## Create a new column "activity2" with the descriptive activity names depending on the activity numbers contained in the column "activity"
index <- c(as.character(activityLabels$V1))
values <- c(as.character(activityLabels$V2))
Data$activity2 <- values[match(Data$activity, index)]
## Delete the "activity" column in Data
Data$activity <- NULL
## Rename the "activity2" column to "activity"
colnames(Data)[68] = "activity"

### 4. Appropriately labels the data set with descriptive variable names.
## prefix t is replaced by time
names(Data)<-gsub("^t", "time", names(Data))
## Acc is replaced by Accelerometer
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
## Gyro is replaced by Gyroscope
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
## prefix f is replaced by frequency
names(Data)<-gsub("^f", "frequency", names(Data))
## Mag is replaced by Magnitude
names(Data)<-gsub("Mag", "Magnitude", names(Data))
## BodyBody is replaced by Body
names(Data)<-gsub("BodyBody", "Body", names(Data))

### 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)

## We are done!!








