### Step-by-Step Guide: Creating and Uploading Datasets to RStudio

# Step 1: Install and Load Libraries
install.packages(c("tidyverse", "readr", "dplyr", "ggplot2", "stringr"))
library(readr)
library(dplyr)
library(ggplot2)
library(stringr)

# Step 2: Load Datasets
imdb <- imdb_titles_v3
netflix <- netflix_titles_v3
global <- all_weeks_global_v3
countries <- all_weeks_countries_v3
popular <- most_popular_v3

# Step 3: Standardize Clean Title Column
clean_titles <- function(title) {
  if (is.na(title)) return("N/A")
  title <- tolower(title)
  title <- str_replace_all(title, "[[:punct:]]", "")  # Remove punctuation
  title <- str_trim(title)  # Trim whitespace
  return(title)
}

imdb <- imdb %>%
  mutate(clean_title = clean_titles(clean_title))

netflix <- netflix %>%
  mutate(clean_title = clean_titles(clean_title))

global <- global %>%
  mutate(clean_title = clean_titles(clean_title))

countries <- countries %>%
  mutate(clean_title = clean_titles(clean_title))

popular <- popular %>%
  mutate(clean_title = clean_titles(clean_title))

# Step 4: Merge Datasets
imdb_netflix <- imdb %>%
  left_join(netflix, by = "clean_title")

# export imdb_netflix as csv
write.csv(imdb_netflix, file = "imdb_netflix.csv", row.names = FALSE)


merged_data <- imdb_netflix %>%
  left_join(global, by = "clean_title") %>%
  left_join(countries, by = "clean_title") %>%
  left_join(popular, by = "clean_title")

# Remove duplicate entries based on 'clean_title'
merged_data <- merged_data %>%
  distinct(clean_title, .keep_all = TRUE)

# View the cleaned merged_data
head(merged_data)

# Check the number of rows after cleaning
nrow(merged_data)

# Step 5: Verify Data Quality
summary <- merged_data %>%
  summarize(
    total_titles = n(),
    matched_titles = sum(!is.na(clean_title)),
    unmatched_titles = sum(is.na(clean_title))
  )
print(summary)

#rename merged_data as imdb_netflix_v4
imdb_netflix_v4 <- merged_data

# View the cleaned imdb_netflix_v4
head(imdb_netflix_v4)

# Check the number of rows after cleaning
nrow(mimdb_netflix_v4)

# Step 5: Verify Data Quality
summary <- imdb_netflix_v4 %>%
  summarize(
    total_titles = n(),
    matched_titles = sum(!is.na(clean_title)),
    unmatched_titles = sum(is.na(clean_title))
  )
print(summary)

# export imdb_netflix_v4 as csv
write.csv(imdb_netflix, file = "imdb_netflix_v4.csv", row.names = FALSE)