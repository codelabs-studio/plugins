# Feature Port - Cheatsheet

> Quick reference para analisis, comparacion y migracion de features entre proyectos.
> Todos los proyectos viven en `/Users/josediaz/Dev/code/`

---

## Comandos

| Comando | Proposito | Modifica codigo? |
|---------|-----------|-----------------|
| `/feature-analyze` | Descubrir features de un proyecto | No (read-only) |
| `/feature-compare` | Comparar una feature en dos proyectos | No (read-only) |
| `/feature-port` | Migrar una feature de A a B | Si (con aprobacion) |

---

## /feature-analyze

**Escanea un proyecto y lista TODAS sus features categorizadas.**

```
/feature-analyze [proyecto]
```

### Ejemplos

```
/feature-analyze almasuite.coach
/feature-analyze facturacion-app
/feature-analyze mi-saas
```

### Que obtienes

- Inventario completo de features
- Categorias: KILLER / CORE / ENHANCEMENT / UTILITY / INFRASTRUCTURE
- Portability rating (1-5) por feature
- Complexity rating (1-5) por feature
- Ranking de mejores candidatas para portar

### Casos de uso

| Situacion | Comando |
|-----------|---------|
| "Que tiene este proyecto?" | `/feature-analyze proyecto-x` |
| "Que puedo portar de aqui?" | `/feature-analyze proyecto-x` → ver PORT RECOMMENDATIONS |
| "Cual es la killer feature?" | `/feature-analyze proyecto-x` → ver KILLER FEATURES |
| "Que tan complejo es esto?" | `/feature-analyze proyecto-x` → ver complexity ratings |

---

## /feature-compare

**Compara como la misma feature esta implementada en dos proyectos.**

```
/feature-compare [feature] in [proyecto-a] vs [proyecto-b]
```

### Ejemplos

```
/feature-compare auth in almasuite.coach vs facturacion-app
/feature-compare chatbot in proyecto-a vs proyecto-b
/feature-compare audit-logs in saas-one vs saas-two
/feature-compare payments in tienda-x vs tienda-y
```

### Que obtienes

- Overview table (tech stack, maturity, files, tables, endpoints)
- Architecture comparison (patrones, estructura de archivos)
- Data model diff (tablas, campos, relaciones)
- Business logic matrix (operaciones que tiene A vs B)
- UI/UX comparison (paginas, componentes, estados, roles)
- External dependencies table
- Scorecard numerico (7 dimensiones, X/10)
- Recommendations: que hace mejor cada uno
- "Best of Both Worlds": la implementacion ideal combinando ambos

### Casos de uso

| Situacion | Comando |
|-----------|---------|
| "Cual implementacion es mejor?" | `/feature-compare X in A vs B` → ver scorecard |
| "Que le falta a mi proyecto?" | `/feature-compare X in mi-proyecto vs el-bueno` → ver operations matrix |
| "Verificar un port que hice" | `/feature-compare X in origen vs destino` → post-port audit |
| "Aprender de otro enfoque" | `/feature-compare X in A vs B` → ver architecture comparison |
| "Decidir que portar" | `/feature-compare X in A vs B` → ver recommendations |

### Despues del compare, que puedo pedir

```
# Todo completo
"Porta [feature] completa de A a B"

# Solo una parte
"Porta solo el data model y el export de A a B"

# Cherry-pick
"Copia el sistema de retention de A a B, sin las categorias"

# Combinar lo mejor
"Usa el dashboard de A pero con los filtros de B"

# Nada
"Ok, lo dejo como esta"
```

---

## /feature-port

**Migra una feature de un proyecto a otro, adaptandola al destino.**

```
/feature-port [feature] from [origen] to [destino]
```

### Ejemplos

```
/feature-port chatbot from almasuite.coach to fittrack-pro
/feature-port audit-logs from facturacion-app to almasuite.coach
/feature-port notifications from saas-one to saas-two
/feature-port payments from tienda-x to tienda-y
```

### Que obtienes

1. Blueprint technology-agnostic de la feature (extraccion)
2. Analisis del proyecto destino (arquitectura, roles, convenciones)
3. Plan de adaptacion detallado (REQUIERE TU APROBACION)
4. Implementacion adaptada al destino
5. Validacion (types, lint, build, visual)

### Fases

```
Fase 1: Extraccion    → Lee el origen (read-only)
Fase 2: Analisis      → Lee el destino (read-only)
Fase 3: Plan          → Te presenta el plan
Fase 4: Aprobacion    → PARA. Espera tu OK
Fase 5: Implementacion → Escribe codigo en el destino
Fase 6: Validacion    → Verifica que todo funciona
```

### Casos de uso

| Situacion | Comando |
|-----------|---------|
| "Quiero esto en mi otro proyecto" | `/feature-port X from A to B` |
| "Copia solo una parte" | "Porta solo [parte especifica] de X from A to B" |
| "Adapta a mis roles" | Automatico: lee `ROLE_EMPATHY_ANALYSIS.md` del destino |
| "Usa mi design system" | Automatico: lee `DESIGN_SYSTEM_ANALYSIS.md` del destino |

### Variantes de port

```
# Port completo
/feature-port chatbot from A to B

# Port parcial (despues del compare)
"Del chatbot de A, porta solo el backend y data model a B.
La UI la hago yo."

# Port con exclusiones
"Porta el sistema de audit-logs de A a B,
pero sin el dashboard de graficos."

# Port con extras
"Porta notifications de A a B, y anade soporte
para push notifications que A no tiene."
```

---

## Flujos Completos

### Flujo 1: Explorar → Decidir → Portar

```
1. /feature-analyze proyecto-a
   → "Ah, tiene un sistema de audit logs interesante"

2. /feature-compare audit-logs in proyecto-a vs proyecto-b
   → "A tiene mejor data model, B tiene mejor UI"

3. /feature-port audit-logs from proyecto-a to proyecto-b
   → "Porta el data model de A, adaptado a la UI de B"
```

### Flujo 2: Comparar → Portar lo mejor

```
1. /feature-compare auth in proyecto-viejo vs proyecto-nuevo
   → Scorecard: viejo=8/10, nuevo=4/10

2. /feature-port auth from proyecto-viejo to proyecto-nuevo
   → Port completo, adaptado al tech stack nuevo
```

### Flujo 3: Analizar → Portar killer feature a varios

```
1. /feature-analyze proyecto-estrella
   → KILLER: AI chatbot (portability 4/5)

2. /feature-port chatbot from proyecto-estrella to proyecto-b
3. /feature-port chatbot from proyecto-estrella to proyecto-c
4. /feature-port chatbot from proyecto-estrella to proyecto-d
   → Misma feature, adaptada 3 veces a 3 contextos diferentes
```

### Flujo 4: Post-port verification

```
1. /feature-port notifications from A to B
   → Implementacion completada

2. /feature-compare notifications in A vs B
   → Verifica que el port quedo bien
   → Scorecard similar, adaptaciones correctas

3. /ux-validate (si B tiene role empathy analysis)
   → Valida UX contra los roles del destino
```

---

## Integracion con Otros Skills

| Skill | Cuando usarlo con feature-port |
|-------|-------------------------------|
| `/role-empathy` | Antes del port, para que el destino tenga roles definidos |
| `/ux-validate` | Despues del port, para validar la adaptacion de UX |
| `/competitor-analyze` | Para analizar competidores y decidir que features portar |
| `/feature-analyze` | Antes del port, para ver el inventario completo |
| `/feature-compare` | Antes del port, para decidir cual implementacion es mejor |

---

## Tips

- `/feature-analyze` y `/feature-compare` son siempre **read-only**. Usalos sin miedo.
- `/feature-port` **siempre para** en Fase 4 para pedirte aprobacion. Nunca escribe sin tu OK.
- Puedes portar parcialmente: "solo el backend", "sin la UI", "solo el data model".
- Si dos proyectos usan tech stacks diferentes, el port traduce automaticamente.
- Despues de portar, usa `/feature-compare` para verificar que quedo bien.
- Los agents internos no se invocan directamente. Los skills los lanzan por ti.
