# Skeleton Widgets Documentation

Este directorio contiene widgets skeleton optimizados para mejorar la experiencia de usuario y el performance durante la carga de contenido.

## Tipos de Skeleton Widgets

### 1. Skeleton Widgets Animados (`skeleton_widgets.dart`)
Incluyen una animación shimmer suave que proporciona un feedback visual atractivo.

**Cuándo usar:**
- Cuando la experiencia visual es prioritaria
- En pantallas principales donde el usuario espera un diseño pulido
- Cuando el performance no es crítico

**Widgets disponibles:**
- `SkeletonContainer` - Contenedor base con animación shimmer
- `TagChipsSkeleton` - Para chips de tags horizontales
- `MangaCardSkeleton` - Card individual de manga
- `SearchResultsSkeleton` - Grid de resultados de búsqueda
- `HorizontalMangaListSkeleton` - Lista horizontal de mangas
- `PopularMangaGridSkeleton` - Grid de mangas populares

### 2. Skeleton Widgets Simples (`skeleton_widgets.dart`)
Versión sin animación de los skeletons para mejor performance.

**Cuándo usar:**
- Cuando necesitas un balance entre UX y performance
- En listas largas o grids con muchos elementos
- Como alternativa rápida a los animados

**Widgets disponibles:**
- `SimpleSkeleton` - Contenedor base sin animación
- `SimpleTagChipsSkeleton` - Chips sin animación

### 3. Ultra-Lightweight Skeletons (`lightweight_skeleton.dart`)
Skeletons optimizados al máximo para situaciones de performance crítico.

**Cuándo usar:**
- En dispositivos de gama baja
- Cuando detectas problemas de performance
- En listas muy largas (100+ elementos)
- Durante pruebas de performance

**Widgets disponibles:**
- `UltraLightSkeleton` - Contenedor base ultra-optimizado
- `UltraLightTagChipsSkeleton` - Chips ultra-ligeros
- `UltraLightMangaCard` - Card de manga ultra-optimizada
- `UltraLightSearchResults` - Grid de búsqueda ultra-ligero
- `UltraLightHorizontalList` - Lista horizontal ultra-ligera
- `UltraLightPopularGrid` - Grid popular ultra-ligero
- `UltraLightImageSkeleton` - Placeholder de imagen minimalista

## Uso en el Código

### Implementación Básica

```dart
import 'package:mangaapp/features/shared/widgets/skeleton_widgets.dart';

// Para cargar tags
if (isLoading) {
  return const SimpleTagChipsSkeleton();
}

// Para resultados de búsqueda
if (isSearching) {
  return const SearchResultsSkeleton();
}
```

### Implementación con Performance Crítico

```dart
import 'package:mangaapp/features/shared/widgets/lightweight_skeleton.dart';

// Activar modo ultra-ligero
static const bool useUltraLightSkeletons = true;

if (isLoading) {
  return useUltraLightSkeletons
      ? const UltraLightTagChipsSkeleton()
      : const SimpleTagChipsSkeleton();
}
```

### Configuración Dinámica

En los archivos `search_page.dart` y `home_page.dart`, puedes cambiar entre diferentes tipos de skeletons modificando la constante:

```dart
// Cambiar a true para máximo performance
static const bool useUltraLightSkeletons = false;
```

## Comparación de Performance

| Tipo | Memoria | CPU | Suavidad Visual | Uso Recomendado |
|------|---------|-----|-----------------|-----------------|
| Animado | Alta | Alta | ⭐⭐⭐⭐⭐ | UX prioritaria |
| Simple | Media | Baja | ⭐⭐⭐⭐ | Balance UX/Performance |
| Ultra-Light | Baja | Muy Baja | ⭐⭐⭐ | Performance crítico |

## Mejores Prácticas

### ✅ Buenas Prácticas
- Usa skeletons que coincidan con el layout final
- Mantén las proporciones similares al contenido real
- Usa colores que se adapten al tema de la app
- Implementa skeletons para todos los estados de carga principales

### ❌ Evitar
- No usar skeletons muy diferentes al contenido final
- No sobrecargar con demasiadas animaciones
- No usar skeletons animados en listas muy largas
- No hardcodear colores sin considerar dark/light theme

## Personalización

### Colores
Los skeletons se adaptan automáticamente al tema de la aplicación:
- **Light theme:** `Colors.grey[300]` y `Colors.grey[100]`
- **Dark theme:** `Colors.grey[800]` y `Colors.grey[700]`

### Tamaños y Formas
Todos los widgets skeleton aceptan parámetros de personalización:

```dart
SkeletonContainer(
  width: 100,
  height: 20,
  borderRadius: BorderRadius.circular(10),
  margin: EdgeInsets.all(8),
)
```

## Testing Performance

Para probar different tipos de skeletons:

1. **Herramientas de Flutter:**
   ```bash
   flutter run --profile
   flutter run --trace-skia
   ```

2. **Monitoreo en app:**
   - Observa el consumo de CPU en DevTools
   - Usa el Performance Overlay: `flutter run --enable-software-rendering`

3. **Cambio rápido de tipos:**
   - Modifica las constantes `useUltraLightSkeletons` en cada página
   - Haz hot reload para comparar inmediatamente

## Roadmap

### Próximas mejoras:
- [ ] Skeleton widgets adaptativos basados en el performance del dispositivo
- [ ] Métricas automáticas de performance
- [ ] Generador automático de skeletons basado en widgets existentes
- [ ] Soporte para skeletons con contenido parcial (Progressive Loading)

---

**Nota:** Si encuentras problemas de performance incluso con los ultra-light skeletons, considera implementar lazy loading o paginación en lugar de mostrar muchos elementos simultáneamente.
