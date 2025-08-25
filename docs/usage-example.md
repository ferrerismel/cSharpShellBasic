# Ejemplo de Uso del Scaffolding Automático

## Paso 1: Generar una Nueva Entidad

Supongamos que queremos crear una entidad `Customer` (Cliente). Ejecuta el siguiente comando:

```powershell
./scripts/generate-crud.ps1 -EntityName "Customer"
```

## Paso 2: Personalizar la Entidad

Después de ejecutar el script, edita la entidad generada en `src/CleanArchitectureAPI.Core/Entities/Customer.cs`:

```csharp
using System.ComponentModel.DataAnnotations;

namespace CleanArchitectureAPI.Core.Entities
{
    public class Customer : BaseEntity
    {
        [Required]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [EmailAddress]
        [StringLength(150)]
        public string? Email { get; set; }
        
        [Phone]
        [StringLength(20)]
        public string? Phone { get; set; }
        
        [StringLength(200)]
        public string? Address { get; set; }
        
        [StringLength(50)]
        public string? City { get; set; }
        
        [StringLength(10)]
        public string? PostalCode { get; set; }
        
        public bool IsActive { get; set; } = true;
    }
}
```

## Paso 3: Personalizar los DTOs

Actualiza los DTOs en `src/CleanArchitectureAPI.Application/DTOs/`:

### CreateCustomerDto.cs
```csharp
using System.ComponentModel.DataAnnotations;

namespace CleanArchitectureAPI.Application.DTOs
{
    public class CreateCustomerDto
    {
        [Required]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [EmailAddress]
        [StringLength(150)]
        public string? Email { get; set; }
        
        [Phone]
        [StringLength(20)]
        public string? Phone { get; set; }
        
        [StringLength(200)]
        public string? Address { get; set; }
        
        [StringLength(50)]
        public string? City { get; set; }
        
        [StringLength(10)]
        public string? PostalCode { get; set; }
    }
}
```

### UpdateCustomerDto.cs
```csharp
using System.ComponentModel.DataAnnotations;

namespace CleanArchitectureAPI.Application.DTOs
{
    public class UpdateCustomerDto
    {
        [Required]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [EmailAddress]
        [StringLength(150)]
        public string? Email { get; set; }
        
        [Phone]
        [StringLength(20)]
        public string? Phone { get; set; }
        
        [StringLength(200)]
        public string? Address { get; set; }
        
        [StringLength(50)]
        public string? City { get; set; }
        
        [StringLength(10)]
        public string? PostalCode { get; set; }
    }
}
```

### CustomerDto.cs
```csharp
namespace CleanArchitectureAPI.Application.DTOs
{
    public class CustomerDto : BaseDto
    {
        public string Name { get; set; } = string.Empty;
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public string? Address { get; set; }
        public string? City { get; set; }
        public string? PostalCode { get; set; }
    }
}
```

## Paso 4: Personalizar Validadores

Actualiza los validadores en `src/CleanArchitectureAPI.Application/Validators/`:

### CreateCustomerDtoValidator.cs
```csharp
using FluentValidation;
using CleanArchitectureAPI.Application.DTOs;

namespace CleanArchitectureAPI.Application.Validators
{
    public class CreateCustomerDtoValidator : AbstractValidator<CreateCustomerDto>
    {
        public CreateCustomerDtoValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("El nombre es requerido")
                .MaximumLength(100).WithMessage("El nombre no puede exceder 100 caracteres");

            RuleFor(x => x.Email)
                .EmailAddress().WithMessage("El email debe tener un formato válido")
                .MaximumLength(150).WithMessage("El email no puede exceder 150 caracteres");

            RuleFor(x => x.Phone)
                .Matches(@"^\+?[1-9]\d{1,14}$").WithMessage("El teléfono debe tener un formato válido")
                .MaximumLength(20).WithMessage("El teléfono no puede exceder 20 caracteres");

            RuleFor(x => x.Address)
                .MaximumLength(200).WithMessage("La dirección no puede exceder 200 caracteres");

            RuleFor(x => x.City)
                .MaximumLength(50).WithMessage("La ciudad no puede exceder 50 caracteres");

            RuleFor(x => x.PostalCode)
                .MaximumLength(10).WithMessage("El código postal no puede exceder 10 caracteres");
        }
    }
}
```

## Paso 5: Crear Migración

```bash
cd src/CleanArchitectureAPI.Infrastructure
dotnet ef migrations add AddCustomerEntity
dotnet ef database update
```

## Paso 6: Compilar y Probar

```bash
cd /workspace
dotnet build
cd src/CleanArchitectureAPI.WebAPI
dotnet run
```

## Paso 7: Probar los Endpoints

Una vez que la aplicación esté ejecutándose, accede a Swagger en `https://localhost:7001/` y prueba los siguientes endpoints:

### GET /api/Customers
Obtiene todos los clientes.

### GET /api/Customers/{id}
Obtiene un cliente específico por ID.

### POST /api/Customers
Crea un nuevo cliente.

**Ejemplo de request body:**
```json
{
  "name": "Juan Pérez",
  "email": "juan.perez@email.com",
  "phone": "+1234567890",
  "address": "123 Main St",
  "city": "New York",
  "postalCode": "10001"
}
```

### PUT /api/Customers/{id}
Actualiza un cliente existente.

### DELETE /api/Customers/{id}
Elimina un cliente (solo administradores).

## Paso 8: Agregar Funcionalidades Específicas

### Agregar Métodos al Servicio

Edita `src/CleanArchitectureAPI.Application/Services/CustomerService.cs`:

```csharp
public async Task<IEnumerable<CustomerDto>> GetByCityAsync(string city)
{
    var customers = await _customerRepository.FindAsync(c => c.City == city && c.IsActive);
    return _mapper.Map<IEnumerable<CustomerDto>>(customers);
}

public async Task<IEnumerable<CustomerDto>> SearchByNameAsync(string searchTerm)
{
    var customers = await _customerRepository.FindAsync(c => 
        c.Name.Contains(searchTerm) && c.IsActive);
    return _mapper.Map<IEnumerable<CustomerDto>>(customers);
}
```

### Agregar Endpoints al Controlador

Edita `src/CleanArchitectureAPI.WebAPI/Controllers/CustomersController.cs`:

```csharp
/// <summary>
/// Obtiene clientes por ciudad
/// </summary>
/// <param name="city">Ciudad de los clientes</param>
/// <returns>Lista de clientes de la ciudad</returns>
[HttpGet("city/{city}")]
[ProducesResponseType(typeof(IEnumerable<CustomerDto>), 200)]
[ProducesResponseType(401)]
public async Task<ActionResult<IEnumerable<CustomerDto>>> GetCustomersByCity(string city)
{
    var customers = await _customerService.GetByCityAsync(city);
    return Ok(customers);
}

/// <summary>
/// Busca clientes por nombre
/// </summary>
/// <param name="searchTerm">Término de búsqueda</param>
/// <returns>Lista de clientes que coinciden con la búsqueda</returns>
[HttpGet("search")]
[ProducesResponseType(typeof(IEnumerable<CustomerDto>), 200)]
[ProducesResponseType(401)]
public async Task<ActionResult<IEnumerable<CustomerDto>>> SearchCustomers([FromQuery] string searchTerm)
{
    var customers = await _customerService.SearchByNameAsync(searchTerm);
    return Ok(customers);
}
```

## Paso 9: Configurar Logging

Agrega logging al servicio:

```csharp
public class CustomerService : ICustomerService
{
    private readonly IRepository<Customer> _customerRepository;
    private readonly IMapper _mapper;
    private readonly ILogger<CustomerService> _logger;

    public CustomerService(
        IRepository<Customer> customerRepository, 
        IMapper mapper,
        ILogger<CustomerService> logger)
    {
        _customerRepository = customerRepository;
        _mapper = mapper;
        _logger = logger;
    }

    public async Task<CustomerDto> CreateAsync(CreateCustomerDto createDto, string createdBy)
    {
        _logger.LogInformation("Creating new customer: {CustomerName}", createDto.Name);
        
        var customer = _mapper.Map<Customer>(createDto);
        customer.CreatedBy = createdBy;
        
        var createdCustomer = await _customerRepository.AddAsync(customer);
        
        _logger.LogInformation("Customer created successfully with ID: {CustomerId}", createdCustomer.Id);
        
        return _mapper.Map<CustomerDto>(createdCustomer);
    }
}
```

## Paso 10: Agregar Pruebas Unitarias

Crea un proyecto de pruebas:

```bash
mkdir tests
cd tests
dotnet new xunit -n CleanArchitectureAPI.Application.Tests
dotnet add reference ../src/CleanArchitectureAPI.Application/CleanArchitectureAPI.Application.csproj
dotnet add package Moq
dotnet add package FluentAssertions
```

Ejemplo de prueba:

```csharp
[Fact]
public async Task CreateCustomer_WithValidData_ShouldReturnCreatedCustomer()
{
    // Arrange
    var createDto = new CreateCustomerDto 
    { 
        Name = "Test Customer", 
        Email = "test@email.com" 
    };
    
    var mockRepository = new Mock<IRepository<Customer>>();
    var mockMapper = new Mock<IMapper>();
    var mockLogger = new Mock<ILogger<CustomerService>>();
    
    var customer = new Customer { Id = 1, Name = "Test Customer" };
    var customerDto = new CustomerDto { Id = 1, Name = "Test Customer" };
    
    mockMapper.Setup(m => m.Map<Customer>(createDto)).Returns(customer);
    mockRepository.Setup(r => r.AddAsync(customer)).ReturnsAsync(customer);
    mockMapper.Setup(m => m.Map<CustomerDto>(customer)).Returns(customerDto);
    
    var service = new CustomerService(mockRepository.Object, mockMapper.Object, mockLogger.Object);
    
    // Act
    var result = await service.CreateAsync(createDto, "test-user");
    
    // Assert
    result.Should().NotBeNull();
    result.Name.Should().Be("Test Customer");
    mockRepository.Verify(r => r.AddAsync(It.IsAny<Customer>()), Times.Once);
}
```

## Resumen

Con estos pasos has creado una entidad completa con:

✅ **Entidad de dominio** con validaciones  
✅ **DTOs** para entrada y salida de datos  
✅ **Servicio** con lógica de negocio  
✅ **Validadores** con FluentValidation  
✅ **Controlador** con endpoints REST  
✅ **Mapeos** con AutoMapper  
✅ **Migración** de base de datos  
✅ **Documentación** automática en Swagger  
✅ **Logging** estructurado  
✅ **Pruebas unitarias**  

El scaffolding automático te ahorra tiempo y asegura consistencia en el código. ¡Solo necesitas personalizar según tus necesidades específicas!