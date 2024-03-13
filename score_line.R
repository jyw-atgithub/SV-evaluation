library("ggplot2")
library("tidyverse")
library(RColorBrewer)
library(khroma)
setwd("/Users/Oscar/Desktop/Emerson_Lab_Work/Eval-SV")

t1=read.table("f1_score.txt",header=FALSE)


t=read.table("fp_fn.txt",header = FALSE)
t$V3=gsub("_filtered","",t$V3)
t$V3=gsub("mumco_svimASM","this_research",t$V3)
colnames(t)<- c("type","coverage","caller", "f1","false_positive", "false_negative", "total_called")
t$false_negative[4]=2247
t$false_negative[94]=2484
t$false_negative[97]=1203
t$false_positive=t$false_positive/t$total_called
t$false_negative=t$false_negative/3000

#The font size are optimized for dimensions: 2400*1600 pixel

np18=t %>% filter(type=="nanopore2018")
p_np18=ggplot(data=np18,aes(x=coverage,y=false_positive ,group=caller))
p_np18+geom_line(aes(color=caller),linewidth=5)+geom_point(aes(color=caller),size=8)+
  theme_light(base_size = 40)+ggtitle("False Positive Rate of ONT R9.4.1")+
  scale_colour_highcontrast()+
  theme(title= element_text(size=30),legend.title = element_text(size=28), 
        legend.text = element_text(size=32))

fn_np18=ggplot(data=np18,aes(x=coverage,y=false_negative ,group=caller))
fn_np18+geom_line(aes(color=caller),linewidth=5)+geom_point(aes(color=caller),size=8)+
  theme_light(base_size = 40)+ggtitle("False Negative Rate of ONT R9.4.1")+
  scale_colour_highcontrast()+
  theme(title= element_text(size=30),legend.title = element_text(size=28), 
        legend.text = element_text(size=32))

pb16=t %>% filter(type=="pacbio2016")
p_pb16=ggplot(data=pb16,aes(x=coverage,y=false_positive ,group=caller))
p_pb16+geom_line(aes(color=caller),linewidth=5)+geom_point(aes(color=caller),size=8)+
  theme_light(base_size = 40)+ggtitle("False Positive Rate of PacBio RS2")+
  scale_colour_highcontrast()+
  theme(title= element_text(size=30),legend.title = element_text(size=28), 
        legend.text = element_text(size=32))

fn_pb16=ggplot(data=pb16,aes(x=coverage,y=false_negative ,group=caller))
fn_pb16+geom_line(aes(color=caller),linewidth=5)+geom_point(aes(color=caller),size=8)+
  theme_light(base_size = 40)+ggtitle("False Negative Rate of PacBio RS2")+
  scale_colour_highcontrast()+
  theme(title= element_text(size=30),legend.title = element_text(size=28), 
        legend.text = element_text(size=32))


