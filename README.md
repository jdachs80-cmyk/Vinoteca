# Mis vinotecas

App web para gestionar tus vinotecas desde el móvil, compartida con otras personas: espacios (casa, apartamento…), armarios con baldas y huecos, fichas de vino, ventana de consumo e historial de botellas abiertas.

- **Frontend**: un único `index.html`, sin compilar. Se publica gratis en GitHub Pages.
- **Backend**: [Supabase](https://supabase.com) (base de datos Postgres + cuentas de usuario + tiempo real). El plan gratuito sobra para este uso.

## Puesta en marcha (unos 10 minutos)

### 1. Crea el proyecto en Supabase
1. Entra en https://supabase.com, crea una cuenta y pulsa **New project**. Elige la región más cercana (p. ej. *West EU*).
2. Cuando termine de crearse, ve a **SQL Editor → New query**, pega el contenido de [`supabase/schema.sql`](supabase/schema.sql) y pulsa **Run**. Debe terminar con *Success*.

### 2. Conecta la app con tu proyecto
1. En Supabase, ve a **Project Settings → API** y copia la **Project URL** y la clave **anon public**.
2. Pon esos dos valores en [`config.js`](config.js) y guarda el cambio en el repositorio.

La clave *anon* es pública por diseño. Lo que protege los datos son las reglas de `schema.sql`: cada persona solo ve los espacios de los que es miembro. **Nunca** pongas en `config.js` la clave *service_role*.

### 3. Publica en GitHub Pages
1. En GitHub: **Settings → Pages → Build and deployment → Source: Deploy from a branch**. Elige la rama donde está la app y la carpeta `/ (root)`.
2. En un minuto la app estará en `https://<tu-usuario>.github.io/Vinoteca/`.

GitHub Pages gratis solo funciona con repositorios **públicos**. Hacer público el repositorio no expone tus vinos, que están en Supabase y no en el código. Si prefieres mantenerlo privado, Netlify o Cloudflare Pages publican repos privados gratis.

### 4. Ajusta los correos de Supabase
En Supabase, **Authentication → URL Configuration**:
- **Site URL**: la dirección de tu app (`https://<tu-usuario>.github.io/Vinoteca/`).
- **Redirect URLs**: añade esa misma dirección.

Así los enlaces de «confirmar cuenta» y «recuperar contraseña» llevan a tu app. El servidor de correo gratuito de Supabase envía pocos correos por hora. Para más personas, configura un SMTP propio en **Authentication → Emails → SMTP Settings**.

### 5. Instálala en el móvil
Abre la dirección en el móvil y usa **Compartir → Añadir a pantalla de inicio** (iPhone) o **⋮ → Instalar app / Añadir a pantalla de inicio** (Android).

## Compartir un espacio
1. La otra persona abre la app y se crea una cuenta con su correo.
2. Tú pulsas **Compartir**, escribes su correo y **Añadir**. Desde ese momento ve el espacio y los cambios aparecen en tiempo real en los dos móviles.

## Diferencias con la versión de claude.ai
- No hay relleno automático de la ficha con Claude: la ficha se rellena a mano, con enlaces a Vivino y Wine-Searcher para consultar los datos.
- Se entra con correo y contraseña. Para compartir se usa el correo de la otra persona.
- Desaparece la opción «visible para todos»: cada espacio lo ven solo sus miembros.
- Los datos de la versión de claude.ai no se migran.
