# Gestión de Órdenes de Trabajo (AC-OT-I) 🛠️
Proyecto final para el Máster ABAP Cloud I - Logali Group.

## 📋 Descripción
Sistema robusto de gestión de órdenes de trabajo desarrollado bajo los estándares de ABAP Cloud, incluyendo integridad referencial física, validaciones de negocio y auditoría de cambios.

## 🏗️ Estructura de Datos
A continuación se presenta el modelo entidad-relación del proyecto:

```mermaid
erDiagram
    ZCUSTOMER_OT ||--o{ ZWORKORDER_OT : "tiene"
    ZTECHNICIAN_OT ||--o{ ZWORKORDER_OT : "asignado"
    ZWORKORDER_OT ||--o{ ZWORKORDER_HIST : "registra cambios"

    ZWORKORDER_OT {
        numc10 work_order_id PK
        numc8 customer_id FK
        char8 technician_id FK
        dats creation_date
        char2 status
        char1 priority
    }
