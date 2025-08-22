using Microsoft.EntityFrameworkCore;
using CleanArchitectureAPI.Core.Entities;

namespace CleanArchitectureAPI.Infrastructure.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        public DbSet<Product> Products { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configuración de la tabla Products
            modelBuilder.Entity<Product>(entity =>
            {
                entity.ToTable("PRODUCTS");
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Id).HasColumnName("ID").ValueGeneratedOnAdd();
                entity.Property(e => e.Name).HasColumnName("NAME").HasMaxLength(100).IsRequired();
                entity.Property(e => e.Description).HasColumnName("DESCRIPTION").HasMaxLength(500);
                entity.Property(e => e.Price).HasColumnName("PRICE").HasColumnType("DECIMAL(18,2)").IsRequired();
                entity.Property(e => e.Stock).HasColumnName("STOCK").IsRequired();
                entity.Property(e => e.Category).HasColumnName("CATEGORY").HasMaxLength(50);
                entity.Property(e => e.IsAvailable).HasColumnName("IS_AVAILABLE").HasDefaultValue(true);
                entity.Property(e => e.CreatedDate).HasColumnName("CREATED_DATE").HasDefaultValueSql("SYSDATE");
                entity.Property(e => e.ModifiedDate).HasColumnName("MODIFIED_DATE");
                entity.Property(e => e.CreatedBy).HasColumnName("CREATED_BY").HasMaxLength(100).IsRequired();
                entity.Property(e => e.ModifiedBy).HasColumnName("MODIFIED_BY").HasMaxLength(100);
                entity.Property(e => e.IsActive).HasColumnName("IS_ACTIVE").HasDefaultValue(true);
            });

            // Configuración global para todas las entidades que heredan de BaseEntity
            modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);
        }
    }
}