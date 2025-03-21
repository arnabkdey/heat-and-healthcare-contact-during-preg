# -------------------------------------------------------------------------------
# @project: Heat and healthcare contact during pregnancy in India
# @author: Arnab K. Dey,  arnabxdey@gmail.com 
# @organization: Scripps Institution of Oceanography, UC San Diego
# @description: This script merges climate zone classifications with processed individual-level DHS data.
# @date: Dec 12, 2024

# Load packages ----- 
pacman::p_load(dplyr, janitor, data.table, fst, openxlsx, here, googledrive)
# rm(list = ls())
source("paths_mac.R")

# Read datasets ----- 
### IR vars created datasets -----
df_IR_full_6mo <- read_fst(here(path_project, "processed-data", "1.1-dhs-IR-vars-created-6mo.fst"), as.data.table = TRUE)
df_IR_full_7mo <- read_fst(here(path_project, "processed-data", "1.1-dhs-IR-vars-created-7mo.fst"), as.data.table = TRUE)

## Climate zones of India with districts ----
df_zones <- read_fst(here(path_project, "processed-data", "1.3-india-dist-climate-zones.fst"), as.data.table = TRUE)

# Merge climate zones into IR dataset  ----
## Convert all variable labels to lower case in df_zones and match state/dist names
df_zones <- df_zones |>
  dplyr::mutate(state_name = tolower(OTHREGNA),
    dist_name = tolower(REGNAME)) |>
  dplyr::mutate(state_name = ifelse(state_name == "dadra & nagar haveli & daman & diu", 
    "dadra & nagar haveli and daman & diu", state_name)) |>
  dplyr::mutate(dist_name = case_when(
    dist_name == "maharajganj" ~ "mahrajganj",
    dist_name == "buxer" ~ "buxar",
    dist_name == "north & middle andaman" ~ "north  & middle andaman",
    dist_name == "janjgir-champa" ~ "janjgir - champa",
    dist_name == "leh" ~ "leh(ladakh)",
    dist_name == "north district" ~ "north  district",
    dist_name == "sant ravidas nagar" ~ "sant ravidas nagar (bhadohi)",
    TRUE ~ dist_name))

## Merge df_zones with df_IR_full -----
### For 6mo dataset
df_IR_full_w_zones_6mo <- merge(df_IR_full_6mo, df_zones, 
                    by.x = c("meta_state_name", "meta_dist_name"), 
                    by.y = c("state_name", "dist_name"), 
                    all.x = TRUE)

colnames(df_IR_full_w_zones_6mo)

### For 7mo dataset
df_IR_full_w_zones_7mo <- merge(df_IR_full_7mo, df_zones, 
                    by.x = c("meta_state_name", "meta_dist_name"), 
                    by.y = c("state_name", "dist_name"), 
                    all.x = TRUE)

# sum(is.na(df_IR_full_w_zones_7mo$climate_zone))

# Save the dataset as an RDS ----
saveRDS(df_IR_full_w_zones_6mo, file = here(path_project, "processed-data", "1.4-processed-IR-data-6mo.rds"))
saveRDS(df_IR_full_w_zones_7mo, file = here(path_project, "processed-data", "1.4-processed-IR-data-7mo.rds"))
print("saving complete")