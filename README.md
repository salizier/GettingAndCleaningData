# About run_statistic.R
## Usage / Input / Output

**NB** : I'm french and my english skills are not very good. 
So i'm sorry if i'm not very clear in this document.

### How to use

All functions are includes in only one file in order to make evaluation by peers easier.
To assign the result of the script, use this code. 

    source("run_analysis.R")
    result <- mainFunction()

The main function is called MainFunction().
This function schedule all subfunctions in order to constuct tidy Data.

### Return

This function return an object which contains the two dataSets

    result$getFullData() # return the dataset of step 4 
    result$getMeanData() # return the dataset of step 5 

### Generate File
@TODO

#### Pre-condition

the Samsung data must be in the working directory, it could be

* a zip file called **getdata-projectfiles-UCI HAR Dataset.zip**
* contains in a directory called **UCI HAR Dataset**

If one of this two conditions is not met, the script exit in error.

#### Parameters
The main function accept one parameter : an integer with limit.
This integer will limit the numbers of importing lines in "train" and "test" data files.

    # takes 400 first lines from "test" files and 400 first lines from "train" files.
    result <- mainFunction(400) 

It's not ask in the project, but it's easier to code with less lines, indeed, working with thousands of lines takes too much time.
I prefered include this limit in order to work with small sets. 
If this parameter is null, the script will take all the lines in all files.

### How it works

This section gives explanations for each functions in the script.

#### The main function 
This one has been explain in previous.
It launches all functions in order to complete the project and give the result in object bothObject
    
    mainFunction <- function(limit = NULL)
    
The first one is a call of checkIncomeFiles(). 
If this last one  return false, the main function launch an error

* * *

#### Step 0 : check if files exists in the working directory

    if(checkIncomeFiles()){
      ...
    }else{
      stop("No data found")
    }
    
***Description*** :  This function checks if files are available in order to construct the TidyData. 
If the folder "UCI HAR Dataset" is not present, it try to unzip "getdata-projectfiles-UCI HAR Dataset.zip".

***Parameters*** : NA

***Return*** : boolean true if there is a correct folder and false if it's impossible to find data.

* * *


#### Step 1 : Merge dataSet from "train" and "test"" files

    fullData <- assembleBothDataSet(limit)

**Description** : This function uses two sub-Functions *assembleDataSet* in order to construct two dataFrame from files and merge in a single data frame with the R native function *merge* on all columns

**parameters** :

* The limit of number lines we want for both *main* and *test* data

**Return** : A dataFrame *fullData* which contain all datas from both *train* and test* files.

* * *

    assembleDataSet(currentDirectory, limit)

**Description** : This function will read all files in *train* or *test* directory

* read *subject* Data in file "subject_<currentDirectory>.txt" and add it in a dataFrame on column subject
* read *category* Data in file "Y_<currentDirectory>.txt" and add it in a dataFrame on column *category*
* read Data in file "subject_<currentDirectory>.txt" and add it in a dataFrame on column subject
* read data in "features.txt" to assign colnames to the x directory. I think it's easier to work with label.
* the main data with measure are "X_<currentDirectory>.txt". Each coloumns correspond to the data found in the file features.txt

**parameters** :
* CurrentDirectory :  a string "test" or "main" 
* Limit :  The limit of number lines we want in each folder *main* and *test* data

**Return** : A dataSet with data from one directory (main or test depends on the currentDirectory parameter)
    
* * *
#### Step 2 : Extracts only the measurements on the mean and standard deviation for each measurement. 

    filterColNameOnSdtMean(colnames(fullData))
    
**Description** : Use regex in order to find column *mean* and *Std*. I choose to keep only data with *mean()* and *std()* at the end. 
I consider all other columns as differents measures.

**parameters** : the colomn name of the fulldata from previous function

**Return** : return a boolean vector. This vector contains true for columns i want to keep and false for others

* * *
  
    filterColumns(fullData,filterdColNames)

**Description** : Filter columns and keep only the true value of the logical vector *filterdColNames*

**parameters** : 

* fullData : the dataSet extract from *test* and *train* directory in step 1
* filterdColNames : the logical vector found in previous function

**Return** : the filter DataSet with only data i want to keep (mean, std, subject and catagory)

* * *

#### Step 3 : Uses descriptive activity names to name the activities in the data set 

    addCategoryLabel(FilterData)
    
**Description** : Open file *activity_labels.txt* and assign it to a dataFrame.
Merge this dataFrame with the input data frame containing all other data.

**parameters** : the filter DataFrame from other function.

**Return** : return data frame with correct label for catagories.
    
* * *

#### Step 4 : Appropriately labels the data set with descriptive variable names.
    
    finalData <- renameColumns(finalData)

**Description** : use function *sub* in order to rename all columns of the input Dataframe.
Each informations of a column is separated with underscore.
honestly, I don't understand the meaning of each variable, but it seems better in this form.
This method give in my opinion clear name like : 

* freqence_Body_Gyro_Mean_X
* freqence_Body_Gyro_StandardDeviation_Z
* time_Body_Acc_Jerk_Mean_X

**parameters** : the data with data exctracted from previous functions

**Return** : return final data for step 4. This dataSet will be assign to the result object with the function *setFullData

    
* * *



#### Step 5 : From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

    makeMeans(finalData)
    
**Description** : Use the R function *aggregate* in order to obtain mean for each couple (category, subject)

**parameters** : the final dataFrame from step 4

**Return** : the final data frame for step 5 

* * *
###  Zoom on return object *BothData*

This function is used to keep and return the two dataSet for the course project
    
    bothResult <- function()
    
This lines initialise the object.
    
* * * 
    setFullData <- function(data)
    setMeanData <- function(data)
    
These two lines bind objects in variables.

* * * 
    getFullData <- function()
    getMeanData <-function()

These two functions are used by users to obtain the two dataSet