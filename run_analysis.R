mainDirectory = "UCI HAR Dataset"
testDirectory = "test"
trainDirectory = "train"
zipFile = "getdata-projectfiles-UCI HAR Dataset.zip"

mainFunction <- function(limit = NULL){
  if(checkIncomeFiles()){
      result <- bothResult()
      
      message("assemble and merge Data")
      fullData <- assembleBothDataSet(limit)
      message(class(fullData))
      

      message("Fileter on mean and std columns")
      filterdColNames <- filterColNameOnSdtMean(colnames(fullData))
      filterData <- filterColumns(fullData,filterdColNames)

      message("Add category labels")
      finalData <- addCategoryLabel(filterData)
      
      message("change columns name")
      finalData <- renameColumns(finalData)
      result$setFullData(finalData)

      message("calculateMeansData")
      meanData <- makeMeans(finalData)
      result$setMeanData(meanData)
      return(result)
  }else{
    stop("No data found")
  }
}



bothResult <- function(){
  fullData <- NULL
  meanData <- NULL
  
  setFullData <- function(data){
    fullData <<- data
  }
  
  setMeanData <- function(data){
    meanData <<- data
  }
  
  getFullData <- function(){
    return(fullData)
  }
  
  getMeanData <-function(){
    return(meanData)
  }
  
  return(list(setFullData = setFullData,
              setMeanData = setMeanData,
              getFullData = getFullData,
              getMeanData = getMeanData))
  
}



#======================================================================
#======================================================================
# rename Columns
#======================================================================
#======================================================================
renameColumns <- function(data){
  colnames(data) <- sapply(colnames(data), unitaryRenameFunction)
  return(data)
}

unitaryRenameFunction <- function(name){
  name <- sub("^t", "time_", name)
  name <- sub("^f", "freqence_", name)
  name <- sub(".mean...", "_Mean_", name)
  name <- sub(".std...", "_StandardDeviation_", name)
  name <- sub(".mean..", "_Mean", name)
  name <- sub(".std..", "_StandardDeviation", name)
  name <- sub("BodyBody", "Body", name)
  name <- sub("Body", "Body_", name)
  name <- sub("Gravity", "Gravity_", name)
  name <- sub("Jerk", "_Jerk", name)
  name <- sub("AccMag", "Acc_Mag", name)
  name <- sub("GyroMag", "Gyro_Mag", name)
  
  return(name)
}

#======================================================================
#======================================================================
# change categorie label
#======================================================================
#======================================================================
addCategoryLabel <- function(data){
  categoryLabel <- read.csv("UCI HAR Dataset/activity_labels.txt",sep=" ",head = FALSE)
  colnames(categoryLabel) <- c("category", "categoryLabel")
  merged <- merge(categoryLabel,data, by =  "category")
  #delete old Colum category
  return(merged[,colnames(merged) != "category"])
}


#======================================================================
#======================================================================
# filter data columns
#======================================================================
#======================================================================

##
# Use regex in order to keep only mean and Std
# exlude meanFreq
##
filterColNameOnSdtMean <- function(colNames){
  include <- grepl("(mean)|(std)|(subject)|(category)|(type)",colNames)
  exclude <- grepl("(meanFreq)",colNames)
  finalFilter = include - exclude == 1
  return(colNames[ finalFilter ])
}


##
# Filter data.table on pertinant columns
##
filterColumns <- function(data,colNames){
  return(data[,colNames])
}


makeMeans <- function(data){
  colNames <- colnames(data)
  meansColumns <- colNames[! colNames %in% c("subject","categoryLabel") ]
  aggregate(data[,meansColumns], list(subject = data$subject,categoryLabel = data$categoryLabel), mean)
}

#======================================================================
#======================================================================
# assemble dataSet
#======================================================================
#======================================================================
assembleDataSet <- function(currentDirectory, limit = NULL){
  message(currentDirectory)
  
  directory <- paste(mainDirectory,currentDirectory,"", sep = "/", collapse = NULL)
  
  # Load subject Data and count number of lines
  subjectFile <- paste(directory, "subject_",currentDirectory,".txt", sep = "", collapse = NULL)
  subjectData <- read.csv(subjectFile, sep = " ", header = FALSE)
  message("subject")
  if(is.null(limit)){
    limit <- length(subjectData[,1])  
  }
  message(limit)
  
  # Load category Data and count number of lines
  categoryFile <- paste(directory, "Y_",currentDirectory,".txt", sep = "", collapse = NULL)
  message(categoryFile)
  categoryData <- read.csv(categoryFile, sep = " ", header = FALSE)

   colnames(categoryData) <- "id"

  message(length(categoryData[,1]))
  
  categoryData
  #search title Columns Names
  featuresFile <- paste(mainDirectory,"features.txt", sep = "/", collapse = NULL)
  features <- read.csv(featuresFile, sep = " ", header = FALSE)
  message("column Title")
  
  # Load main data into a data.TABLE
  mainData <- paste(directory, "X_",currentDirectory,".txt", sep = "", collapse = NULL)
  delimitedVector <- c(17,c(rep(16, 560)))
  dataTable <- read.fwf(mainData,widths = delimitedVector,buffersize = 300,col.names = features[,2], n = limit)
  message("load Main")
  message(length(dataTable[,1]))

  
  #add Other Data
  dataTable$subject <- subjectData[1:limit,1]
  dataTable$category <- categoryData[1:limit,1]
  class(dataTable)
  return(dataTable)
  
}

assembleBothDataSet <- function(limit = NULL){
  test <- assembleDataSet(testDirectory, limit)
  train <- assembleDataSet(trainDirectory, limit)
  merge = merge(test, train, all = TRUE, by = intersect(names(test), names(train)))
  return(merge)
}

#======================================================================
#======================================================================
#
# check incoming file
#
#======================================================================
#======================================================================

##
# Check if folder "UCI HAR Dataset exists"
# return TRUE if exists
# try to unzip if not exists
##
checkIncomeFiles <- function(){
  if(file.exists(mainDirectory)){
    return(TRUE)
  }else{
    message("File \"UCI HAR Dataset\" not found")
    return(unzipIfnecessary())
  }
}

##
# check if the zip with data exists and unzip if exists
# return False if not exists
##
unzipIfnecessary <- function(){
  fileName = zipFile
  if(file.exists(fileName)){
    unzip(fileName)
    return(TRUE)
  }else{
    message("Zip File \"getdata-projectfiles-UCI HAR Dataset.zip\" not found")
    return(FALSE)
  }
}
