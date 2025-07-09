library(jiebaRD) 
library(jiebaR)                 
library(wordcloud2)
library(dplyr)
library(tm)
df <- read.table(file = "freq_input.txt", header = T, sep = '\t')
wordcloud2(df)
wordf <- arrange(df, -freq) 
wordcloud2(data=wordf)
color = rep(c('#238B45',"#66C2A4", '#B2E2E2',"#EDF8FB"),
            nrow(wordf))
wordcloud2(wordf, 
           color = color, 
           fontWeight = "700",
           rotateRatio = 0)
wordcloud2(wordf, 
           size = 0.7, 
           shape = 'star')
wordcloud2(wordf, size = 0.8,
           shape = "diamond",
           color = "random-light", 
           backgroundColor = "gray")
wordcloud2(wordf, 
           size = 1, 
           minRotation = -pi/8, 
           maxRotation = pi/8,  
           rotateRatio = 0.9    
)
wordcloud2(wordf, 
           size = 0.7,
           shape = 'cardioid'
)+WCtheme(2)
color = rep(c('#138BB9', '#4198B9',"#6FA5B9","#9EB1B9"),
            nrow(wordf))
wordcloud2(wordf, 
           color = color, 
           fontWeight = "700",
           rotateRatio = 0)