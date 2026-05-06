# Role Empathy System - Plugin para Claude Code

> Sistema completo para diseñar software centrado en el usuario.
> Garantiza que cada feature se construya desde la perspectiva de quien la usa.

**Version**: 1.0.0
**Autor**: Jose Diaz
**Ubicacion**: `~/.claude/plugins/role-empathy/`

---

## Que es el Role Empathy System

Es un sistema de 3 capas que hace que Claude Code siempre piense
en los usuarios de lo que construye:

```
Capa 1: Principio en Global CLAUDE.md (siempre activo, automatico)
Capa 2: Hook SessionStart (detecta si el proyecto tiene roles definidos)
Capa 3: Skills invocables (analisis profundo bajo demanda)
```

### Problema que resuelve

Cuando desarrollas un SaaS con multiples roles (admin, owner, team, end user),
es facil construir features que funcionan tecnicamente pero no estan
pensadas para quien las usa. El role empathy system fuerza a considerar
cada rol ANTES de implementar.

---

## Componentes del Sistema

### 1. Principio Global (automatico)

**Ubicacion**: `~/.claude/CLAUDE.md` (seccion "Role Empathy Principle")

**Que hace**: En CADA conversacion, la IA tiene presente el principio de
"piensa en quien usa esto". Es una directriz corta (~15 lineas) que no
consume muchos tokens pero mantiene la mentalidad activa.

**Ejemplo de efecto**: Si le pides "implementa el dashboard", la IA
automaticamente se pregunta "para que rol?" y diseña la UX
segun el perfil de ese rol.

No necesitas hacer nada. Esta siempre activo.

---

### 2. Hook SessionStart (automatico)

**Ubicacion**: `~/.claude/plugins/role-empathy/hooks/session-start.md`

**Que hace**: Al iniciar cada conversacion de Claude Code, verifica si
el proyecto actual tiene un archivo `docs/ROLE_EMPATHY_ANALYSIS.md`.

- Si existe: te avisa que los roles estan definidos y seran considerados
- Si no existe: te sugiere crear uno con `/role-empathy`

No necesitas hacer nada. Se ejecuta solo.

---

### 3. Skill: /role-empathy (invocable)

**Ubicacion**: `~/.claude/plugins/role-empathy/skills/role-empathy.md`
**Modelo**: Claude Opus (usa el modelo mas potente por la complejidad)

**Cuando usarlo**:
- Al iniciar un proyecto nuevo con multiples roles de usuario
- Cuando agregas una feature importante que afecta a varios roles
- Cuando quieres revisar/actualizar el analisis existente
- Cuando un nuevo rol aparece en el sistema

**Como usarlo**:
```
Tu: /role-empathy
```

**Que hace** (6 fases):

| Fase | Que hace | Output |
|------|----------|--------|
| 1. Role Discovery | Escanea DB schema, auth, rutas para encontrar todos los roles | Lista de roles encontrados |
| 2. Persona Generation | Para cada rol: quien es, sus miedos, motivaciones, nivel tecnico | Ficha de persona por rol |
| 3. Tool & Feature Mapping | Que herramientas necesita cada rol, que KPIs ve, que acciones hace | Dashboard spec por rol |
| 4. UX Principles | Densidad visual, tono emocional, mobile priority, accesibilidad | Guia UX por rol |
| 5. Inter-Role Flows | Como fluyen los datos entre roles, donde se cruzan | Diagramas de flujo |
| 6. Competitive Benchmarking | Compara contra competidores documentados | Tabla comparativa |

**Output**: Genera o actualiza `docs/ROLE_EMPATHY_ANALYSIS.md`

**Ejemplo**:
```
Tu: Estoy empezando un proyecto de gestion de clinicas. /role-empathy

IA: [escanea el codebase]
    Roles encontrados: admin, clinic_owner, doctor, nurse, patient
    [genera persona para cada uno]
    [define herramientas por rol]
    [documenta todo en docs/ROLE_EMPATHY_ANALYSIS.md]
```

---

### 4. Skill: /ux-validate (invocable)

**Ubicacion**: `~/.claude/plugins/role-empathy/skills/ux-validate.md`
**Modelo**: Claude Sonnet (rapido, suficiente para validacion)

**Cuando usarlo**:
- Despues de implementar una feature
- Antes de hacer merge/PR
- Cuando quieres verificar que no olvidaste ningun rol

**Como usarlo**:
```
Tu: Acabo de implementar la pagina de clientes. /ux-validate
```

**Que hace**:
1. Lee el `docs/ROLE_EMPATHY_ANALYSIS.md` del proyecto
2. Identifica que roles usan la feature que implementaste
3. Verifica contra los criterios de cada rol
4. Opcionalmente usa Playwright para tomar screenshots
5. Reporta PASS / NEEDS WORK / FAIL por rol

**Criterios de validacion por tipo de rol**:

| Tipo de rol | Que valida |
|-------------|-----------|
| Admin | Densidad de datos, bulk actions, impersonation, metricas |
| Business owner | KPIs visibles sin scroll, acciones claras, time-to-insight <5s |
| Team member | Cola de tareas prominente, permisos claros, comunicacion accesible |
| End user | Mobile-first, tono emocional correcto, progreso visible, minima complejidad |

**Ejemplo de output**:
```
ROLE: Coach
FEATURE: Client list page
STATUS: NEEDS WORK
FINDINGS:
  - No muestra "ultimo check-in" (critico segun el analisis)
  - Sin indicador de engagement
RECOMMENDATIONS:
  - Anadir columna "Last Check-In"
  - Anadir badge de engagement (alto/medio/bajo)

ROLE: Member
FEATURE: Client list page
STATUS: N/A (members no ven esta pagina)
```

---

### 5. Skill: /competitor-analyze (invocable)

**Ubicacion**: `~/.claude/plugins/role-empathy/skills/competitor-analyze.md`
**Modelo**: Claude Opus (analisis profundo)

**Cuando usarlo**:
- Para analizar un competidor nuevo
- Para profundizar en un competidor conocido
- Cuando quieres comparar tu producto con otro

**Como usarlo**:
```
Tu: /competitor-analyze https://hubfit.com
Tu: /competitor-analyze https://practice.do
Tu: /competitor-analyze https://trainerize.com
```

**Que hace** (4 pasos):

| Paso | Que hace |
|------|----------|
| 1. Navigation & Capture | Navega la web con Playwright, toma screenshots de landing, pricing, features, demo |
| 2. Design System Extraction | Extrae colores, tipografia, spacing, componentes, layout patterns |
| 3. UX Pattern Analysis | Documenta arquitectura de informacion, navegacion, visualizacion de datos, onboarding |
| 4. Competitive Assessment | Lo que hacen bien, lo que hacen mal, lo que les falta, su "moat" |

**Output**:
- Screenshots en `docs/screenshots/competitors/[nombre]/`
- Documento en `docs/COMPETITIVE_ANALYSIS_[NOMBRE].md`

---

### 6. Agent: role-analyzer (interno, no invocable)

**Ubicacion**: `~/.claude/plugins/role-empathy/agents/role-analyzer.md`
**Modelo**: Claude Sonnet

**Que hace**: Es un subagente que la IA lanza automaticamente cuando
necesita descubrir roles en un codebase desconocido. Escanea:

- Schema de base de datos (role enums, permissions tables)
- Middleware de auth (role checks, route guards)
- Definiciones de rutas (grupos por rol)
- Documentacion existente

Tu NO lo invocas directamente. Se usa internamente cuando
ejecutas `/role-empathy` en un proyecto nuevo.

---

## Archivos que genera el sistema

| Archivo | Generado por | Contenido |
|---------|-------------|-----------|
| `docs/ROLE_EMPATHY_ANALYSIS.md` | /role-empathy | Analisis completo de todos los roles, personas, herramientas, UX, flujos |
| `docs/DESIGN_SYSTEM_ANALYSIS.md` | /competitor-analyze (manual) | Paleta de colores, tipografia, componentes, UX guidelines por rol |
| `docs/COMPETITIVE_ANALYSIS_[X].md` | /competitor-analyze | Analisis detallado del competidor X |
| `docs/screenshots/competitors/[x]/` | /competitor-analyze | Screenshots del competidor |

---

## Flujo completo recomendado para un proyecto nuevo

```
PASO 1: Inicia Claude Code en tu proyecto
        → Hook detecta automaticamente si hay analisis de roles
        → "No role empathy analysis found. Use /role-empathy"

PASO 2: Ejecuta /role-empathy
        → Se escanea el codebase
        → Se generan personas para cada rol
        → Se crea docs/ROLE_EMPATHY_ANALYSIS.md

PASO 3: Analiza competidores (opcional pero recomendado)
        → /competitor-analyze https://competidor.com
        → Se genera analisis + screenshots

PASO 4: Desarrolla features normalmente
        → La IA consulta automaticamente ROLE_EMPATHY_ANALYSIS.md
        → Sugiere proactivamente ajustes de UX por rol
        → "Esta feature afecta al rol Member, que espera UX mobile-first"

PASO 5: Valida despues de implementar
        → /ux-validate
        → Verifica cada rol contra los criterios definidos
        → Reporta PASS/NEEDS WORK/FAIL

PASO 6: Repite desde paso 4 para la siguiente feature
```

---

## Donde vive cada cosa

```
~/.claude/
  CLAUDE.md                           ← Principio global (15 lineas)
  commands/
    role-empathy.md                   ← /role-empathy (invocable)
    ux-validate.md                    ← /ux-validate (invocable)
    competitor-analyze.md             ← /competitor-analyze (invocable)
  plugins/
    role-empathy/
      plugin.json                     ← Manifest del plugin
      README.md                       ← ESTE ARCHIVO
      skills/
        role-empathy.md               ← Contenido original del skill
        ux-validate.md                ← Contenido original del skill
        competitor-analyze.md         ← Contenido original del skill
      hooks/
        session-start.md              ← Auto-detecta roles al iniciar sesion
      agents/
        role-analyzer.md              ← Subagente para descubrir roles
  plugins/cache/local/role-empathy/   ← Copia cached del plugin (runtime)
```

**Nota tecnica**: Los comandos invocables viven en `~/.claude/commands/`
porque los plugins locales no registran sus skills automaticamente.
El plugin mantiene la estructura completa para hooks, agents y documentacion.

---

## Preguntas frecuentes

**P: Funciona en TODOS mis proyectos?**
R: Si. El principio global y el hook estan activos siempre. Las skills
   se pueden invocar en cualquier proyecto. Si el proyecto no tiene roles
   definidos, el hook te lo dice y te sugiere crearlos.

**P: Consume muchos tokens?**
R: El principio global son ~15 lineas (minimo). Los skills solo se
   ejecutan cuando los invocas. El hook SessionStart es una verificacion
   rapida de si existe un archivo.

**P: Puedo personalizar los criterios de validacion?**
R: El `docs/ROLE_EMPATHY_ANALYSIS.md` de cada proyecto ES la
   personalizacion. Ahi defines que espera cada rol. El skill
   `/ux-validate` lee ese archivo como fuente de verdad.

**P: Que pasa si agrego un rol nuevo al sistema?**
R: Ejecuta `/role-empathy` de nuevo. Detectara el nuevo rol y
   actualizara el documento existente (no lo sobreescribe desde cero).

**P: Funciona sin Playwright?**
R: `/role-empathy` y `/ux-validate` funcionan sin Playwright (solo
   analizan codigo). `/competitor-analyze` SI necesita Playwright
   para navegar webs de competidores.

---

## Proyectos donde se ha usado

### AlmaSuite.coach (2026-02-06)
- Roles: platform_admin, coach, collaborator, member, visitante
- Competidores analizados: HubFit
- Referentes de diseno: Linear, Headspace, Stripe
- Documentos generados:
  - `docs/ROLE_EMPATHY_ANALYSIS.md` (600+ lineas)
  - `docs/DESIGN_SYSTEM_ANALYSIS.md` (400+ lineas)
  - 5 screenshots en `docs/screenshots/competitors/hubfit/`
