using CleanArchitectureAPI.Application.DTOs;

namespace CleanArchitectureAPI.Application.Interfaces
{
    public interface IProductService
    {
        Task<ProductDto?> GetByIdAsync(int id);
        Task<IEnumerable<ProductDto>> GetAllAsync();
        Task<IEnumerable<ProductDto>> GetByCategoryAsync(string category);
        Task<ProductDto> CreateAsync(CreateProductDto createDto, string createdBy);
        Task<ProductDto> UpdateAsync(int id, UpdateProductDto updateDto, string modifiedBy);
        Task DeleteAsync(int id);
        Task<bool> ExistsAsync(int id);
    }
}