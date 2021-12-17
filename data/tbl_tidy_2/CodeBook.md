---
dataReporter: yes
title: tbl_tidy_2
subtitle: "Autogenerated data summary from dataReporter"
date: 2021-12-17 16:01:28
output: html_document
---




# Data report overview
The dataset examined has the following dimensions:


---------------------------------
Feature                    Result
------------------------ --------
Number of observations       5940

Number of variables             8
---------------------------------




### Checks performed
The following variable checks were performed, depending on the data type of each variable:

-----------------------------------------------------------------------------------------------------------------------------------------------
&nbsp;                                                 character   factor    labelled   haven labelled   numeric   integer   logical    Date   
----------------------------------------------------- ----------- --------- ---------- ---------------- --------- --------- --------- ---------
Identify miscoded missing values                        &times;    &times;   &times;       &times;       &times;   &times;             &times; 

Identify prefixed and suffixed whitespace               &times;    &times;   &times;       &times;                                             

Identify levels with < 6 obs.                           &times;    &times;   &times;       &times;                                             

Identify case issues                                    &times;    &times;   &times;       &times;                                             

Identify misclassified numeric or integer variables     &times;    &times;   &times;       &times;                                             

Identify outliers                                                                                        &times;   &times;             &times; 
-----------------------------------------------------------------------------------------------------------------------------------------------




Please note that all numerical values in the following have been rounded to 2 decimals.


# Codebook summary table

------------------------------------------------------------------------------------------------------
Label           Variable          Class       # unique  Missing  Description                          
                                                values                                                
--------------- ----------------- --------- ---------- --------- -------------------------------------
Activity        **[activity]**    factor             6  0.00 %   Each person performed six            
performed by                                                     activities (WALKING,                 
the person                                                       WALKING_UPSTAIRS,                    
                                                                 WALKING_DOWNSTAIRS, SITTING,         
                                                                 STANDING, LAYING). The experiments   
                                                                 have been video-recorded to label    
                                                                 the data manually.                   

Person          **[subject]**     factor            30  0.00 %   A group of 30 volunteers within an   
performing                                                       age bracket of 19-48 years carried   
the activity                                                     out the experiments.                 

Physical        **[domain]**      factor             2  0.00 %   From each window, a vector of        
domain of                                                        features was obtained by             
the variable                                                     calculating variables either from    
                                                                 the time or frequency domain.        

Physical        **[component]**   factor             2  0.00 %   The sensor acceleration signals      
domain of                                                        have gravitational and body motion   
the variable                                                     components, separated using a        
                                                                 Butterworth low-pass filter into     
                                                                 body acceleration and gravity. The   
                                                                 gravitational force is assumed to    
                                                                 have only low frequency components,  
                                                                 therefore a filter with 0.3 Hz       
                                                                 cutoff frequency was used.           
                                                                 Gyroscope signals have only body     
                                                                 motion component.                    

Embedded        **[sensor]**      factor             7  0.00 %   Linear acceleration and angular      
accelerometer                                                    velocity are captured using a        
or gyroscope                                                     smartphone's embedded accelerometer  
                                                                 and gyroscope sensors. The body      
                                                                 linear acceleration and angular      
                                                                 velocity were derived in time to     
                                                                 obtain Jerk signals.                 

3-axial         **[axis]**        factor             4  0.00 %   3-axial linear acceleration and      
signals                                                          3-axial angular velocity are         
                                                                 captured. Also the magnitude of      
                                                                 these three-dimensional signals      
                                                                 were calculated using the Euclidean  
                                                                 norm.                                

Mean value      **[mean]**        numeric         5760  0.00 %   Mean value normalized and bounded    
                                                                 within [-1,1], estimated from the    
                                                                 3-axial linear acceleration and      
                                                                 3-axial angular velocity signals.    

Standard        **[std]**         numeric         5760  0.00 %   Standard deviation normalized and    
deviation                                                        bounded within [-1,1], estimated     
                                                                 from the 3-axial linear              
                                                                 acceleration and 3-axial angular     
                                                                 velocity signals.                    
------------------------------------------------------------------------------------------------------




# Variable list
## activity

*Activity performed by the person*

<div class = "row">
<div class = "col-lg-8">

------------------------------------
Feature                       Result
------------------------- ----------
Variable type                 factor

Number of missing obs.       0 (0 %)

Number of unique values            6

Mode                        "LAYING"

Reference category            LAYING
------------------------------------


</div>
<div class = "col-lg-4">
![plot of chunk Var-1-activity](figure/Var-1-activity-1.png)

</div>
</div>




---

## subject

*Person performing the activity*

<div class = "row">
<div class = "col-lg-8">

-----------------------------------
Feature                      Result
------------------------- ---------
Variable type                factor

Number of missing obs.      0 (0 %)

Number of unique values          30

Mode                            "1"

Reference category                1
-----------------------------------


</div>
<div class = "col-lg-4">
![plot of chunk Var-2-subject](figure/Var-2-subject-1.png)

</div>
</div>


- Note: The variable consists exclusively of numbers and takes a lot of different values. Is it perhaps a misclassified numeric variable? 



---

## domain

*Physical domain of the variable*

<div class = "row">
<div class = "col-lg-8">

-----------------------------------
Feature                      Result
------------------------- ---------
Variable type                factor

Number of missing obs.      0 (0 %)

Number of unique values           2

Mode                         "TIME"

Reference category             TIME
-----------------------------------


</div>
<div class = "col-lg-4">
![plot of chunk Var-3-domain](figure/Var-3-domain-1.png)

</div>
</div>




---

## component

*Physical domain of the variable*

<div class = "row">
<div class = "col-lg-8">

-----------------------------------
Feature                      Result
------------------------- ---------
Variable type                factor

Number of missing obs.      0 (0 %)

Number of unique values           2

Mode                         "Body"

Reference category             Body
-----------------------------------


</div>
<div class = "col-lg-4">
![plot of chunk Var-4-component](figure/Var-4-component-1.png)

</div>
</div>




---

## sensor

*Embedded accelerometer or gyroscope*

<div class = "row">
<div class = "col-lg-8">

-----------------------------------
Feature                      Result
------------------------- ---------
Variable type                factor

Number of missing obs.      0 (0 %)

Number of unique values           7

Mode                          "Acc"

Reference category              Acc
-----------------------------------


</div>
<div class = "col-lg-4">
![plot of chunk Var-5-sensor](figure/Var-5-sensor-1.png)

</div>
</div>




---

## axis

*3-axial signals*

<div class = "row">
<div class = "col-lg-8">

-----------------------------------
Feature                      Result
------------------------- ---------
Variable type                factor

Number of missing obs.      0 (0 %)

Number of unique values           4

Mode                          "MAG"

Reference category              MAG
-----------------------------------


</div>
<div class = "col-lg-4">
![plot of chunk Var-6-axis](figure/Var-6-axis-1.png)

</div>
</div>




---

## mean

*Mean value*

<div class = "row">
<div class = "col-lg-8">

----------------------------------------
Feature                           Result
------------------------- --------------
Variable type                    numeric

Number of missing obs.           0 (0 %)

Number of unique values             5760

Median                             -0.13

1st and 3rd quartiles       -0.93; -0.01

Min. and max.                   -1; 0.97
----------------------------------------


</div>
<div class = "col-lg-4">
![plot of chunk Var-7-mean](figure/Var-7-mean-1.png)

</div>
</div>


- Note that the following possible outlier values were detected: \"0.12\", \"0.12\", \"0.12\", \"0.12\", \"0.12\", ..., \"0.97\", \"0.97\", \"0.97\", \"0.97\", \"0.97\" (566 values omitted). 



---

## std

*Standard deviation*

<div class = "row">
<div class = "col-lg-8">

----------------------------------------
Feature                           Result
------------------------- --------------
Variable type                    numeric

Number of missing obs.           0 (0 %)

Number of unique values             5760

Median                             -0.92

1st and 3rd quartiles       -0.97; -0.36

Min. and max.                   -1; 0.69
----------------------------------------


</div>
<div class = "col-lg-4">
![plot of chunk Var-8-std](figure/Var-8-std-1.png)

</div>
</div>




---



Report generation information:

 *  Created by: eZeTec (username: `eZe`).

 *  Report creation time: Fri Dec 17 2021 16:01:33

 *  Report was run from directory: `E:/@projects/ProgrammingAssignment3`

 *  dataReporter v1.0.2 [Pkg: 2021-11-11 from CRAN (R 4.1.2)]

 *  R version 4.1.2 (2021-11-01).

 *  Platform: x86_64-w64-mingw32/x64 (64-bit)(Windows 10 x64 (build 22000)).

 *  Function call: `makeDataReport(data = eval(parse(text = table_name)), render = F, 
    mode = c("summarize", "visualize", "check"), smartNum = F, 
    file = rmd_file_path, replace = T, quiet = T, openResult = F, 
    codebook = T, reportTitle = table_name)`
