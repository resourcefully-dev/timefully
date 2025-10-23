library(dplyr)

dtf <- flextools::energy_profiles |>
    select(
        datetime,
        solar,
        building
    ) |>
    mutate(
        building = ifelse(
            lubridate::wday(datetime, week_start = 1) %in% 6:7,
            building * 0.5,
            building
        )
    )

usethis::use_data(dtf, overwrite = TRUE)
