# Diagrama de Arquitectura

## Estructura de Proyectos

```mermaid
graph TB
    subgraph "Clean Architecture API"
        subgraph "WebAPI Layer"
            A[Controllers]
            B[Middleware]
            C[Filters]
        end
        
        subgraph "Application Layer"
            D[Services]
            E[DTOs]
            F[Validators]
            G[Mappings]
            H[Interfaces]
        end
        
        subgraph "Infrastructure Layer"
            I[Repositories]
            J[DbContext]
            K[Data Access]
        end
        
        subgraph "Core Layer"
            L[Entities]
            M[Domain Interfaces]
            N[Common]
        end
        
        subgraph "External"
            O[Oracle Database]
            P[Keycloak]
            Q[Swagger UI]
        end
    end
    
    A --> D
    A --> E
    D --> H
    D --> F
    D --> G
    D --> I
    I --> J
    J --> O
    A --> P
    A --> Q
    D --> L
    I --> M
```

## Flujo de Datos

```mermaid
sequenceDiagram
    participant Client
    participant Controller
    participant Service
    participant Repository
    participant Database
    participant Keycloak
    
    Client->>Controller: HTTP Request
    Controller->>Keycloak: Validate JWT Token
    Keycloak-->>Controller: Claims Principal
    
    alt Valid Token
        Controller->>Service: Process Request
        Service->>Repository: Get/Update Data
        Repository->>Database: Execute Query
        Database-->>Repository: Return Data
        Repository-->>Service: Return Entity
        Service-->>Controller: Return DTO
        Controller-->>Client: HTTP Response
    else Invalid Token
        Controller-->>Client: 401 Unauthorized
    end
```

## Dependencias entre Capas

```mermaid
graph LR
    subgraph "Dependencies"
        WebAPI --> Application
        WebAPI --> Infrastructure
        Application --> Core
        Infrastructure --> Core
        Infrastructure --> Application
    end
    
    subgraph "No Dependencies"
        Core -.-> WebAPI
        Core -.-> Infrastructure
        Application -.-> WebAPI
    end
```

## Estructura de Carpetas Detallada

```mermaid
graph TD
    subgraph "src/"
        subgraph "CleanArchitectureAPI.Core/"
            A1[Entities/BaseEntity.cs]
            A2[Entities/Product.cs]
            A3[Interfaces/IRepository.cs]
            A4[Interfaces/IUnitOfWork.cs]
        end
        
        subgraph "CleanArchitectureAPI.Application/"
            B1[DTOs/BaseDto.cs]
            B2[DTOs/ProductDto.cs]
            B3[Services/ProductService.cs]
            B4[Interfaces/IProductService.cs]
            B5[Validators/]
            B6[Mappings/ProductMappingProfile.cs]
        end
        
        subgraph "CleanArchitectureAPI.Infrastructure/"
            C1[Data/ApplicationDbContext.cs]
            C2[Repositories/Repository.cs]
            C3[Repositories/UnitOfWork.cs]
            C4[DependencyInjection.cs]
        end
        
        subgraph "CleanArchitectureAPI.WebAPI/"
            D1[Controllers/ProductsController.cs]
            D2[Middleware/ExceptionHandlingMiddleware.cs]
            D3[Program.cs]
            D4[appsettings.json]
        end
    end
    
    subgraph "scripts/"
        E1[generate-crud.ps1]
    end
```

## Flujo de Scaffolding Automático

```mermaid
flowchart TD
    A[Ejecutar Script] --> B[Crear Entidad]
    B --> C[Crear DTOs]
    C --> D[Crear Interfaz de Servicio]
    D --> E[Crear Servicio]
    E --> F[Crear Validadores]
    F --> G[Crear Mapeos]
    G --> H[Crear Controlador]
    H --> I[Actualizar DbContext]
    I --> J[Actualizar Dependencias]
    J --> K[Compilar Proyecto]
    K --> L[Crear Migración]
    L --> M[Actualizar Base de Datos]
    M --> N[Probar Endpoints]
```

## Configuración de Autenticación

```mermaid
graph LR
    subgraph "Authentication Flow"
        A[Client Request] --> B[JWT Bearer Token]
        B --> C[Keycloak Validation]
        C --> D[Claims Principal]
        D --> E[Authorization Filter]
        E --> F[Controller Action]
    end
    
    subgraph "Keycloak Configuration"
        G[Authority]
        H[Audience]
        I[Client ID]
        J[Client Secret]
    end
    
    C --> G
    C --> H
    C --> I
    C --> J
```

## Patrón Repository

```mermaid
classDiagram
    class IRepository~T~ {
        <<interface>>
        +GetByIdAsync(id) T
        +GetAllAsync() IEnumerable~T~
        +AddAsync(entity) T
        +UpdateAsync(entity) T
        +DeleteAsync(id) void
        +ExistsAsync(id) bool
    }
    
    class Repository~T~ {
        -_context ApplicationDbContext
        -_dbSet DbSet~T~
        +GetByIdAsync(id) T
        +GetAllAsync() IEnumerable~T~
        +AddAsync(entity) T
        +UpdateAsync(entity) T
        +DeleteAsync(id) void
        +ExistsAsync(id) bool
    }
    
    class IUnitOfWork {
        <<interface>>
        +Repository~T~() IRepository~T~
        +SaveChangesAsync() int
        +BeginTransactionAsync() void
        +CommitTransactionAsync() void
        +RollbackTransactionAsync() void
    }
    
    class UnitOfWork {
        -_context ApplicationDbContext
        -_repositories Dictionary
        -_transaction IDbContextTransaction
        +Repository~T~() IRepository~T~
        +SaveChangesAsync() int
        +BeginTransactionAsync() void
        +CommitTransactionAsync() void
        +RollbackTransactionAsync() void
    }
    
    IRepository~T~ <|.. Repository~T~
    IUnitOfWork <|.. UnitOfWork
    Repository~T~ --> ApplicationDbContext
    UnitOfWork --> ApplicationDbContext
```

## Mapeo de Entidades a DTOs

```mermaid
graph LR
    subgraph "Domain Layer"
        A[Product Entity]
    end
    
    subgraph "Application Layer"
        B[ProductDto]
        C[CreateProductDto]
        D[UpdateProductDto]
    end
    
    subgraph "AutoMapper"
        E[ProductMappingProfile]
    end
    
    A --> E
    E --> B
    C --> E
    E --> A
    D --> E
    E --> A
```

## Validación de Datos

```mermaid
flowchart TD
    A[HTTP Request] --> B[Controller]
    B --> C[FluentValidation]
    C --> D{Valid?}
    D -->|Yes| E[Service Layer]
    D -->|No| F[400 Bad Request]
    E --> G[Repository Layer]
    G --> H[Database]
    H --> I[Response]
```

## Middleware Pipeline

```mermaid
graph LR
    A[Request] --> B[Exception Handling]
    B --> C[CORS]
    C --> D[Authentication]
    D --> E[Authorization]
    E --> F[Controller]
    F --> G[Response]
```