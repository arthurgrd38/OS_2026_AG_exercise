

# Load the data
df<-read.table(here("data/nutrients_plant_icing_adventdalen_2025.txt"), header = TRUE, sep = " ")

## Re-organisation the columns to make the data usable

# Remove the column "sample" with the path and the comments for the adjusted values from the nutrients models
df <- dplyr::select(df, -sample, -n, -c, -p, -si, -phenolics, -n_comment, -p_comment, -c_comment, -si_comment, -phenolics_comment)

# Correct mistakes on the id labels
df <- df %>%
  mutate(id = sub("_$", "", id),   # removes any trailing underscore, if there is one
         id = gsub("--", "-", id)) # replaces double dashes with a single dash

# Replace "_" to "-" A SECOND TIME JUST IN CASE IF SOME VARIABLES CHANGE
#df$id <- gsub("_", "-", df$id)

# Correct mistakes on the subplot names: 4-12 to 9-12 for plot A1_12I for all species from _3_1 to _4_5
df <- df %>%
  mutate(id = sub("^(A1_12I_[A-Za-z]+_)4-12-", "\\19-12-", id))

# Create 6 columns from id
df = df %>%
  tidyr::extract(id,
                 into = c("block", "plot", "treatment", "sp", "leaf_id", "replicate"),
                 regex = "^([A-Za-z][0-9]+)-([0-9]+)([A-Za-z]+)-([A-Za-z]+)-([0-9]+-[0-9]+-[0-9]+)-([0-9]+)$",
                 remove = FALSE)

# Create subplot (leaf_id without its last number) and leaf (last number of leaf_id)
df <- df %>%
  mutate(subplot = sub("-[0-9]+$", "", leaf_id),
         leaf    = sub(".*-([0-9]+)$", "\\1", leaf_id))

# Rebuild id and subplot_id with "-" only (no "_", and a "-" between plot number and treatment)
df <- df %>%
  mutate(id         = paste(block, plot, treatment, sp, leaf_id, replicate, sep = "-"),
         subplot_id = paste(block, plot, treatment, sp, leaf_id, sep = "-"))

# Create plot_block, plot_id and sub_id columns
df <- df %>%
  mutate(plot_block = paste(block, plot, sep = "-"),
         plot_id    = paste(block, plot, treatment, sep = "-"),
         sub_id     = paste(block, plot, treatment, sp, subplot, sep = "-"))

# Reorder columns (all remaining columns, n_corr, p_corr, etc., stay after these)
df <- df %>%
  relocate(block, plot, treatment, sp, subplot, leaf, replicate,
           id, subplot_id, sub_id, plot_id, plot_block, leaf_id)

