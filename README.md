# Gestión de Órdenes de Trabajo (AC-OT-I) 🛠️

Proyecto final desarrollado en ABAP Cloud como solución de gestión de órdenes de trabajo.

## 📋 Descripción

Este proyecto implementa una solución para la gestión de órdenes de trabajo, incluyendo:

- estructura de datos y diccionario de datos
- operaciones CRUD sobre órdenes de trabajo
- validaciones de negocio
- control de autorización por actividad
- auditoría de cambios mediante historial

La solución está basada en tablas transparentes, elementos de datos, dominios y clases ABAP para la lógica de negocio.

## 🏗️ Modelo de datos

El modelo funcional se compone de las siguientes entidades:

- **ZCUSTOMER_OT**: maestro de clientes
- **ZTECHNICIAN_OT**: maestro de técnicos
- **ZWORKORDER_OT**: órdenes de trabajo
- **ZWORDER_HIST_OT**: historial de modificaciones de órdenes

### Relación lógica entre entidades

```mermaid
erDiagram
    ZCUSTOMER_OT ||--o{ ZWORKORDER_OT : "tiene"
    ZTECHNICIAN_OT ||--o{ ZWORKORDER_OT : "asignado"
    ZWORKORDER_OT ||--o{ ZWORDER_HIST_OT : "registra cambios"
```

## 🧩 Diccionario de datos

### Tablas principales
- `ZCUSTOMER_OT`
- `ZTECHNICIAN_OT`
- `ZWORKORDER_OT`
- `ZWORDER_HIST_OT`

### Elementos de datos
- `ZDE_PRIORITY_YZ`
- `ZDE_STATUS_YZ`

### Dominios
- `ZDO_PRIORITY_YZ`
- `ZDO_STATUS_YZ`

## ⚙️ Funcionalidades implementadas

### CRUD de órdenes de trabajo
La lógica CRUD está implementada en la clase:

- `ZCL_WORK_ORDER_CRUD_HANDLER_YZ`

Incluye:
- creación de órdenes
- lectura por identificador
- actualización de órdenes
- eliminación condicionada por reglas de negocio

### Validaciones de negocio
La lógica de validación está implementada en:

- `ZCL_WORK_ORDER_VALIDATOR_YZ`

Reglas incluidas:
- el cliente debe existir
- el técnico debe existir
- la prioridad debe ser válida
- solo se puede actualizar una orden en estado pendiente
- una orden con historial no puede eliminarse

### Autorización
Se utiliza el objeto de autorización:

- `ZOT_AUT_YZ`

Actividades controladas:
- `01` Crear
- `02` Modificar
- `03` Visualizar
- `06` Eliminar

## 📝 Auditoría e historial

Cada actualización de una orden genera un registro en:

- `ZWORDER_HIST_OT`

Esto permite dejar trazabilidad de los cambios realizados sobre la orden de trabajo.

## 🔒 Bloqueo de concurrencia

Se definió el objeto de bloqueo:

- `EZWORKORDER_YZ`

asociado a la tabla `ZWORKORDER_OT` y al campo `WORK_ORDER_ID`.

> Nota: el objeto de bloqueo está creado y documentado en el proyecto. Su integración programática en el entorno ABAP Cloud presentó una limitación técnica en runtime, por lo que actualmente se mantiene definido a nivel de diccionario, aunque no activo en la lógica final de ejecución.

## 🧪 Pruebas

Se incluyen pruebas funcionales de ejecución mediante:

- `ZCL_WORK_ORDER_CRUD_TEST_YZ`

Flujo probado:
1. crear orden
2. leer orden creada
3. actualizar orden
4. verificar restricción de borrado tras registrar historial

Ejemplo de salida esperada:

```text
--- INICIO DE PRUEBAS CRUD ---
Crear: Orden creada
Leer Orden 100: Orden de Prueba Inicial - Estado: PE
Actualizar: Orden actualizada e historial registrado
Eliminar: No se puede eliminar: tiene historial o no está pendiente
--- FIN DE PRUEBAS CRUD ---
```

## 🚀 Clase de carga de datos

Para preparar datos maestros base se incluye:

- `ZCL_LOAD_MASTER_DATA_YZ`

Esta clase inserta registros iniciales de cliente y técnico para facilitar las pruebas del sistema.

## 📌 Estado actual del proyecto

El proyecto cuenta con:
- modelo de datos funcional
- lógica CRUD implementada
- validaciones de negocio
- historial de modificaciones
- control de autorización
- pruebas funcionales reproducibles

## 👩‍💻 Autora

Yesenia Zapata
