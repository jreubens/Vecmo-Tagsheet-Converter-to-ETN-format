---
Title: "Vecmo Tagsheet Converter to ETN format"
authors: "JAn Reubens, Jolien Goossens"
date: `r Sys.Date()`
---


#Load Library 'dplyr' and 'readxl'
library(plyr)
library(readxl)
library(dplyr)
library(tidyr)

# 1. Read in Vemco Tagsheet  
input <- read_excel("Data/TagSheet_PC4C_Erwin.xls", sheet=2)
write.csv(input, file = "Data/TagSheet_PC4C_ERwin.csv")
input <- read.csv2("Data/TagSheet_PC4C_Erwin.csv",sep=",")
summary(input)
head(input)
names(input)

# 2. Data manipulation
# a. Data selection --> only keep the metadata to import in ETN
selection <- select(input, Serial.No.,Customer, Researcher, Tag.Family, VUE.Tag.ID,Est.tag.life..days.,
                    Step.1.Time......dy.hr.min.sec.,Step.1.Power..L.H.,Step.1.Acc..On..sec.,Step.1.Min.Delay..sec.,
                    Step.1.Max.Delay..sec.,Step.2.Time........dy.hr.min.sec.,Step.2.Power..L.H.,
                    Step.2.Acc..On..sec.,Step.2.Min.Delay..sec.,Step.2.Max.Delay..sec.,
                    Step.3.Time........dy.hr.min.sec.,Step.3.Power..L.H.,Step.3.Acc..On..sec.,Step.3.Min.Delay..sec.,
                    Step.3.Max.Delay..sec.,Step.4.Time..........dy.hr.min.sec.,Step.4.Power..L.H.,Step.4.Acc..On..sec.,
                    Step.4.Min.Delay..sec.,Step.4.Max.Delay..sec.,Sensor.type,Range,Units,Slope,Intercept,
                    Accelerometer.Algorithm,Accelerometer.Samples...sec.,Sensor.Transmit.Ratio)                          

# b. Rename Headers to ETN format
selection <- selection %>%
  rename(serialNumber = Serial.No.,
         ownerGroup = Customer,
         tagCodeSpace = VUE.Tag.ID,
         model = Tag.Family,
         sensorType	= Sensor.type,
         estimatedLifetime	= Est.tag.life..days.,
         durationStep1 = Step.1.Time......dy.hr.min.sec.,
         maxDelayStep1 = Step.1.Max.Delay..sec.,
         minDelayStep1 = Step.1.Min.Delay..sec., 
         acceleration_on_sec_step1 = Step.1.Acc..On..sec.,
         powerStep1	= Step.1.Power..L.H.,
         durationStep2 = Step.2.Time........dy.hr.min.sec.,
         maxDelayStep2 = Step.2.Max.Delay..sec.,	
         minDelayStep2 = Step.2.Min.Delay..sec.,
         acceleration_on_sec_step2 = Step.2.Acc..On..sec.,
         powerStep2	= Step.2.Power..L.H.,
         durationStep3	= Step.3.Time........dy.hr.min.sec.,
         maxDelayStep3	= Step.3.Max.Delay..sec.,
         minDelayStep3	= Step.3.Min.Delay..sec.,
         acceleration_on_sec_step3 = Step.3.Acc..On..sec.,
         powerStep3 = Step.3.Power..L.H.,
         durationStep4 = Step.4.Time..........dy.hr.min.sec.,
         maxDelayStep4= Step.4.Max.Delay..sec.,
         minDelayStep4 = Step.4.Min.Delay..sec.,
         acceleration_on_sec_step4 = Step.4.Acc..On..sec.,
         powerStep4	= Step.4.Power..L.H.,
         intercept	= Intercept,
         slope	= Slope,
         ownerPi	= Researcher,
         range = Range,
         units = Units,
         accelerometer_algoritm = Accelerometer.Algorithm,
         accelerometer_samples_per_sec = Accelerometer.Samples...sec.,
         sensor_transmit_ratio = Sensor.Transmit.Ratio)

#c. Add columns

selection$manufacturer <- "vemco"
selection$acousticTagType <- "animal"
selection$type <- "acoustic"
selection <- selection %>%
  separate(tagCodeSpace, c("Code", "Code2", "idCode"), "-", remove = F) %>%
  select(-Code, -Code2) #added idCode
selection$thelmaConvertedCode	<- NA
selection <- selection %>%
  separate(model, c("model1", "model2", "frequency", "rm1", "rm2"), "-", remove = T) %>%
  select(-rm1, -rm2) #added frequency
selection <- selection %>%  
  unite(model, model1, model2, sep ="-", remove =T) # united model1 and 2 to correct format
 


# d. Rename specific arguments to match ETN
# Typical fields that need to be updated:
# - ownergroup
# - ownerPI

selection$ownerGroup <-  plyr::revalue(selection$ownerGroup, c("WAGENINGEN UR MARINE RESEARCH"="IMARES"))
selection$ownerPi <-  plyr::revalue(selection$ownerPi, c("Jan Reubens"="Erwin Winter"))


# 3. Save .csv output file for import in ETN
write.csv(selection, file = "Export/tag_import_ETN.csv", row.names = F)
