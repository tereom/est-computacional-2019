library(mxmaps)
library(fs)

# Download data
# source: https://www.inegi.org.mx/programas/intercensal/2015/default.html#Tabulados
edu_path <- "https://www.inegi.org.mx/contenidos/programas/intercensal/2015/tabulados/06_educacion_" 
home_path <- "https://www.inegi.org.mx/contenidos/programas/intercensal/2015/tabulados/12_hogares_"

edu_path_local <- "data/municipios/edu"
use_directory(edu_path_local)
home_path_local <- "data/municipios/home"
use_directory(home_path_local)

download_files_inegi <- function(state_abbr) {
    # education
    state_edu_path <- paste0(edu_path, state_abbr, ".xls")
    download.file(state_edu_path, destfile = fs::path(edu_path_local, 
        basename(state_edu_path)))
    # home
    state_home_path <- paste0(home_path, state_abbr, ".xls")
    download.file(state_home_path, destfile = fs::path(home_path_local, 
        basename(state_home_path)))
}
state_abbrs <- df_mxstate %>% 
    pull(state_abbr_official) %>% 
    tolower %>% 
    str_remove(fixed(".")) %>% 
    str_remove(" ")

state_abbrs[4] <- "cam"
state_abbrs[9] <- "cdmx"

# read and tidy data

read_edu <- function(state_path) {
    readxl::read_excel(path = state_path, sheet = 3, skip = 8) %>% 
        select(state = ...1, municipio = ...2, age_bracket = ...3, est = ...4, 
            reads_writes = Total...8, prop_male = Hombres...9, 
            prop_female = Mujeres...10) %>% 
        filter(!is.na(state), municipio != "Total", est == "Valor") %>% 
        select(-est)
}

read_edu <- function(state_path) {
    df_readwrite <- readxl::read_excel(state_path, sheet = 2, skip = 8) %>% 
        select(state = ...1, municipio = ...2, est = ...3, 
            reads_writes = Total...7) %>% 
        filter(!is.na(state), municipio != "Total", est == "Valor") %>% 
        select(-est)
    df_schoolyears <- readxl::read_excel(state_path, sheet = 5, skip = 9) %>% 
        select(state = ...1, municipio = ...2, sex = ...3, est = ...4, 
            avg_schoolyears = ...17) %>% 
        filter(!is.na(state), municipio != "Total", est == "Valor") %>% 
        select(-est)
    df_edu <- df_schoolyears %>% 
        spread(sex, avg_schoolyears) %>% 
        rename(avg_schoolyears_male = Hombres, avg_schoolyears_female = Mujeres, 
            avg_schoolyears = Total) %>% 
        inner_join(df_readwrite)
}
edu_paths <- dir_ls(path("data", "municipios", "edu"))
df_edu <- map_df(edu_paths, read_edu)

read_home <- function(state_path) {
    readxl::read_excel(path = state_path, sheet = 3, skip = 8) %>% 
        select(state = ...1, municipio = ...2, sex_lead = ...3, homes = ...4, 
            family_homes = Total...7, no_family_homes = Total...12, 
            est = ...5, nuclear = Nuclear, unipersonal = Unipersonal) %>% 
        filter(!is.na(state), municipio != "Total", sex_lead == "Total",
            est == "Valor", homes == "Hogares") %>% 
        select(-est, -sex_lead, -homes)
}
home_paths <- dir_ls(path("data", "municipios", "home"))
df_home <- map_df(home_paths, read_home)

df_mun_excel <- df_edu %>% 
    left_join(df_home, by = c("state", "municipio")) %>% 
    mutate(
        state_code = str_sub(state, 1, 2), 
        municipio_code = str_sub(municipio, 1, 3)
    ) %>% 
    select(-state, -municipio) 
df_mun <- df_mxmunicipio %>% 
    left_join(df_mun_excel) %>% 
    mutate(
        prop_indigenous = indigenous / pop, 
        pop_cat = Hmisc::cut2(pop, g = 6), 
        is_metro = !is.na(metro_area)
    )


fin_2014 <- fin %>% 
    filter(anio == 2014) %>% 
    mutate(state_code = str_sub(Clave, 1, 2),
        municipio_code = str_sub(Clave, 3, 5)
        )

cohesion_rezago <- read_csv("data/cohesion_rezago_social.csv")

df_cohesion_rezago <- cohesion_rezago %>% 
    mutate(state_code = Cve_Ent, 
        municipio_code = str_sub(Cve_Mun, 3, 5))

df_mun <- df_mun %>% 
    left_join(df_cohesion_rezago)

ggplot(df_mun, aes(x = pop, y = Pob_sin_servicios_salud)) +
    geom_point() +
    scale_x_log10()

ggplot(df_mun, aes(x = Viviendas_sin_drenaje, y = Viviendas_sin_lavadora)) +
    geom_point() +
    scale_x_log10()

df_oax <- df_mun %>% 
    filter(state_abbr == "OAX")


ggplot(df_mun, aes(x = Viviendas_sin_lavadora, 
    y =  Viviendas_sin_refrigerador, color = pop_cat,
    label = state_abbr)) +
    geom_point() +
    scale_x_log10()+
    scale_y_log10()

plotly::ggplotly()

### Marginación
usethis::use_zip("http://www.conapo.gob.mx/work/models/CONAPO/Marginacion/Datos_Abiertos/Municipio/02_Municipio/Mapa_de_grado_de_marginacion_por_municipio_2015.rar")

ggplot(df_mun, aes(x = avg_schoolyears_male, y = avg_schoolyears_female)) +
    geom_point(aes(color = avg_schoolyears_male > avg_schoolyears_female), alpha = 0.5) + 
    geom_abline(alpha = 0.5) +
    facet_wrap(~pop_cat)


ggplot(df_mun, aes(x = pop, y = family_homes)) +
    geom_point(alpha = 0.5) + 
    scale_x_log10() +
    scale_y_log10() +
    geom_smooth()

ggplot(df_mun, aes(x = avg_schoolyears, y = reads_writes)) +
    geom_point(alpha = 0.5) + 
    ylim(50, 100) 

ggplot(df_mun, aes(x = state_abbr_official, y = avg_schoolyears)) +
    geom_point(alpha = 0.5) 
ggplot(df_mun, aes(x = pop_cat, y = avg_schoolyears)) +
    geom_jitter(alpha = 0.5) 

ggplot(df_mun, aes(x = pop, y = Inversion_pc, label = state_abbr)) +
    geom_jitter(alpha = 0.5) +
    scale_y_log10() +
    scale_x_log10()
plotly::ggplotly()

usethis::use_zip("https://www.coneval.org.mx/Medicion/MP/Documents/Cohesion_social/Indicadores_cohesion_social_municipio_Mexico_2010-2015.zip")

library(plotly)

df_statecodes <- df_mxstate %>% 
    select(state_code = region, state_name, state_abbr)

nal_2012 <- nal_2012 %>% 
    mutate(
        state_code = str_c("0", edo_id) %>% str_sub(start = -1L-1)
        ) %>% 
    left_join(df_statecodes) %>% 
    select(state_code, state_name, state_abbr, distrito_loc_17,
        casilla:ln_total)

set.seed(938938)
nal_2012_sample <- sample_n(nal_2012, 1500)
ggplot(nal_2012_sample, aes(x = total, y = prd_pt_mc, color = casilla)) +
    geom_point()

