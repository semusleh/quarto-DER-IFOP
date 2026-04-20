<img src="img/ifop-horizontal-opt.png" alt="Logo IFOP" width="260"/>

# Plantilla Quarto Libro — Informes de Evaluación de Stock IFOP

Plantilla reproducible para generar informes técnicos de evaluación de stock en formato **PDF** y **HTML** usando [Quarto](https://quarto.org) y R. Incluye portada institucional IFOP, encabezado y pie de página automáticos, tabla de contenidos, numeración de secciones y figuras, y referencias bibliográficas.

Desarrollada por la División de Investigación Pesquera — [Instituto de Fomento Pesquero (IFOP)](https://www.ifop.cl).

---

## Requisitos de software

Instalar en este orden:

### 1. R

Lenguaje base para el análisis de datos.

- Descarga: [https://cran.r-project.org](https://cran.r-project.org)
- Seleccionar el instalador para tu sistema operativo (Windows, macOS o Linux)
- Versión mínima recomendada: R 4.3

### 2. Positron (recomendado) o RStudio

Editor de código con integración nativa para R y Quarto.

- **Positron** (más moderno, recomendado): [https://positron.posit.co](https://positron.posit.co)
- **RStudio** (alternativa): [https://posit.co/download/rstudio-desktop](https://posit.co/download/rstudio-desktop)

> Positron incluye Quarto integrado. Si se usa RStudio, puede ser necesario instalar Quarto por separado (ver paso siguiente).

### 3. Quarto

Motor de publicación que convierte los archivos `.qmd` en PDF y HTML.

- Descarga: [https://quarto.org/docs/get-started](https://quarto.org/docs/get-started)
- Si se usa Positron, Quarto generalmente ya viene incluido. Verificar con `quarto --version` en la terminal.

### 4. TinyTeX (para generar PDF)

Distribución LaTeX liviana que Quarto usa para compilar el PDF. Se instala desde R:

```r
install.packages("tinytex")
tinytex::install_tinytex()
```

La instalación tarda unos minutos. Solo debe hacerse una vez. TinyTeX descarga automáticamente los paquetes LaTeX adicionales que necesite al compilar por primera vez.

### 5. Paquetes R

Instalar desde la consola de R:

```r
install.packages(c(
  "knitr",    # motor de chunks R en Quarto
  "here",     # rutas relativas robustas
  "yaml",     # lectura de _variables.yml desde R
  "tidyverse" # manipulación y visualización de datos
))

# Para leer salidas de modelos SS3:
install.packages("r4ss")
```

### 6. Fuentes tipográficas (para PDF)

El PDF usa **Arial Narrow** (cuerpo de texto) y **Verdana** (títulos). Si estas fuentes no están instaladas, la plantilla usa Latin Modern Roman como alternativa sin generar error.

**Windows:** Arial Narrow y Verdana generalmente ya están instaladas si tienes Microsoft Office. Si no, se pueden obtener desde el [paquete de fuentes de Microsoft](https://docs.microsoft.com/typography).

**macOS:** Verdana viene preinstalada. Arial Narrow requiere Microsoft Office o instalación manual. Para instalar desde terminal:

```bash
# Con Homebrew
brew install --cask font-arial-narrow
```

**Linux (Ubuntu/Debian):**

```bash
sudo apt install ttf-mscorefonts-installer
sudo fc-cache -f -v
```

---

## Cómo usar la plantilla

### Clonar o descargar el repositorio

```bash
git clone https://github.com/tu-usuario/quarto-ifop-libro.git
cd quarto-ifop-libro/template
```

O descargar como ZIP desde el botón verde **Code → Download ZIP** en esta página.

### Compilar el PDF

Desde la terminal, dentro de la carpeta `template/`:

```bash
quarto render --to pdf
```

### Compilar la versión HTML

```bash
quarto render --to html
```

### Compilar ambos formatos

```bash
quarto render
```

El PDF se genera en `template/_book/`. La versión HTML queda en `template/_book/index.html`.

---

## Estructura del proyecto

```
template/
├── _quarto.yml          ← configuración central del libro
├── _variables.yml       ← especie, año, autores (editar al adaptar)
├── index.qmd            ← resumen ejecutivo
├── 02_objetivos.qmd
├── 03_antecedentes.qmd
├── 04_demersal.qmd      ← capítulo con sub-archivos incluidos
├── 05_fup.qmd
├── 06_referencias.qmd
├── styles/
│   ├── doc-settings.tex     ← fuentes, encabezado, pie de página (PDF)
│   ├── portada-completa.tex ← portada y ficha técnica (PDF)
│   └── styles-html.css      ← estilos de la versión HTML
└── img/
    └── Logos/
        ├── ifop-pez-a-opt.png    ← logo para encabezado PDF
        └── ifop-pez-bl-opt.png   ← logo para navbar HTML
```

Para adaptar la plantilla a un nuevo recurso, editar `_variables.yml` con el nombre de la especie, año y autores, y actualizar el texto de la portada en `styles/portada-completa.tex`.

---

## Documentación

La guía completa de uso y edición está en `guia_quarto_ifop.qmd` (o en el PDF compilado `guia_quarto_ifop.pdf`). Cubre la estructura de archivos, cómo cambiar la portada, el encabezado y pie de página, el sistema de `include` para capítulos extensos, manejo de cache y freeze, y cómo integrar modelos externos (SS3, ADMB, JJM).

---

## Contacto

Dr. Selim Musleh Vega  
Correo: [selim.musleh@ifop.cl](mailto:selim.musleh@ifop.cl)  

División de Investigación Pesquera — Departamento de Evaluación de Recursos  
Instituto de Fomento Pesquero (IFOP)  
[www.ifop.cl](https://www.ifop.cl)
