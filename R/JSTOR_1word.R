#' Plot the frequency of one word over time in a JSTOR DfR dataset
#' 
#' @description Function to plot changes in the relative frequency of a word over time. The relative frequency is the frequency of the word in a document divided by the total number of words in a document. For use with JSTOR's Data for Research datasets (http://dfr.jstor.org/).
#' @param unpack1grams object returned by the function JSTOR_unpack1grams.
#' @param oneword One word, surrounded by standard quote marks, or a vector of words
#' @param span span of the lowess line (controls the degree of smoothing). Default is 0.4
#' @param se logical, show or hide standard error region of smoother line, Default is TRUE.
#' @return Returns a ggplot object with publication year on the horizontal axis and log relative frequency on the vertical axis. Each point represents a single document.
#' @examples 
#' ## JSTOR_1word(unpack1grams, "diamonds")
#' ## JSTOR_1word(unpack1grams, c("diamonds", "pearls"), span = 0.8, se = FALSE)

JSTOR_1word <- function(unpack1grams, oneword, span = 0.5, se=TRUE){
  #### investigate change in use of certain words of interest over time
  y <- unpack1grams$wordcounts
  
  bibliodata <- unpack1grams$bibliodata
  
  # using dtm
  # y <- as.matrix(wordcounts)
  # Get total number of word in all articles to standarise for different article lengths
  leng <- slam:::row_sums.simple_triplet_matrix(y)
  # now get total number of word of interest (always lower case)
  word <- as.matrix(  y[ , (dimnames(y)$Terms %in% oneword)  ]  )
  
  # alert if word is not present
  if ( (length(dimnames(word)$Terms) == 0) | (length(dimnames(word)$Terms) == 0) ) {
    stop("This word is not present in the document term matrix, so this function cannot be completed") 
  } else {
  
  
  # if vector of words, get row totals
  if (length(oneword) > 1) {
    word <- as.matrix(rowSums(word)) 
  } else {
    word <- word
  }
  
  # calculate ratio
  word_ratio <- word/leng
  

  
  # get years for each article
  suppressMessages(library(data.table))
  word_by_year <- data.table(word_ratio = word_ratio, year = as.numeric(as.character(bibliodata$year)))
  setnames(word_by_year, c("word_ratio", "year"))
  lim_min <- as.numeric(as.character(min(bibliodata$year)))
  lim_max <- as.numeric(as.character(max(bibliodata$year)))
  # vizualise one word over time
  library(ggplot2)
  suppressWarnings(ggplot(word_by_year, aes(year, log(word_ratio))) +
                     geom_point(subset = .(word_ratio > 0)) +
                     geom_smooth( aes(group = 1), method = "loess", se = se, span = span, data=subset(word_by_year, word_ratio>0)) +
                     theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
                     ylab(paste0("log of frequency of the word '", oneword, "'")) +
                     # inspect bibliodata$year to see min and max year to set axis limits
                     scale_x_continuous(limits=c(lim_min, lim_max), breaks = seq(lim_min-1, lim_max+1, 2)))
 }
}

