# Feature Port - Plugin para Claude Code

> Sistema de analisis y migracion de funcionalidades entre proyectos. Analiza features de cualquier proyecto, las extrae en aislamiento, y las porta a otros proyectos adaptandolas completamente a la arquitectura, convenciones y sistema de roles del destino.

**Version**: 1.1.0
**Author**: Jose Diaz
**Ubicacion**: `~/.claude/plugins/feature-port/`

---

## Que es Feature Port

Feature Port resuelve un problema comun cuando trabajas con multiples proyectos simultaneamente: implementas algo bueno en un proyecto y quieres replicarlo en otro, pero no quieres explicarlo todo de nuevo ni copiar codigo a mano.

Este plugin permite:
1. **Analizar** las features de cualquier proyecto en tu directorio de desarrollo
2. **Extraer** una feature especifica entendiendo su esencia (separada de la implementacion)
3. **Portar** esa feature a otro proyecto, adaptandola completamente
4. **Comparar** como la misma feature esta implementada en dos proyectos diferentes

El directorio base de todos los proyectos es `/Users/josediaz/Dev/code/`.

---

## Componentes del Sistema

El plugin tiene 5 componentes:

| Componente | Tipo | Invocacion | Modelo | Proposito |
|-----------|------|------------|--------|-----------|
| `/feature-analyze` | Skill | Manual | Sonnet | Escanea un proyecto y lista sus features |
| `/feature-port` | Skill | Manual | Opus | Migra una feature de proyecto A a proyecto B |
| `/feature-compare` | Skill | Manual | Sonnet | Compara una feature entre dos proyectos |
| `feature-scanner` | Agent | Interno | Sonnet | Escanea estructura y detecta features |
| `feature-extractor` | Agent | Interno | Opus | Analisis profundo de una feature especifica |

---

## /feature-analyze - Descubrir Features

Escanea un proyecto completo y devuelve un inventario categorizado de todas sus features.

### Uso

```
/feature-analyze [nombre-proyecto]
```

### Ejemplos

```
/feature-analyze almasuite.coach
/feature-analyze fittrack-pro
/feature-analyze mi-saas-app
```

### Que hace

1. Valida que el proyecto existe en `/Users/josediaz/Dev/code/`
2. Lee documentacion existente (README, FEATURE_TRACKING, etc.)
3. Lanza el agente `feature-scanner` para escaneo profundo
4. Presenta las features organizadas por categoria:
   - **KILLER**: Diferenciadores unicos, alto valor
   - **CORE**: Esenciales para el producto
   - **ENHANCEMENT**: Agregan valor pero no son criticas
   - **UTILITY**: Herramientas internas/admin
   - **INFRASTRUCTURE**: Habilitan features pero no son features en si

5. Cada feature incluye:
   - Descripcion de que hace
   - Archivos involucrados
   - Modelo de datos
   - Dependencias externas
   - Rating de portabilidad (1-5)
   - Rating de complejidad (1-5)

6. Al final, recomienda las mejores candidatas para portar

### Output

Por defecto muestra en consola. Si pides guardar, crea `docs/FEATURE_ANALYSIS_[DATE].md`.

---

## /feature-port - Migrar Features

Migra una feature especifica de un proyecto a otro, adaptandola completamente.

### Uso

```
/feature-port [feature] from [proyecto-origen] to [proyecto-destino]
```

### Ejemplos

```
/feature-port chatbot from almasuite.coach to fittrack-pro
/feature-port audit-logs from proyecto-a to proyecto-b
/feature-port notification-system from saas-one to saas-two
```

### Proceso (6 fases)

#### Fase 1: Extraccion (READ-ONLY en origen)
- Lanza el agente `feature-extractor`
- Mapea TODOS los archivos de la feature
- Extrae modelo de datos, logica de negocio, patrones UI
- Genera un BLUEPRINT technology-agnostic

#### Fase 2: Analisis del Destino
- Analiza tech stack, patrones, convenciones del proyecto destino
- Lee su sistema de roles, design system, features existentes
- Identifica equivalencias y diferencias con el origen

#### Fase 3: Plan de Adaptacion
- Crea un plan detallado que mapea origen → destino
- Incluye: traduccion de tech stack, cambios de data model, adaptacion de roles
- Lista archivos a crear/modificar, dependencias, variables de entorno

#### Fase 4: Aprobacion del Usuario
- **PARA y presenta el plan** antes de tocar codigo
- Espera aprobacion, cambios, o cancelacion

#### Fase 5: Implementacion
- Ejecuta en orden: DB → Types → Backend → Frontend → Wiring → Docs
- Respeta las convenciones del proyecto destino
- Usa componentes y utilidades existentes del destino

#### Fase 6: Validacion
- Type check, lint, build
- Screenshots con Playwright si esta disponible
- Validacion contra roles si existe Role Empathy Analysis

### Reglas Clave

- **NUNCA** modifica el proyecto origen (solo lectura)
- **SIEMPRE** presenta el plan antes de implementar
- **ADAPTA** al destino en vez de copiar del origen
- **RESPETA** las convenciones existentes del destino
- **NO** trae dependencias duplicadas (usa equivalentes del destino)

---

## /feature-compare - Comparar Implementaciones

Compara como la misma feature (o features similares) esta implementada en dos proyectos diferentes. Muestra un analisis side-by-side.

### Uso

```
/feature-compare [feature] in [proyecto-a] vs [proyecto-b]
```

### Ejemplos

```
/feature-compare chatbot in almasuite.coach vs fittrack-pro
/feature-compare auth in proyecto-a vs proyecto-b
/feature-compare notifications in saas-one vs saas-two
```

### Que hace

1. Analiza la feature en ambos proyectos **en paralelo**
2. Construye una matriz de comparacion en 6 dimensiones:
   - **Arquitectura**: Estructura de archivos, patrones, modularidad
   - **Data Model**: Tablas, campos, relaciones, convenciones
   - **Business Logic**: Operaciones, validaciones, permisos
   - **UI/UX**: Paginas, componentes, estados, responsive
   - **Integraciones**: Servicios externos, dependencias
   - **Calidad**: Tests, type safety, error handling
3. Genera un **Scorecard** numerico (X/10) por dimension
4. Recomienda que tomar de cada proyecto ("Best of Both Worlds")

### Cuando usarlo

- **Post-port**: Despues de `/feature-port`, para verificar que la adaptacion es correcta
- **Pre-port**: Para decidir CUAL implementacion portar si tienes la misma feature en 2+ proyectos
- **Aprendizaje**: Para entender diferentes enfoques al mismo problema
- **Audit**: Para detectar gaps o mejoras en una implementacion vs otra

### Output

Tabla comparativa detallada en consola. Si pides guardar, crea `docs/FEATURE_COMPARISON_[feature]_[date].md`.

---

## Agentes Internos

### feature-scanner
- **Proposito**: Escaneo rapido de features de un proyecto
- **Modelo**: Sonnet (rapido, suficiente para escaneo)
- **Usado por**: `/feature-analyze`
- **Escanea**: Routes, APIs, schemas, services, components, navigation
- **No invocable directamente** por el usuario

### feature-extractor
- **Proposito**: Analisis profundo de UNA feature especifica
- **Modelo**: Opus (necesita razonamiento complejo)
- **Usado por**: `/feature-port`
- **Produce**: File map, data model, business logic, UI patterns, blueprint
- **No invocable directamente** por el usuario

---

## Flujo Completo Recomendado

### Escenario: "Quiero copiar el chatbot de almasuite a mi otro proyecto"

```
1. /feature-analyze almasuite.coach
   → Ve todas las features, identifica "AI Chatbot" como KILLER feature

2. /feature-port chatbot from almasuite.coach to otro-proyecto
   → Extrae el chatbot en aislamiento
   → Analiza otro-proyecto
   → Presenta plan de adaptacion
   → [Usuario aprueba]
   → Implementa adaptado al destino

3. /ux-validate (si el destino tiene role empathy analysis)
   → Valida que el chatbot se ajusta a los roles del destino
```

### Escenario: "Tengo auth en dos proyectos, cual es mejor?"

```
1. /feature-compare auth in proyecto-a vs proyecto-b
   → Comparacion side-by-side en 6 dimensiones
   → Scorecard: A=7/10, B=9/10
   → "B tiene mejor error handling y 2FA, A tiene mejor UX de onboarding"

2. /feature-port auth from proyecto-b to proyecto-a
   → Porta la implementacion superior, adaptada al destino
```

### Escenario: "Quiero ver que features tiene proyecto-x"

```
1. /feature-analyze proyecto-x
   → Lista completa con categorias y ratings
   → "Ah, el sistema de audit logs se ve bien"

2. (Mas tarde) /feature-port audit-logs from proyecto-x to proyecto-y
```

---

## Donde Vive Cada Cosa

```
~/.claude/plugins/feature-port/
├── plugin.json              ← Manifiesto del plugin
├── README.md                ← Este archivo
├── skills/
│   ├── feature-analyze.md   ← Skill: /feature-analyze
│   ├── feature-port.md      ← Skill: /feature-port
│   └── feature-compare.md   ← Skill: /feature-compare
└── agents/
    ├── feature-scanner.md   ← Agente: escaneo de features
    └── feature-extractor.md ← Agente: extraccion profunda
```

---

## Integracion con Otros Plugins

### Con Role Empathy (`/role-empathy`)
- Si el proyecto destino tiene `docs/ROLE_EMPATHY_ANALYSIS.md`, el port adapta la feature a los roles del destino
- Despues del port, se recomienda `/ux-validate` para verificar la adaptacion

### Con Design System
- Si el destino tiene `docs/DESIGN_SYSTEM_ANALYSIS.md`, el port adapta la UI al design system

### Con Feature Tracking
- Despues del port, actualiza `docs/FEATURE_TRACKING.md` en el proyecto destino
- Actualiza `docs/CHANGELOG.md` si existe

---

## Preguntas Frecuentes

### Puede portar entre tech stacks diferentes?
Si. El agente `feature-extractor` genera un blueprint technology-agnostic. La fase de adaptacion traduce al tech stack del destino.

### Modifica el proyecto origen?
Nunca. El origen es siempre de solo lectura.

### Que pasa si la feature ya existe parcialmente en el destino?
El plan de adaptacion identifica solapamientos y solo porta lo que falta.

### Funciona con proyectos que no son JavaScript/TypeScript?
Si. El scanner y extractor analizan cualquier tipo de proyecto (Python, Go, Rust, etc.).

### Puedo portar multiples features a la vez?
Recomendacion: portar una a la vez. Cada feature puede tener dependencias y es mejor validar cada una antes de continuar.

### Que pasa si cancelo durante la implementacion?
Las fases 1-4 son read-only. La fase 5 (implementacion) crea archivos nuevos que se pueden revertir con git.

### Puedo comparar features que se llaman diferente en cada proyecto?
Si. `/feature-compare` busca por funcionalidad, no por nombre. Si en un proyecto es "audit-logs" y en otro es "activity-tracker", lo detecta si haces la comparacion.

---

## Proyectos Donde Se Ha Usado

_(Se actualizara conforme se use)_

| Fecha | Feature | Origen | Destino | Resultado |
|-------|---------|--------|---------|-----------|
| - | - | - | - | - |
