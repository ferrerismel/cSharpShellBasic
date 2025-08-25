using AutoMapper;
using CleanArchitectureAPI.Core.Entities;
using CleanArchitectureAPI.Application.DTOs;

namespace CleanArchitectureAPI.Application.Mappings
{
    public class ProductMappingProfile : Profile
    {
        public ProductMappingProfile()
        {
            CreateMap<Product, ProductDto>();
            
            CreateMap<CreateProductDto, Product>()
                .ForMember(dest => dest.CreatedDate, opt => opt.MapFrom(src => DateTime.UtcNow))
                .ForMember(dest => dest.IsActive, opt => opt.MapFrom(src => true));
            
            CreateMap<UpdateProductDto, Product>()
                .ForMember(dest => dest.ModifiedDate, opt => opt.MapFrom(src => DateTime.UtcNow));
        }
    }
}