param(
    [Parameter(Mandatory=$true)]
    [string]$EntityName,
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectPath = "."
)

# Configuración
$CorePath = "$ProjectPath/src/CleanArchitectureAPI.Core"
$ApplicationPath = "$ProjectPath/src/CleanArchitectureAPI.Application"
$InfrastructurePath = "$ProjectPath/src/CleanArchitectureAPI.Infrastructure"
$WebAPIPath = "$ProjectPath/src/CleanArchitectureAPI.WebAPI"

# Función para crear la entidad
function Create-Entity {
    $entityContent = @"
using System.ComponentModel.DataAnnotations;

namespace CleanArchitectureAPI.Core.Entities
{
    public class $EntityName : BaseEntity
    {
        [Required]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [StringLength(500)]
        public string? Description { get; set; }
        
        // Agregar más propiedades según sea necesario
    }
}
"@
    
    $entityPath = "$CorePath/Entities/$EntityName.cs"
    $entityContent | Out-File -FilePath $entityPath -Encoding UTF8
    Write-Host "Entidad creada: $entityPath"
}

# Función para crear DTOs
function Create-DTOs {
    $createDtoContent = @"
using System.ComponentModel.DataAnnotations;

namespace CleanArchitectureAPI.Application.DTOs
{
    public class Create${EntityName}Dto
    {
        [Required]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [StringLength(500)]
        public string? Description { get; set; }
        
        // Agregar más propiedades según sea necesario
    }
}
"@

    $updateDtoContent = @"
using System.ComponentModel.DataAnnotations;

namespace CleanArchitectureAPI.Application.DTOs
{
    public class Update${EntityName}Dto
    {
        [Required]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [StringLength(500)]
        public string? Description { get; set; }
        
        // Agregar más propiedades según sea necesario
    }
}
"@

    $responseDtoContent = @"
namespace CleanArchitectureAPI.Application.DTOs
{
    public class ${EntityName}Dto : BaseDto
    {
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        
        // Agregar más propiedades según sea necesario
    }
}
"@

    $createDtoPath = "$ApplicationPath/DTOs/Create${EntityName}Dto.cs"
    $updateDtoPath = "$ApplicationPath/DTOs/Update${EntityName}Dto.cs"
    $responseDtoPath = "$ApplicationPath/DTOs/${EntityName}Dto.cs"

    $createDtoContent | Out-File -FilePath $createDtoPath -Encoding UTF8
    $updateDtoContent | Out-File -FilePath $updateDtoPath -Encoding UTF8
    $responseDtoContent | Out-File -FilePath $responseDtoPath -Encoding UTF8

    Write-Host "DTOs creados en: $ApplicationPath/DTOs/"
}

# Función para crear la interfaz del servicio
function Create-ServiceInterface {
    $interfaceContent = @"
using CleanArchitectureAPI.Application.DTOs;

namespace CleanArchitectureAPI.Application.Interfaces
{
    public interface I${EntityName}Service
    {
        Task<${EntityName}Dto?> GetByIdAsync(int id);
        Task<IEnumerable<${EntityName}Dto>> GetAllAsync();
        Task<${EntityName}Dto> CreateAsync(Create${EntityName}Dto createDto, string createdBy);
        Task<${EntityName}Dto> UpdateAsync(int id, Update${EntityName}Dto updateDto, string modifiedBy);
        Task DeleteAsync(int id);
        Task<bool> ExistsAsync(int id);
    }
}
"@

    $interfacePath = "$ApplicationPath/Interfaces/I${EntityName}Service.cs"
    $interfaceContent | Out-File -FilePath $interfacePath -Encoding UTF8
    Write-Host "Interfaz del servicio creada: $interfacePath"
}

# Función para crear el servicio
function Create-Service {
    $serviceContent = @"
using AutoMapper;
using CleanArchitectureAPI.Core.Entities;
using CleanArchitectureAPI.Core.Interfaces;
using CleanArchitectureAPI.Application.DTOs;
using CleanArchitectureAPI.Application.Interfaces;

namespace CleanArchitectureAPI.Application.Services
{
    public class ${EntityName}Service : I${EntityName}Service
    {
        private readonly IRepository<${EntityName}> _${EntityName.ToLower()}Repository;
        private readonly IMapper _mapper;

        public ${EntityName}Service(IRepository<${EntityName}> ${EntityName.ToLower()}Repository, IMapper mapper)
        {
            _${EntityName.ToLower()}Repository = ${EntityName.ToLower()}Repository;
            _mapper = mapper;
        }

        public async Task<${EntityName}Dto?> GetByIdAsync(int id)
        {
            var ${EntityName.ToLower()} = await _${EntityName.ToLower()}Repository.GetByIdAsync(id);
            return _mapper.Map<${EntityName}Dto>(${EntityName.ToLower()});
        }

        public async Task<IEnumerable<${EntityName}Dto>> GetAllAsync()
        {
            var ${EntityName.ToLower()}s = await _${EntityName.ToLower()}Repository.GetAllAsync();
            return _mapper.Map<IEnumerable<${EntityName}Dto>>(${EntityName.ToLower()}s);
        }

        public async Task<${EntityName}Dto> CreateAsync(Create${EntityName}Dto createDto, string createdBy)
        {
            var ${EntityName.ToLower()} = _mapper.Map<${EntityName}>(createDto);
            ${EntityName.ToLower()}.CreatedBy = createdBy;
            
            var created${EntityName} = await _${EntityName.ToLower()}Repository.AddAsync(${EntityName.ToLower()});
            return _mapper.Map<${EntityName}Dto>(created${EntityName});
        }

        public async Task<${EntityName}Dto> UpdateAsync(int id, Update${EntityName}Dto updateDto, string modifiedBy)
        {
            var existing${EntityName} = await _${EntityName.ToLower()}Repository.GetByIdAsync(id);
            if (existing${EntityName} == null)
                throw new ArgumentException("`${EntityName} with ID {id} not found");

            _mapper.Map(updateDto, existing${EntityName});
            existing${EntityName}.ModifiedBy = modifiedBy;
            
            var updated${EntityName} = await _${EntityName.ToLower()}Repository.UpdateAsync(existing${EntityName});
            return _mapper.Map<${EntityName}Dto>(updated${EntityName});
        }

        public async Task DeleteAsync(int id)
        {
            var ${EntityName.ToLower()} = await _${EntityName.ToLower()}Repository.GetByIdAsync(id);
            if (${EntityName.ToLower()} == null)
                throw new ArgumentException("`${EntityName} with ID {id} not found");

            await _${EntityName.ToLower()}Repository.DeleteAsync(id);
        }

        public async Task<bool> ExistsAsync(int id)
        {
            return await _${EntityName.ToLower()}Repository.ExistsAsync(id);
        }
    }
}
"@

    $servicePath = "$ApplicationPath/Services/${EntityName}Service.cs"
    $serviceContent | Out-File -FilePath $servicePath -Encoding UTF8
    Write-Host "Servicio creado: $servicePath"
}

# Función para crear validadores
function Create-Validators {
    $createValidatorContent = @"
using FluentValidation;
using CleanArchitectureAPI.Application.DTOs;

namespace CleanArchitectureAPI.Application.Validators
{
    public class Create${EntityName}DtoValidator : AbstractValidator<Create${EntityName}Dto>
    {
        public Create${EntityName}DtoValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("El nombre es requerido")
                .MaximumLength(100).WithMessage("El nombre no puede exceder 100 caracteres");

            RuleFor(x => x.Description)
                .MaximumLength(500).WithMessage("La descripción no puede exceder 500 caracteres");
        }
    }
}
"@

    $updateValidatorContent = @"
using FluentValidation;
using CleanArchitectureAPI.Application.DTOs;

namespace CleanArchitectureAPI.Application.Validators
{
    public class Update${EntityName}DtoValidator : AbstractValidator<Update${EntityName}Dto>
    {
        public Update${EntityName}DtoValidator()
        {
            RuleFor(x => x.Name)
                .NotEmpty().WithMessage("El nombre es requerido")
                .MaximumLength(100).WithMessage("El nombre no puede exceder 100 caracteres");

            RuleFor(x => x.Description)
                .MaximumLength(500).WithMessage("La descripción no puede exceder 500 caracteres");
        }
    }
}
"@

    $createValidatorPath = "$ApplicationPath/Validators/Create${EntityName}DtoValidator.cs"
    $updateValidatorPath = "$ApplicationPath/Validators/Update${EntityName}DtoValidator.cs"

    $createValidatorContent | Out-File -FilePath $createValidatorPath -Encoding UTF8
    $updateValidatorContent | Out-File -FilePath $updateValidatorPath -Encoding UTF8

    Write-Host "Validadores creados en: $ApplicationPath/Validators/"
}

# Función para crear mapeos
function Create-Mappings {
    $mappingContent = @"
using AutoMapper;
using CleanArchitectureAPI.Core.Entities;
using CleanArchitectureAPI.Application.DTOs;

namespace CleanArchitectureAPI.Application.Mappings
{
    public class ${EntityName}MappingProfile : Profile
    {
        public ${EntityName}MappingProfile()
        {
            CreateMap<${EntityName}, ${EntityName}Dto>();
            
            CreateMap<Create${EntityName}Dto, ${EntityName}>()
                .ForMember(dest => dest.CreatedBy, opt => opt.MapFrom(src => src.CreatedBy))
                .ForMember(dest => dest.CreatedDate, opt => opt.MapFrom(src => DateTime.UtcNow))
                .ForMember(dest => dest.IsActive, opt => opt.MapFrom(src => true));
            
            CreateMap<Update${EntityName}Dto, ${EntityName}>()
                .ForMember(dest => dest.ModifiedBy, opt => opt.MapFrom(src => src.ModifiedBy))
                .ForMember(dest => dest.ModifiedDate, opt => opt.MapFrom(src => DateTime.UtcNow));
        }
    }
}
"@

    $mappingPath = "$ApplicationPath/Mappings/${EntityName}MappingProfile.cs"
    $mappingContent | Out-File -FilePath $mappingPath -Encoding UTF8
    Write-Host "Mapeo creado: $mappingPath"
}

# Función para crear el controlador
function Create-Controller {
    $controllerContent = @"
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using CleanArchitectureAPI.Application.DTOs;
using CleanArchitectureAPI.Application.Interfaces;
using System.Security.Claims;

namespace CleanArchitectureAPI.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ${EntityName}sController : ControllerBase
    {
        private readonly I${EntityName}Service _${EntityName.ToLower()}Service;

        public ${EntityName}sController(I${EntityName}Service ${EntityName.ToLower()}Service)
        {
            _${EntityName.ToLower()}Service = ${EntityName.ToLower()}Service;
        }

        /// <summary>
        /// Obtiene todos los ${EntityName.ToLower()}s
        /// </summary>
        /// <returns>Lista de ${EntityName.ToLower()}s</returns>
        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<${EntityName}Dto>), 200)]
        [ProducesResponseType(401)]
        public async Task<ActionResult<IEnumerable<${EntityName}Dto>>> Get${EntityName}s()
        {
            var ${EntityName.ToLower()}s = await _${EntityName.ToLower()}Service.GetAllAsync();
            return Ok(${EntityName.ToLower()}s);
        }

        /// <summary>
        /// Obtiene un ${EntityName.ToLower()} por su ID
        /// </summary>
        /// <param name="id">ID del ${EntityName.ToLower()}</param>
        /// <returns>${EntityName} encontrado</returns>
        [HttpGet("{id}")]
        [ProducesResponseType(typeof(${EntityName}Dto), 200)]
        [ProducesResponseType(404)]
        [ProducesResponseType(401)]
        public async Task<ActionResult<${EntityName}Dto>> Get${EntityName}(int id)
        {
            var ${EntityName.ToLower()} = await _${EntityName.ToLower()}Service.GetByIdAsync(id);
            if (${EntityName.ToLower()} == null)
                return NotFound();

            return Ok(${EntityName.ToLower()});
        }

        /// <summary>
        /// Crea un nuevo ${EntityName.ToLower()}
        /// </summary>
        /// <param name="createDto">Datos del ${EntityName.ToLower()} a crear</param>
        /// <returns>${EntityName} creado</returns>
        [HttpPost]
        [Authorize(Roles = "Admin,Manager")]
        [ProducesResponseType(typeof(${EntityName}Dto), 201)]
        [ProducesResponseType(400)]
        [ProducesResponseType(401)]
        public async Task<ActionResult<${EntityName}Dto>> Create${EntityName}(Create${EntityName}Dto createDto)
        {
            var currentUser = User.FindFirst(ClaimTypes.Name)?.Value ?? "System";
            var ${EntityName.ToLower()} = await _${EntityName.ToLower()}Service.CreateAsync(createDto, currentUser);
            
            return CreatedAtAction(nameof(Get${EntityName}), new { id = ${EntityName.ToLower()}.Id }, ${EntityName.ToLower()});
        }

        /// <summary>
        /// Actualiza un ${EntityName.ToLower()} existente
        /// </summary>
        /// <param name="id">ID del ${EntityName.ToLower()}</param>
        /// <param name="updateDto">Datos actualizados del ${EntityName.ToLower()}</param>
        /// <returns>${EntityName} actualizado</returns>
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin,Manager")]
        [ProducesResponseType(typeof(${EntityName}Dto), 200)]
        [ProducesResponseType(400)]
        [ProducesResponseType(404)]
        [ProducesResponseType(401)]
        public async Task<ActionResult<${EntityName}Dto>> Update${EntityName}(int id, Update${EntityName}Dto updateDto)
        {
            var currentUser = User.FindFirst(ClaimTypes.Name)?.Value ?? "System";
            var ${EntityName.ToLower()} = await _${EntityName.ToLower()}Service.UpdateAsync(id, updateDto, currentUser);
            
            return Ok(${EntityName.ToLower()});
        }

        /// <summary>
        /// Elimina un ${EntityName.ToLower()}
        /// </summary>
        /// <param name="id">ID del ${EntityName.ToLower()}</param>
        /// <returns>Sin contenido</returns>
        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        [ProducesResponseType(204)]
        [ProducesResponseType(404)]
        [ProducesResponseType(401)]
        public async Task<IActionResult> Delete${EntityName}(int id)
        {
            await _${EntityName.ToLower()}Service.DeleteAsync(id);
            return NoContent();
        }
    }
}
"@

    $controllerPath = "$WebAPIPath/Controllers/${EntityName}sController.cs"
    $controllerContent | Out-File -FilePath $controllerPath -Encoding UTF8
    Write-Host "Controlador creado: $controllerPath"
}

# Función para actualizar el DbContext
function Update-DbContext {
    $dbContextPath = "$InfrastructurePath/Data/ApplicationDbContext.cs"
    $content = Get-Content $dbContextPath -Raw
    
    # Agregar DbSet
    $dbSetPattern = "public DbSet<.*>.*{ get; set; }"
    $newDbSet = "        public DbSet<$EntityName> ${EntityName}s { get; set; }`n"
    
    if ($content -match $dbSetPattern) {
        $content = $content -replace "(\s+)(public DbSet<.*>.*{ get; set; })", "`$1`$2`n$newDbSet"
    } else {
        $content = $content -replace "(public class ApplicationDbContext : DbContext)", "`$1`n$newDbSet"
    }
    
    # Agregar configuración de la entidad
    $entityConfig = @"

            // Configuración de la tabla ${EntityName}s
            modelBuilder.Entity<$EntityName>(entity =>
            {
                entity.ToTable("${EntityName.ToUpper()}S");
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Id).HasColumnName("ID").ValueGeneratedOnAdd();
                entity.Property(e => e.Name).HasColumnName("NAME").HasMaxLength(100).IsRequired();
                entity.Property(e => e.Description).HasColumnName("DESCRIPTION").HasMaxLength(500);
                entity.Property(e => e.CreatedDate).HasColumnName("CREATED_DATE").HasDefaultValueSql("SYSDATE");
                entity.Property(e => e.ModifiedDate).HasColumnName("MODIFIED_DATE");
                entity.Property(e => e.CreatedBy).HasColumnName("CREATED_BY").HasMaxLength(100).IsRequired();
                entity.Property(e => e.ModifiedBy).HasColumnName("MODIFIED_BY").HasMaxLength(100);
                entity.Property(e => e.IsActive).HasColumnName("IS_ACTIVE").HasDefaultValue(true);
            });
"@
    
    $content = $content -replace "(// Configuración global para todas las entidades)", "$entityConfig`n`$1"
    
    $content | Out-File -FilePath $dbContextPath -Encoding UTF8
    Write-Host "DbContext actualizado: $dbContextPath"
}

# Función para actualizar las dependencias
function Update-Dependencies {
    # Actualizar Application DependencyInjection
    $appDiPath = "$ApplicationPath/DependencyInjection.cs"
    $appContent = Get-Content $appDiPath -Raw
    
    # Agregar servicio
    $appContent = $appContent -replace "// Registro de servicios", "// Registro de servicios`n            services.AddScoped<I${EntityName}Service, ${EntityName}Service>();"
    
    $appContent | Out-File -FilePath $appDiPath -Encoding UTF8
    Write-Host "Dependencias de Application actualizadas"
}

# Ejecutar todas las funciones
Write-Host "Generando código CRUD para la entidad: $EntityName" -ForegroundColor Green

Create-Entity
Create-DTOs
Create-ServiceInterface
Create-Service
Create-Validators
Create-Mappings
Create-Controller
Update-DbContext
Update-Dependencies

Write-Host "`n¡Código CRUD generado exitosamente!" -ForegroundColor Green
Write-Host "`nPróximos pasos:" -ForegroundColor Yellow
Write-Host "1. Revisar y ajustar las propiedades de la entidad según tus necesidades"
Write-Host "2. Ejecutar 'dotnet build' para verificar que todo compile correctamente"
Write-Host "3. Crear y ejecutar las migraciones de Entity Framework"
Write-Host "4. Probar los endpoints en Swagger"