
informacion_app <- gt::html(
  
  paste0(
    '<h4 style="color:#f46572"><b>Machine Learning para predecir los casos de dengue semanales</b></h4> <br>',
   '<p align="justify" style="font-size: .8rem;">La <b>fiebre del dengue</b> es una enfermedad transmitida por mosquitos presente fundamentalmente en zonas tropicales. Cuando se trata de casos graves, esta enfermedad puede llegar a causar la muerte, mientras que en los diagnósticos leves sus síntomas son muy similares a los de la fiebre. Si bien históricamente la enfermedad ha sido más prevalente en el sudeste asiático y en las islas del pacífico, actualmente una proporción sustancial de casos están sucediendo en América Latina. </p>
      <p align="justify" style="font-size: .8rem;">Así pues, más allá de la aplicación de políticas de vacunación, <b>la capacidad para estimar el número futuro de casos que afrontará una región es fundamental a la hora de definir tanto estrategias de prevención como de preparación</b>. Por ello, trabajar en el desarrollo de estos modelos es una tarea de gran relevancia social, y pone de manifiesto la <b>utilidad pública y social de las técnicas de Machine Learning</b>.</p>
      <p align="justify" style="font-size: .8rem;">Ante este contexto, <a href="https://www.drivendata.org/competitions/44/dengai-predicting-disease-spread/page/80/" target="_blank">DRIVENDATA</a> proporciona información histórica acerca del número de casos semanales para dos ciudades: <b>San Juan</b> (en Puerto Rico) e <b>Iquitos</b> (en Perú), junto con información de hasta 23 variables medioambientales relativas a la temperatura, la precipitación o la vegetación. Por tanto, a partir de la información medioambiental de la semana actual, se puede estimar el número de casos de dengue de la semana próxima. Además, utilizando información medioambiental estimada se puede ampliar el rango temporal de la predicción.</p>
      <p align="justify" style="font-size: .8rem;">Esta aplicación es una versión <i>beta</i> pensada para ser utilizada por las administraciones públicas y autoridades sanitarias de las respectivas regiones. Desde la <i>app</i> se puede subir un archivo con la información medioambiental y, de forma automatizada, se obtienen las predicciones semanales del número de casos de dengue para ambas ciudades.</p>
      <p align="justify" style="font-size: .8rem;">Este proyecto se enmarca dentro del <a href="https://drive.google.com/file/d/1RgHJAV02pYTGyEKTPG6ylvcI_CHZMrCb/view?usp=sharing" target="_blank">Trabajo de Final de Máster</a> del Máster en Big Data & <i>Data Science</i> de la <a href="https://www.ucm.es/" target="_blank">Universidad Complutense de Madrid</a>  y la empresa <a href="https://www.nticmaster.es/master-data-science/" target="_blank">NTIC</a>. El código de la <i>shiny app</i> puede consultarse en su <a href="https://github.com/Adan-gz/SHINYAPP_TFM_Master_BIG_DATA" target="_blank">repositorio de Github</a>.
      <br>
      <br>
      <br>'
    
  )
)


explicacion_app <- gt::html(
  
  paste0(
    '<h4 style="color:#f46572"><b>Cómo realizar la predicción</b></h4> <br>',
    '<p align="justify" style="font-size: .8rem;">A priori, debería de haber un departamento encargado de recoger la información semanal relativa a las 23 variables medioambientales. Este archivo se subiría en formato .csv a la aplicación y, automáticamente, se obtendría la estimación. </p>
      <p align="justify" style="font-size: .8rem;">No obstante, se proporcionan hasta 3 bases de datos a modo de ejemplo con el nombre de ‘Muestra’. La número 3 está diseñada incorrectamente a propósito para comprobar qué ocurre cuando el formato del archivo no es el adecuado. Además, se facilita una plantilla por si se quisiera rellenar con sus propios datos semanales.</p>
      <p align="justify" style="font-size: .8rem;">Por tanto, para probar la <i>app</i> puede descargar una de las muestras y subirla en el apartado de <i>Realiza la predicción/Datos</i> en formato .csv. En el subapartado de <i>Checks</i> se mostrará una tabla con las comprobaciones del formato, indicando si está todo correcto o si se ha producido algún error específico. Además, si se detecta algún valor "extraño" verá un aviso, por si acaso se tratara de un error. En el subapartado de <i>Resumen de la información</i> se visualizan las variables del archivo subido.</p>
      <p align="justify" style="font-size: .8rem;">Dos cuestiones a tener en cuenta: se debe indicar en cada fila la ciudad (“sj” para San Juan e “iq” para Iquitos) y la semana en formato yyyy-mm-dd (p.ej., 2011-12-02). Recuerda que la información medioambiental semanal proporcionada sirve para predecir el número de casos de dengue de la semana próxima. Si se tiene alguna duda más sobre el formato de las variables puede consultar este <a href="https://www.drivendata.org/competitions/44/dengai-predicting-disease-spread/page/82/" target="_blank">enlace</a>.</p>
      <p align="justify" style="font-size: .8rem;">La predicción se realiza en tres pasos: (1) se separan los datos de la ciudad de San Juan y de Iquitos en dos bases de datos diferentes; (2) los datos de cada ciudad son tratados de forma diferenciada, lo que en este contexto se conoce como <i>feature engineering</i>; y (3) se realizan las predicciones para cada ciudad mediante un modelo específico para cada una, concretamente un modelo de árboles de regresión XGBOOST.  </p>
      <p align="justify" style="font-size: .8rem;">En la siguiente tabla puede verse una muestra de los datos: </p>
      <br>
      '
    
  )
)


