using System.ComponentModel.DataAnnotations;

namespace CleanArchitectureAPI.Core.Entities
{
    public abstract class BaseEntity
    {
        [Key]
        public int Id { get; set; }
        
        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
        
        public DateTime? ModifiedDate { get; set; }
        
        public string CreatedBy { get; set; } = string.Empty;
        
        public string? ModifiedBy { get; set; }
        
        public bool IsActive { get; set; } = true;
    }
}