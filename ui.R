

library(shiny)
library(DT)
library(recipes)
library(parsnip)
library(dplyr)
library(plotly)
library(gt)
library(markdown) # requerido por shinyapps
library(xgboost) # requerido por shinyapps
library(shinydashboard)
# library(ggplot2)
# library(patchwork)
# library(recipes)
# library(parsnip)
# library(flextable)


ui <- fluidPage( title = 'RomenAdanGz - TFM Big Data',
                 lang = 'es', 
                 theme = bslib::bs_theme(bootswatch = 'minty', primary = '#f68185'),

                 
                 
# navbarPage - title ------------------------------------------------------
                 
 navbarPage( id = 'tabs',
             
             footer =  includeMarkdown("www/footer.md"),
             
             
             tags$style(HTML("
                             .center {
                                display: block;
                                margin-left: auto;
                                margin-right: auto;
                                margin-bottom: 0px;
                                padding-bottom: 0px;
                                width: 50%;
                                }
                                " ) ),
             
             title ='Predicción del número de casos de dengue semanales    ', 


# Information -------------------------------------------------------------

       # conditionalPanel(
       # condition = "output.es_correcta == true",
       tabPanel('Presentación',
               
               fluidRow(
                 column(2),
                 column(8,
                        br(),
                        informacion_app,
                        imageOutput('mapa'),
                        br(),br(),br()
                 ),
                 column(2)
               ) # fluidRow
       ), #tabPanel


# Explicación ------------------------------------------
                             
     tabPanel('Cómo realizar la predicción',
              fluidRow(
                column(2, br(),br(),
                       downloadButton('muestra_1',
                                      label = gt::html('<span style="font-size: .8rem;">Muestra 1</span>'),
                       ),
                       downloadButton('muestra_2',
                                      label = gt::html('<span style="font-size: .8rem;">Muestra 2</span>'),
                         ), 
                       br(), br(),
                       downloadButton('muestra_3',
                                      label = gt::html('<span style="font-size: .8rem;">Muestra 3 (error)</span>')),
                       br(),br(),br(),
                       downloadButton('data_plantilla',
                                      label = gt::html('<span style="font-size: .8rem;">Plantilla</span>') ),
                       ),
                column(8,
                       br(),
                       explicacion_app,
                       DT::dataTableOutput('muestra_data'),
                       br(),br(),br()
                ),
                column(4)
              )
             ),#tabPanel


# Predicción --------------------------------------------------------------

 navbarMenu('Realiza la predicción',

## Datos -------------------------------------------------------------------

    tabPanel('Datos', 
      fluidRow(
             column(2,br(),br(),
                    fileInput("file",label =  "Sube tu CSV",
                              buttonLabel = 'Buscar',
                              placeholder = '...',
                              multiple = FALSE,
                              accept = ".csv") ),
             column(8,
                    br(),
                    gt::html('<span style="font-size: 1.2rem; color:#f46572;"><b>Estos son los datos que has subido</b></span>'),
                    DT::dataTableOutput('file_head') )
             ) ),

## Checks ------------------------------------------------------------------

    tabPanel('Checks',
        fluidRow(
             column(2),
             column(8,
                  br(),
                  gt::html('<span style="font-size: 1.2rem; color:#f46572;"><b>¿Deberías checkear alguna variable?</b></span>'),
                  uiOutput('file_checks'),
                  br()
           )
           )
          ),#tabPanel
    

## resumen -----------------------------------------------------------------

    tabPanel('Resumen de la información',
             fluidRow(
               
               column(2),
               column(8,
                      gt::html('<span style="font-size: 1.2rem; color:#f46572;"><b>Evolución temporal de las variables</b></span>'),
                      shinycssloaders::withSpinner( plotOutput('p_temp_sj'), color = '#f46572' ),
                      br(),
                      shinycssloaders::withSpinner( plotOutput('p_temp_iq'), color = '#f46572' ),
                      br(),
                      gt::html('<span style="font-size: 1.2rem; color:#f46572;"><b>Distribución entre las variables</b></span>'),
                      shinycssloaders::withSpinner( plotOutput('p_dist_sj'), color = '#f46572' ),
                      br(),
                      shinycssloaders::withSpinner( plotOutput('p_dist_iq'), color = '#f46572' ),
                      br(),
                      gt::html('<span style="font-size: 1.2rem; color:#f46572;"><b>Análisis de Componentes Principales</b></span>'),
                    fluidRow(
                      box( shinycssloaders::withSpinner( plotOutput('p_pca_sj'), color = '#f46572' ), width = 6),
                      # br(),
                      box( shinycssloaders::withSpinner( plotOutput('p_pca_iq'), color = '#f46572' ), width = 6)
                      ),
                      br(),
                      )
               
             )
             ),
    

# Estimacion --------------------------------------------------------------

    tabPanel('Estimación',
      fluidRow( 
        # column(.5),
        column(6,
               gt::html('<span style="font-size: 1.2rem; color:#f46572;"><b>Estimaciones de los casos de dengue semanales</b></span>'),
               br(),
               shinycssloaders::withSpinner( DT::dataTableOutput('df_predictions'), color = '#f46572' ),
               br(),
               downloadButton('data_predicciones',
                              label = gt::html('<span style="font-size: .8rem;">Descargar predicciones en csv</span>') ),
                              
                       ),
        # column(1),
          column(6,
              gt::html('<span style="font-size: 1.2rem; color:#f46572;"><b>Evolución temporal</b></span>'),
              radioButtons("select_CI", label = gt::html('<b>Intervalo de confianza:'), 
                          choices = c('0.80','0.90','0.95','0.99'), selected = '0.95', inline = T),
              shinycssloaders::withSpinner( plotlyOutput('plot_predictions_sj'), color = '#f46572' ),
              shinycssloaders::withSpinner( plotlyOutput('plot_predictions_iq'), color = '#f46572' ),
              br()
                  )
        # column(.5)
           ) # fluidRow

    ) # tabPanel

# close  -----------------------------------------------------------------

  ), #navbarMenu
         
 )#navbarPage
         
)# fluidP