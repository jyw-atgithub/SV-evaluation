library("ggplot2")
library("tidyverse")
library("dplyr")
library("gridExtra")
setwd("/Users/Oscar/Downloads")

t1=read.table("f1_score.txt",header=FALSE)

np18=t1 %>% filter(V1=="nanopore2018")
colnames(np18)=c("tech","coverage","program","post-process","f1_score")
p_np18= ggplot(data=np18,aes(x=coverage,y=f1_score,group=program))
p_np18+geom_line(aes(color=program),size=1)+geom_point(aes(color=program))+
#  ggtitle("f1 score")+  
  theme_classic() + 
  theme(legend.title = element_text(size=20), legend.text = element_text(size=20))+
  theme(legend.key.size = unit(0.6, 'cm'))