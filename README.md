# Clean Architecture API Template

Plantilla base en .NET Core 8 para construir APIs RESTful siguiendo los principios de Clean Architecture.

## 🏗️ Estructura del Proyecto

```
CleanArchitectureAPI/
├── src/
│   ├── CleanArchitectureAPI.Core/           # Capa de Dominio
│   │   ├── Entities/                        # Entidades de dominio
│   │   ├── Interfaces/                      # Interfaces de repositorio
│   │   └── Common/                          # Clases comunes
│   │
│   ├── CleanArchitectureAPI.Application/    # Capa de Aplicación
│   │   ├── DTOs/                           # Objetos de transferencia de datos
│   │   ├── Services/                       # Servicios de aplicación
│   │   ├── Interfaces/                     # Interfaces de servicios
│   │   ├── Validators/                     # Validaciones con FluentValidation
│   │   └── Mappings/                       # Configuración de AutoMapper
│   │
│   ├── CleanArchitectureAPI.Infrastructure/ # Capa de Infraestructura
│   │   ├── Data/                           # Contexto de Entity Framework
│   │   ├── Repositories/                   # Implementaciones de repositorios
│   │   └── DependencyInjection.cs         # Configuración de DI
│   │
│   └── CleanArchitectureAPI.WebAPI/        # Capa de Presentación
│       ├── Controllers/                    # Controladores API
│       ├── Middleware/                     # Middleware personalizado
│       └── Filters/                        # Filtros de acción
│
├── scripts/
│   └── generate-crud.ps1                   # Script de scaffolding automático
│
└── CleanArchitectureAPI.sln                # Solución de Visual Studio
```

## 🚀 Características Principales

### ✅ Conexión a Oracle
- Configuración completa de Entity Framework Core con Oracle
- Cadena de conexión configurada en `appsettings.json`
- Soporte para migraciones automáticas

### ✅ Clean Architecture
- Separación clara de responsabilidades
- Inversión de dependencias
- Capas bien definidas (Core, Application, Infrastructure, WebAPI)

### ✅ Scaffolding Automático
- Script PowerShell para generar código CRUD completo
- Generación automática de entidades, DTOs, servicios, validadores y controladores
- Documentación Swagger automática

### ✅ Documentación con Swagger
- Configuración completa de Swagger/OpenAPI
- Documentación automática de endpoints
- Autenticación JWT integrada en Swagger

### ✅ Autenticación y Autorización con Keycloak
- Configuración de OpenID Connect
- Soporte para JWT Bearer tokens
- Políticas de autorización basadas en roles

### ✅ Validación y Mapeo
- FluentValidation para validaciones de entrada
- AutoMapper para mapeo entre entidades y DTOs
- Validación automática en controladores

## 🛠️ Configuración Inicial

### 1. Configurar la Base de Datos Oracle

Edita `src/CleanArchitectureAPI.WebAPI/appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=XE)));User Id=tu_usuario;Password=tu_password;"
  }
}
```

### 2. Configurar Keycloak

```json
{
  "Keycloak": {
    "Authority": "https://tu-servidor-keycloak/auth/realms/tu-realm",
    "Audience": "tu-client-id",
    "ClientId": "tu-client-id",
    "ClientSecret": "tu-client-secret"
  }
}
```

### 3. Instalar Dependencias

```bash
dotnet restore
```

### 4. Crear Migraciones

```bash
cd src/CleanArchitectureAPI.Infrastructure
dotnet ef migrations add InitialCreate
dotnet ef database update
```

### 5. Ejecutar la Aplicación

```bash
cd src/CleanArchitectureAPI.WebAPI
dotnet run
```

## 📝 Guía de Uso

### Agregar una Nueva Entidad

Para agregar una nueva entidad (por ejemplo, "Customer"), ejecuta:

```powershell
./scripts/generate-crud.ps1 -EntityName "Customer"
```

Esto generará automáticamente:

1. **Entidad**: `src/CleanArchitectureAPI.Core/Entities/Customer.cs`
2. **DTOs**: 
   - `src/CleanArchitectureAPI.Application/DTOs/CreateCustomerDto.cs`
   - `src/CleanArchitectureAPI.Application/DTOs/UpdateCustomerDto.cs`
   - `src/CleanArchitectureAPI.Application/DTOs/CustomerDto.cs`
3. **Servicio**: `src/CleanArchitectureAPI.Application/Services/CustomerService.cs`
4. **Interfaz**: `src/CleanArchitectureAPI.Application/Interfaces/ICustomerService.cs`
5. **Validadores**: 
   - `src/CleanArchitectureAPI.Application/Validators/CreateCustomerDtoValidator.cs`
   - `src/CleanArchitectureAPI.Application/Validators/UpdateCustomerDtoValidator.cs`
6. **Mapeos**: `src/CleanArchitectureAPI.Application/Mappings/CustomerMappingProfile.cs`
7. **Controlador**: `src/CleanArchitectureAPI.WebAPI/Controllers/CustomersController.cs`

### Personalizar la Entidad

Después de generar el código, edita la entidad según tus necesidades:

```csharp
public class Customer : BaseEntity
{
    [Required]
    [StringLength(100)]
    public string Name { get; set; } = string.Empty;
    
    [EmailAddress]
    public string? Email { get; set; }
    
    [Phone]
    public string? Phone { get; set; }
    
    // Agregar más propiedades según sea necesario
}
```

### Crear Migraciones

```bash
cd src/CleanArchitectureAPI.Infrastructure
dotnet ef migrations add AddCustomerEntity
dotnet ef database update
```

## 🔐 Autenticación y Autorización

### Configuración de Roles

Los roles se configuran en Keycloak y se mapean a claims JWT:

```csharp
[Authorize(Roles = "Admin")]           // Solo administradores
[Authorize(Roles = "Admin,Manager")]   // Administradores o managers
[Authorize]                            // Usuarios autenticados
```

### Obtener Información del Usuario

```csharp
var currentUser = User.FindFirst(ClaimTypes.Name)?.Value ?? "System";
var userRoles = User.Claims.Where(c => c.Type == ClaimTypes.Role).Select(c => c.Value);
```

## 📚 Documentación de API

### Acceder a Swagger

Una vez ejecutada la aplicación, accede a:
- **Swagger UI**: `https://localhost:7001/`
- **Swagger JSON**: `https://localhost:7001/swagger/v1/swagger.json`

### Documentar Endpoints

Los endpoints se documentan automáticamente usando comentarios XML:

```csharp
/// <summary>
/// Obtiene todos los productos
/// </summary>
/// <returns>Lista de productos</returns>
/// <response code="200">Retorna la lista de productos</response>
/// <response code="401">No autorizado</response>
[HttpGet]
[ProducesResponseType(typeof(IEnumerable<ProductDto>), 200)]
[ProducesResponseType(401)]
public async Task<ActionResult<IEnumerable<ProductDto>>> GetProducts()
{
    // Implementación
}
```

## 🧪 Pruebas Unitarias

### Estructura Recomendada

```
tests/
├── CleanArchitectureAPI.Core.Tests/
├── CleanArchitectureAPI.Application.Tests/
├── CleanArchitectureAPI.Infrastructure.Tests/
└── CleanArchitectureAPI.WebAPI.Tests/
```

### Ejemplo de Prueba

```csharp
[Test]
public async Task CreateProduct_WithValidData_ShouldReturnCreatedProduct()
{
    // Arrange
    var createDto = new CreateProductDto 
    { 
        Name = "Test Product", 
        Price = 100 
    };
    
    // Act
    var result = await _productService.CreateAsync(createDto, "test-user");
    
    // Assert
    Assert.NotNull(result);
    Assert.AreEqual("Test Product", result.Name);
}
```

## 🔄 Flujo de Datos

### 1. Petición HTTP
```
Cliente → ProductsController → ProductService → ProductRepository → Oracle Database
```

### 2. Autenticación
```
Request → JWT Middleware → Keycloak Validation → Claims Principal
```

### 3. Autorización
```
Claims Principal → Authorization Filter → Role-based Access Control
```

### 4. Procesamiento
```
DTO → Validation → Mapping → Entity → Repository → Database
```

### 5. Respuesta
```
Database → Entity → Mapping → DTO → JSON Response
```

## 📋 Buenas Prácticas

### Nomenclatura
- **Entidades**: PascalCase (ej: `Product`, `Customer`)
- **DTOs**: PascalCase + sufijo (ej: `ProductDto`, `CreateProductDto`)
- **Servicios**: PascalCase + sufijo (ej: `ProductService`)
- **Controladores**: PascalCase + sufijo (ej: `ProductsController`)

### Validaciones
- Usar Data Annotations para validaciones básicas
- Usar FluentValidation para validaciones complejas
- Validar en múltiples capas (DTO, Service, Repository)

### Manejo de Errores
- Usar middleware global para excepciones
- Retornar códigos HTTP apropiados
- Logging estructurado de errores

### Seguridad
- Validar tokens JWT en cada request
- Usar HTTPS en producción
- Implementar rate limiting
- Sanitizar inputs

## 🚀 Despliegue

### Docker

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["src/CleanArchitectureAPI.WebAPI/CleanArchitectureAPI.WebAPI.csproj", "src/CleanArchitectureAPI.WebAPI/"]
COPY ["src/CleanArchitectureAPI.Application/CleanArchitectureAPI.Application.csproj", "src/CleanArchitectureAPI.Application/"]
COPY ["src/CleanArchitectureAPI.Infrastructure/CleanArchitectureAPI.Infrastructure.csproj", "src/CleanArchitectureAPI.Infrastructure/"]
COPY ["src/CleanArchitectureAPI.Core/CleanArchitectureAPI.Core.csproj", "src/CleanArchitectureAPI.Core/"]
RUN dotnet restore "src/CleanArchitectureAPI.WebAPI/CleanArchitectureAPI.WebAPI.csproj"
COPY . .
WORKDIR "/src/src/CleanArchitectureAPI.WebAPI"
RUN dotnet build "CleanArchitectureAPI.WebAPI.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "CleanArchitectureAPI.WebAPI.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CleanArchitectureAPI.WebAPI.dll"]
```

### Variables de Entorno

```bash
export ConnectionStrings__DefaultConnection="tu-cadena-conexion-oracle"
export Keycloak__Authority="https://tu-keycloak-server/auth/realms/tu-realm"
export Keycloak__Audience="tu-client-id"
export Keycloak__ClientSecret="tu-client-secret"
```

## 📞 Soporte

Para dudas o problemas:

1. Revisa la documentación de Swagger
2. Verifica los logs de la aplicación
3. Consulta la documentación de Entity Framework Core
4. Revisa la configuración de Keycloak

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.