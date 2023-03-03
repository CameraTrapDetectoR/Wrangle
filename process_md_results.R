#' Function to read in MegaDetector results
#'
#'
#' @param json_path absolute path to json file with MD results
#' @param score_threshold confidence score threshold to flag results.
#' Accepts values 0-1; Default=0.5
#'
#' @import rjson
#' @import dplyr
#'
#' @return df of MD results with user-determined flags based on class, confidence score
#'
#' @export

process_md_results <- function(json_path=NULL, score_threshold=0.5){

  # load dplyr for pipe function
  library(dplyr)

  # load detections
  json_file <- rjson::fromJSON(file = json_path)
  md_results <- json_file$images

  # create empty df to hold results
  md_df <- data.frame(matrix(nrow = 0, ncol = 7))
  colnames(md_df) <- c("filename", "class", "conf", "c1", "c2", "c3", "c4")

  # loop through image files
  for(i in 1:length(md_results)){
    # isolate detections for a single image
    img <- md_results[i][[1]]

    # define variables
    detections <- img$detections
    filename <- img$file

    # create dummy observation for empty detections
    if(length(detections) == 0){
      class <- "empty"
      confidence <- 0
      x <- y <- w <- h <- 0
      det_row <- cbind(filename, class, conf, x, y, w, h)
      md_df <- rbind(md_df, det_row)
    }

    else {
      # loop through each prediction in a given image
      for(j in 1:length(detections)){

        # isolate individual detection
        pred <- detections[j][[1]]

        # define cat, conf, bbox
        class <- pred$category
        conf <- pred$conf
        x <- pred$bbox[1]
        y <- pred$bbox[2]
        w <- pred$bbox[3]
        h <- pred$bbox[4]

        # cat results into a vector
        det_row <- cbind(filename, class, conf, x, y, w, h)

        # add detection to df
        md_df <- rbind(md_df, det_row)
      }
    }
  }

  # data processing
  md_df <- md_df %>%
    # convert numbers to numerics
    dplyr::mutate(conf = as.numeric(conf),
           x = as.numeric(x),
           y = as.numeric(y),
           w = as.numeric(w),
           h = as.numeric(h)) %>%
    # convert coordinates
    dplyr::mutate(XMin = (x - w)/2,
           YMin = (y + h)/2,
           XMax = (x + w)/2,
           YMax = (y - h)/2) %>%
    dplyr::mutate(class = ifelse(class == "1", "animal",
                          ifelse(class == "2", "person",
                                 ifelse(class == "3", "vehicle", class)))) %>%
    # create a flag column
    dplyr::mutate(flag = NA)

  # flag any detections that are not animals
  md_df <- md_df %>%
    dplyr::mutate(flag = ifelse(class != "animal", "class_flag", flag))

  # flag detections below acceptable confidence threshold
  md_df$conf <- round(md_df$conf, 2)
  md_df <- md_df %>%
    dplyr::mutate(flag = ifelse(conf < score_threshold,
                         paste(flag, "conf_flag", sep = ", "), flag))

  # add column for bbox coordinates
  md_df$bbox.origin <- "UL"

  return(md_df)
} #END

