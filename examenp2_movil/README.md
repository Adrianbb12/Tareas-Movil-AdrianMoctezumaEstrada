# Mis Lugares Favoritos

Aplicación Flutter para guardar lugares personales con foto y ubicación exacta en OpenStreetMap. Usa Supabase Auth, Database y Storage. Cada cuenta solo puede consultar y cambiar sus propios datos mediante RLS.

## Configuración inicial

1. Crea un proyecto en Supabase.
2. En **SQL Editor**, abre `supabase/schema.sql` y ejecuta todo el script. Crea la tabla con políticas RLS y el bucket privado para fotos.
3. En **Project Settings > API Keys**, copia el **Project URL** y una **publishable key**. La clave es la publicable/anon; nunca uses `service_role` dentro de Flutter.
4. Copia `supabase.keys.example.json` como `supabase.keys.json` y reemplaza sus valores. Ese archivo está excluido de Git.
5. En la terminal integrada de VS Code, desde esta carpeta:

```powershell
flutter pub get
flutter run --dart-define-from-file=supabase.keys.json
```

La app usa autenticación por correo y contraseña. Si Supabase pide confirmar correo, abre el enlace que te envíe antes de iniciar sesión.

## Uso

- Crea una cuenta o inicia sesión.
- Toca **Agregar lugar**, escribe nombre, categoría y descripción.
- Toca **Marcar ubicación exacta en el mapa**, acerca el mapa y toca el punto. La pantalla muestra las coordenadas elegidas antes de guardar.
- Agrega una foto desde la galería. Si el nombre es Juan Gallo, aparece la foto de ejemplo adjunta; puedes sustituirla por otra.
- La pestaña **Mapa** muestra todos tus pines. El botón de ubicación solicita permiso al dispositivo para mostrar tu posición actual.
- Busca por nombre, filtra por categoría, edita o elimina desde el menú de cada ficha.

La casa de tu novia no viene precargada: guarda sus coordenadas solamente cuando tú marques el punto y pulses **Guardar lugar**. Las ubicaciones y fotos quedan en tu proyecto Supabase, protegidas por las políticas de propietario incluidas en el SQL.

## Tus lugares para registrar

La app empieza vacía para que cada pin sea exacto y lo confirmes tú. Puedes crear estas fichas:

| Nombre | Categoría | Descripción sugerida |
| --- | --- | --- |
| Juan Gallo | Comida | Mi restaurante favorito: toda la comida está muy buena y tienen excelentes promociones. |
| Casa de mi novia | Personal | Aquí cocinamos, vemos películas y hacemos tarea juntos. |
| Tianguis de las Vías | Paseo | Venimos los domingos, compramos tepache y recorremos los puestos. |
| H‑E‑B Zona Universitaria | Compras | Me gusta buscar las ofertas, aunque la tienda suele ser cara. |
| La Piraña Cubana | Comida | Me gustan los mariscos, el menú tipo buffet y el ambiente agradable. |

Confirma tú cada punto en el mapa. Para Juan Gallo usa la sucursal de Reforma que visitas; la ubicación de la casa se guarda cuando tú la marcas, sin exponer la dirección en la ficha.

## Tecnologías

- Flutter y Dart
- Supabase Auth, Postgres con RLS y Storage privado
- `flutter_map` con teselas de OpenStreetMap
- `geolocator` e `image_picker`
