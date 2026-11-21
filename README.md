# Mis vinotecas

App web (un único `index.html`) para gestionar vinotecas: espacios compartidos, armarios con baldas y huecos, fichas de vino rellenadas por Claude (nombre o foto de etiqueta), ventana de consumo e historial de botellas abiertas.

## Importante: dependencias del runtime de Claude

La app usa el runtime de artefactos de claude.ai (`window.claude.use('db' | 'user' | 'sample')`) para:

- **db**: guardar espacios, vinotecas, vinos y consumos (base de datos compartida).
- **user**: identificar a quien la usa y buscar personas para compartir.
- **sample**: rellenar la ficha del vino con Claude.

Fuera de claude.ai (p. ej. abriendo `index.html` en local o en GitHub Pages) se abre en **solo lectura** y no guarda nada. Para usarla fuera hay que sustituir esas llamadas por un backend propio (Firebase, Supabase…) y una API de IA.

Versión publicada: https://claude.ai/artifact/D5uCqzySxQVpkBeHqeD9zX
