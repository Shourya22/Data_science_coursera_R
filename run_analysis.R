#Preparing the workspace (install packages if not present)
	rm(list=ls())
	library(dplyr)
	library(data.table)

#Extract the data files collected from the accelerometers 

#Retrieve Train data
	xtrain=read.table("UCI HAR Dataset/train/X_train.txt")
	ytrain=read.table("UCI HAR Dataset/train/Y_train.txt")
	subject_train=read.table("UCI HAR Dataset/train/subject_train.txt")

#Retrieve Test data
	xtest=read.table("UCI HAR Dataset/test/X_test.txt")
	ytest=read.table("UCI HAR Dataset/test/Y_test.txt")
	subject_test=read.table("UCI HAR Dataset/test/subject_test.txt")

#Read the features file
	features=read.table("UCI HAR Dataset/features.txt")

#Read the activity label file
	activity_label=read.table("UCI HAR Dataset/activity_labels.txt")

#Merge the training and test datasets
	merged=rbind(xtrain,xtest)

#Get the column names for the train and test data
	colnames(merged)=features[,2]

#Extract only measurements for mean and std for each measurement

#Search for columns having 'mean' or 'std' and retrieve the index
	reqcol=grep(".*mean.*|.*std.*",colnames(merged))

#retrieve the column names for the corresponding index from the 'combined' data frame
	reqcolnames=colnames(merged[reqcol])
#remove "()" from column name
	reqcolnames <- gsub('[()]', '',reqcolnames)

#extract and build a dataframe with column data having 'mean' and 'std'
	i=1
	meanstddata <- data.frame(merged[,reqcol[i]])
	for (i in 2:length(reqcol))
	{
	  meanstddata <- cbind(meanstddata,data.frame(merged[,reqcol[i]]))
	} 
	colnames(meanstddata) <- reqcolnames


#combine activity and subject information to the measurement dataset

#Get the column names for activity label,activity id and subject id
	colnames(activity_label)=c("activityid", "activitylabel")
	colnames(ytrain)=c("activityid")
	colnames(ytest)=c("activityid")
	colnames(subject_train)=c("subjectid")
	colnames(subject_test)=c("subjectid")

#1. Merge activity label and activity id dataframe by activity id.
#2. concatenate columns from dataframe created in 1 with subject dataframe 
#3. concatenate columns from 2 with 'combined. dataframe

	datafinal <- merge(activity_label,rbind(ytrain,ytest), by.x = "activityid") %>%
	  cbind(rbind(subject_train,subject_test)) %>%
	  cbind(meanstddata)

# Aggregate of each measurement by activity and subject id
	final=data.table(datafinal)
	aggregate.data=final[,lapply(.SD,mean), by = c("activityid","activitylabel","subjectid")]

#Write data to a text file
	write.table(aggregate.data, "tidydata.txt",row.name=FALSE)
