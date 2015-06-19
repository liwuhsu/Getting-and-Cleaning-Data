#Use data.table and dplyr libraries
library(data.table)
library(dplyr)

#Read training data set
subjectTraining <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)
activityTraining <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE)
featuresTraining <- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)

#Read test data set
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)
activityTest <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE)
featuresTest <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)

#Merge the training and the test sets to create one data set
subject <- rbind(subjectTraining, subjectTest)
activity <- rbind(activityTraining, activityTest)
features <- rbind(featuresTraining, featuresTest)

#Naming variables
colnames(subject) <- "subject"
colnames(activity) <- "activity"
featuresLabel <- read.table("UCI HAR Dataset/features.txt")
colnames(features) <- t(featuresLabel[2])

#Merge to the complete data
completeData <- cbind(subject, activity, features)

#Extracts only the measurements on the mean and standard deviation for each measurement.
selectedColumns <- grep(".*mean.*|.*std.*|subject|activity", names(completeData), ignore.case=TRUE)
simplifiedData <- completeData[, selectedColumns]

#Uses descriptive activity names to name the activities in the data set
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)
activityNumber <- as.character(simplifiedData$activity)
for (i in 1:6){
        simplifiedData$activity[simplifiedData$activity == i] <- as.character(activityLabels[i,2])
}
simplifiedData$activity <- as.factor(simplifiedData$activity)

#Appropriately labels the data set with descriptive variable names.
names(simplifiedData)
names(simplifiedData)<-gsub("Acc", "Accelerometer", names(simplifiedData))
names(simplifiedData)<-gsub("Gyro", "Gyroscope", names(simplifiedData))
names(simplifiedData)<-gsub("BodyBody", "Body", names(simplifiedData))
names(simplifiedData)<-gsub("Mag", "Magnitude", names(simplifiedData))
names(simplifiedData)<-gsub("^t", "Time", names(simplifiedData))
names(simplifiedData)<-gsub("^f", "Frequency", names(simplifiedData))

#From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
simplifiedData$subject <- as.factor(simplifiedData$subject)
simplifiedData <- data.table(simplifiedData)
tidyData <- aggregate(. ~subject + activity, simplifiedData, mean)
write.table(tidyData, file = "UCI HAR Dataset/TidyData.txt", row.names = FALSE)

