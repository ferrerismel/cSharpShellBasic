using System.ComponentModel.DataAnnotations;

namespace CleanArchitectureAPI.Application.DTOs
{
    public class CreateProductDto
    {
        [Required]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [StringLength(500)]
        public string? Description { get; set; }
        
        [Required]
        [Range(0, double.MaxValue)]
        public decimal Price { get; set; }
        
        [Range(0, int.MaxValue)]
        public int Stock { get; set; }
        
        [StringLength(50)]
        public string? Category { get; set; }
        
        public bool IsAvailable { get; set; } = true;
    }

    public class UpdateProductDto
    {
        [Required]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [StringLength(500)]
        public string? Description { get; set; }
        
        [Required]
        [Range(0, double.MaxValue)]
        public decimal Price { get; set; }
        
        [Range(0, int.MaxValue)]
        public int Stock { get; set; }
        
        [StringLength(50)]
        public string? Category { get; set; }
        
        public bool IsAvailable { get; set; } = true;
    }

    public class ProductDto : BaseDto
    {
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public decimal Price { get; set; }
        public int Stock { get; set; }
        public string? Category { get; set; }
        public bool IsAvailable { get; set; }
    }
}