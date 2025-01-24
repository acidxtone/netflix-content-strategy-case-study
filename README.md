
# Netflix Content Strategy Case Study


## Step 1: Explore the Datasets

### Datasets:

1. **IMDb Top Rated Titles (Movies & TV Series)** (`data.csv`)

   - Provides metadata about TV shows and movies, including genres, ratings, and popularity.
   - [Dataset link](https://www.kaggle.com/datasets/octopusteam/imdb-top-rated-titles-movies-and-tv-series)

2. **Netflix Movies and TV Shows** (`netflix_titles.csv`)

   - Includes details about titles available on Netflix, such as genre, duration, and release year.
   - [Dataset link](https://www.kaggle.com/datasets/shivamb/netflix-shows)

3. **Official Netflix Viewership Database** (`most_popular.csv`, `all_weeks_countries.csv`, `all_weeks_global.csv`)

   - Provides weekly views in hours, highlighting popular Netflix titles.
   - [Dataset link](https://www.kaggle.com/datasets/sujaykapadnis/official-netflix-streaming-data?select=all-weeks-global.csv)

### Actions:

- Load and inspect datasets for completeness, missing values, and compatibility (e.g., how genres and titles match across datasets).
- Familiarize yourself with columns in each dataset and decide how they relate to your topic.

#### Collect Data

- Upload all datasets to Google Sheets, Excel

#### Standardize Categories Across Datasets - Excel

- Rename inconsistent column names for uniformity. For example:
- Rename `show_title` to `title` `catagory` to `type` `runtime` to `duration` across all datasets, `listed_in` to `genre`,`rank`to `weekly_rank` 
    - Create new columns and separate type (TV Show / Movie ) from language ( Non English/ English) in the `all_weeks_global.csv` & `most_popular.csv`
      - =IF(ISNUMBER(SEARCH("Film",B2)),"Film",IF(ISNUMBER(SEARCH("TV",B2)),"TV","")) 
        - for film or tv
      - =IFERROR(TRIM(MID(B1,FIND("(",B1)+1,FIND(")",B1)-FIND("(",B1)-1)),"")
        - for language  
    - Create new column to separate `duration_mins` (time and seasons) to `seasons`
      - =IF(ISNUMBER(SEARCH("min", A2)), VALUE(LEFT(A2, SEARCH("min", A2)-1)), "") 
        - for `duration_mins` mins
      - =IF(ISNUMBER(SEARCH("season", A2)), VALUE(LEFT(A2, SEARCH("season", A2)-2)), "")
        - for  `seasons`  
- Rename In the `type` column change the names to proper names like `TV show` `Movie` etc.
- Align `releaseYear` (IMDb) with `release_year` (Netflix).


#### Clean Data

- Trim whitespace from key columns like `title` and `season_title`.
- Reformat all duration vlues to mins in `duration_mins` 
  - =A1*60 
    - from min to Hr
- Replace blank cells with `N/A` or a default value. use "Go To Special" fill all banks type "N/A" Ctrl + Enter to fill all the selected blank cells with "N/A".
- Handle missing values:
  - For numerical columns like `averageRating` or `weekly_hours_viewed`, use a default value or leave null.
  - For text columns, use "Unknown" or "N/A" if needed.
- Save cleaned files as `*_v1.csv` (e.g., `data_v1.csv`).

#### 4. Remove Unnecessary Columns

- Identify columns irrelevant to the analysis and remove them.

- **IMDb Top Rated Titles:** (data_v1.csv)

  - **Useful:**
    - `title`: Essential for joining datasets and identifying titles.
    - `genres`: Key to analyzing genre trends.
    - `averageRating`: Helps identify top-rated genres.
    - `release_year`: Useful for comparing release trends across datasets.
    - `type` : useful for comparing which types of narrative formats TV Shows or Movies
  - **Not Useful:**
    - `tconst`: A unique identifier in IMDb, but not relevant for analysis.
    - `numVotes`: Could be useful for detailed popularity analysis but is not essential for this project.

- **Netflix Titles:** (netflix_titles_v1.csv)

  - **Useful:**
    - `title`: Essential for joining datasets and identifying titles.
    - `genre` (genres): Helps standardize genre categories with other datasets.
    - `release_year`: Useful for identifying trends over time.
    - `type` : useful for comparing which types of narrative formats TV Shows or Movies
  - **Not Useful:**
    - `director`: Not relevant unless analyzing director-specific trends.
    - `cast`: Could be useful for actor-specific analyses but is outside the scope of this study.
    - `country`: Not relevant unless regional trends are considered.
    - `rating`: Could be useful for age-specific trends but is excluded here.
    - `duration`: Not directly relevant unless analyzing by runtime.
    - `description`: Adds context but does not contribute directly to the analysis goals.

- **Netflix Streaming Data:** (all_weeks_global_v1.csv, all_weeks_countries_v1.csv, most_popular_v1.csv)

  - **Useful:**
    - `title`: Essential for joining datasets and identifying titles.
    - `weekly_hours_viewed`: A key metric for measuring popularity.
    - `category`: Distinguishes between movies and TV shows.
    - `week`: Helps assess trends over time.
    - `type` : useful for comparing which types of narrative formats TV Shows or Movies
    - `weekly_rank`: A metric for measuring popularity.
    - `countries` : 
  - **Not Useful:**
    - `season_title`: Relevant only if a detailed seasonal analysis is needed.
    - `runtime`: Not relevant unless runtime analysis is a focus.
    - `weekly_views`: Redundant if `weekly_hours_viewed` is used.
    - `is_staggered_launch`: Useful for launch strategy analysis but not in this case.
    - `episode_launch_details`: Not relevant for high-level analysis.
    
    * reaname  `data_v1.csv` to `imdb_v2.csv`
    * reaname each file to add "v2.csv"
               ## imdb_v2.csv , netflix_titles_v2.csv, most_popular_v2.csv, all_weeks_countries_v2.csv, all_weeks_global_v2.csv ### Phase 2: Merging Data in BigQuery

      Rename the cleaned file `imdb_v3.csv` to `imdb_titles_v3.csv` for consistency with the dataset names used in the queries.

#### Standardize Titles for Matching (excel)

- Add a `clean_title` column to each dataset:
  ```excel
  =LOWER(SUBSTITUTE(SUBSTITUTE(A2, "'", ""), ":", ""))
  ```
- Use this column to join datasets.
- Save updated files as `*_v3.csv` (e.g., `imdb_v3.csv`).

### Creating and Uploading Datasets to RStudio

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
  title <- tolower(title)                       # Convert to lowercase
  title <- str_replace_all(title, "[[:punct:]]", "")  # Remove punctuation
  title <- str_trim(title)                      # Trim whitespace
  title[is.na(title)] <- "N/A"                  # Replace NAs with "N/A"
  return(title)
}

# Step 4: Merge Datasets
imdb_netflix <- imdb %>%
  left_join(netflix, by = "clean_title")

# Merge the global dataset to include 'weekly_hours_viewed'
imdb_netflix <- imdb_netflix %>%
  left_join(global %>% select(clean_title, weekly_hours_viewed), by = "clean_title")

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

#rename summary as summary_imdb_netflix_v4
summary_imdb_netflix_v4 <- summary

# export summary_imdb_netflix_v4 as csv
write.csv(summary_imdb_netflix_v4, file = "summary_imdb_netflix_v4.csv", row.names = FALSE)

## Clean the new data set in Excel or Google Sheets.
    - open imdb_netflix_v4.csv
    - get rid of the Redundant columns such as `genre.y` 
    - rename the release_year.y -> end_year (when a TV Show stopped airing)
    - rename "type.x, genres.x, release_year.x, type.y,"
    - rename them to "type, genres, release_year, type,"
    - rename create a new csv imdb_netflix_v5.csv

### **Prepare for Analysis Phase - Using Excel**

#### **1. Load the Dataset:**
- Open your cleaned dataset (`imdb_netflix_v5.csv`) in Excel. Save the file as excel format to keep formating settings `imdb_netflix_v5.xlxs`.
- Inspect for additional cleaning needs:
  - Check for empty rows or columns and remove them.
  - Validate that numeric columns (e.g., `weekly_hours_viewed`) contain numbers and no unexpected text or symbols.
  - create a new sheet `imdb_netflix_v6` and use vlookup to get rid of duplicates in the clean_title column
      =UNIQUE('imdb_netflix_v5'!A2:A7370)
      =IF(A2<>"", VLOOKUP(A2, 'imdb_netflix_v5'!A$2:H$7370, 2, FALSE), "")
      =IF(A2<>"", VLOOKUP(A2, 'imdb_netflix_v5'!A$2:H$7370, 3, FALSE), "")
      =IF(A2<>"", VLOOKUP(A2, 'imdb_netflix_v5'!A$2:H$7370, 4, FALSE), "")
      =IF(A2<>"", VLOOKUP(A2, 'imdb_netflix_v5'!A$2:H$7370, 5, FALSE), "")
      =IF(A2<>"", VLOOKUP(A2, 'imdb_netflix_v5'!A$2:H$7370, 6, FALSE), "")
      =IF(A2<>"", VLOOKUP(A2, 'imdb_netflix_v5'!A$2:H$7370, 7, FALSE), "")
  - create a new sheet `imdb_netflix_v7` and get rid of `year_end` and N/A and bank titles etc

#### **2. Filter Relevant Data:**
- Apply the **Filter** feature:
  - Highlight your dataset and go to **Data** > **Filter**.
  - Use filters on the `type` column to focus on TV Shows.
  - Use filters on `genres` to analyze specific genres if needed.
  - Sort `weekly_hours_viewed` in descending order to identify top-performing entries.

  - create a new sheet `imdb_netflix_v7.csv` and get rid of `year_end` and N/A and bank titles etc
  

### Analysis and Visualization Using Tableau

#### Analysis Phase

1. **Import Data**
   - Open Tableau and connect to the cleaned dataset (`imdb_netflix_v7.csv`).
   - Verify fields are correctly recognized: 
     - `weekly_hours_viewed` (numeric), 
     - `average_rating` (numeric), 
     - `genres` (categorical), 
     - `release_year` (numeric), and 
     - `type` (categorical).

2. **Genre Analysis**
   - Create a **Bar Chart**:
     - Drag `genres` to Rows and `weekly_hours_viewed` to Columns.
     - Sort bars in descending order to highlight top-performing genres.

3. **Correlation Analysis**
   - Create a **Scatter Plot**:
     - Place `average_rating` on the X-axis and `weekly_hours_viewed` on the Y-axis.
     - Add color markers for `genres` and a trend line.

4. **Trend Analysis**
   - Use a **Line Chart**:
     - Drag `release_year` to Columns and `weekly_hours_viewed` to Rows.
     - Color-code by `genres` to visualize trends over time.




